defmodule Tai.Trading.Position do
  alias __MODULE__

  @type venue_id :: Tai.Venue.id()
  @type credential_id :: Tai.Venue.credential_id()
  @type product_symbol :: Tai.Venues.Product.symbol()
  @type t :: %Position{
          venue_id: venue_id,
          credential_id: credential_id,
          product_symbol: product_symbol,
          side: :long | :short,
          qty: Decimal.t(),
          entry_price: Decimal.t(),
          leverage: Decimal.t(),
          margin_mode: :crossed | :fixed
        }

  @enforce_keys ~w(
    venue_id
    credential_id
    product_symbol
    side
    qty
    entry_price
    leverage
    margin_mode
  )a
  defstruct ~w(
    venue_id
    credential_id
    product_symbol
    side
    qty
    entry_price
    leverage
    margin_mode
  )a
end
