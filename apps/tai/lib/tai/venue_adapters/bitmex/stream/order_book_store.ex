defmodule Tai.VenueAdapters.Bitmex.Stream.OrderBookStore do
  use GenServer
  require Logger

  @type venue_id :: Tai.Venues.Adapter.venue_id()
  @type product_symbol :: Tai.Venues.Product.symbol()

  @type t :: %Tai.VenueAdapters.Bitmex.Stream.OrderBookStore{
          venue_id: venue_id,
          symbol: product_symbol,
          table: map
        }

  @enforce_keys ~w(venue_id symbol table)a
  defstruct ~w(venue_id symbol table)a

  def start_link(venue_id: venue_id, symbol: symbol, venue_symbol: venue_symbol) do
    store = %Tai.VenueAdapters.Bitmex.Stream.OrderBookStore{
      venue_id: venue_id,
      symbol: symbol,
      table: %{}
    }

    GenServer.start_link(__MODULE__, store, name: to_name(venue_id, venue_symbol))
  end

  @spec init(t) :: {:ok, t}
  def init(state) do
    {:ok, state}
  end

  @spec to_name(venue_id, venue_symbol :: String.t()) :: atom
  def to_name(venue_id, venue_symbol), do: :"#{__MODULE__}_#{venue_id}_#{venue_symbol}"

  def handle_cast({:snapshot, data, received_at}, state) do
    normalized =
      data
      |> Enum.reduce(
        %{bids: %{}, asks: %{}, table: %{}},
        fn
          %{"id" => id, "price" => price, "side" => "Sell", "size" => size}, acc ->
            asks = acc.asks |> Map.put(price, {size, received_at, nil})
            table = acc.table |> Map.put(id, price)

            acc
            |> Map.put(:asks, asks)
            |> Map.put(:table, table)

          %{"id" => id, "price" => price, "side" => "Buy", "size" => size}, acc ->
            bids = acc.bids |> Map.put(price, {size, received_at, nil})
            table = acc.table |> Map.put(id, price)

            acc
            |> Map.put(:bids, bids)
            |> Map.put(:table, table)
        end
      )

    snapshot = %Tai.Markets.OrderBook{
      venue_id: state.venue_id,
      product_symbol: state.symbol,
      bids: normalized.bids,
      asks: normalized.asks
    }

    :ok = Tai.Markets.OrderBook.replace(snapshot)

    new_table = Map.merge(state.table, normalized.table)
    new_state = Map.put(state, :table, new_table)

    {:noreply, new_state}
  end

  def handle_cast({:insert, data, received_at}, state) do
    normalized =
      data
      |> Enum.reduce(
        %{bids: %{}, asks: %{}, table: %{}},
        fn
          %{"id" => id, "price" => price, "side" => "Sell", "size" => size}, acc ->
            asks = acc.asks |> Map.put(price, {size, received_at, nil})
            table = acc.table |> Map.put(id, price)

            acc
            |> Map.put(:asks, asks)
            |> Map.put(:table, table)

          %{"id" => id, "price" => price, "side" => "Buy", "size" => size}, acc ->
            bids = acc.bids |> Map.put(price, {size, received_at, nil})
            table = acc.table |> Map.put(id, price)

            acc
            |> Map.put(:bids, bids)
            |> Map.put(:table, table)
        end
      )

    %Tai.Markets.OrderBook{
      venue_id: state.venue_id,
      product_symbol: state.symbol,
      bids: normalized.bids,
      asks: normalized.asks
    }
    |> Tai.Markets.OrderBook.update()

    new_table = Map.merge(state.table, normalized.table)
    new_state = Map.put(state, :table, new_table)

    {:noreply, new_state}
  end

  def handle_cast({:update, data, received_at}, state) do
    normalized =
      data
      |> Enum.reduce(
        %{bids: %{}, asks: %{}},
        fn
          %{"id" => id, "side" => "Sell", "size" => size}, acc ->
            price = Map.fetch!(state.table, id)
            asks = acc.asks |> Map.put(price, {size, received_at, nil})
            Map.put(acc, :asks, asks)

          %{"id" => id, "side" => "Buy", "size" => size}, acc ->
            price = Map.fetch!(state.table, id)
            bids = acc.bids |> Map.put(price, {size, received_at, nil})
            Map.put(acc, :bids, bids)
        end
      )

    %Tai.Markets.OrderBook{
      venue_id: state.venue_id,
      product_symbol: state.symbol,
      bids: normalized.bids,
      asks: normalized.asks
    }
    |> Tai.Markets.OrderBook.update()

    {:noreply, state}
  end

  def handle_cast({:delete, data, received_at}, state) do
    normalized =
      data
      |> Enum.reduce(
        %{bids: %{}, asks: %{}},
        fn
          %{"id" => id, "side" => "Sell"}, acc ->
            price = Map.fetch!(state.table, id)
            asks = acc.asks |> Map.put(price, {0, received_at, nil})
            Map.put(acc, :asks, asks)

          %{"id" => id, "side" => "Buy"}, acc ->
            price = Map.fetch!(state.table, id)
            bids = acc.bids |> Map.put(price, {0, received_at, nil})
            Map.put(acc, :bids, bids)
        end
      )

    %Tai.Markets.OrderBook{
      venue_id: state.venue_id,
      product_symbol: state.symbol,
      bids: normalized.bids,
      asks: normalized.asks
    }
    |> Tai.Markets.OrderBook.update()

    {:noreply, state}
  end
end
