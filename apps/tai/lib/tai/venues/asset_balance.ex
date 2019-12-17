defmodule Tai.Venues.AssetBalance do
  alias __MODULE__

  @type venue_id :: Tai.Venues.Adapter.venue_id()
  @type account_id :: Tai.Venues.Adapter.account_id()
  @type asset :: atom
  @type t :: %AssetBalance{
          venue_id: venue_id,
          account_id: account_id,
          asset: asset,
          free: Decimal.t(),
          locked: Decimal.t()
        }

  @enforce_keys ~w(
    venue_id
    account_id
    asset
    free
    locked
  )a
  defstruct ~w(
    venue_id
    account_id
    asset
    free
    locked
  )a

  @spec total(t) :: Decimal.t()
  def total(b), do: Decimal.add(b.free, b.locked)
end

defimpl Stored.Item, for: Tai.Venues.AssetBalance do
  @type asset_balance :: Tai.Venues.AssetBalance.t()

  @spec key(asset_balance) :: String.t()
  def key(b), do: {b.venue_id, b.account_id, b.asset}
end
