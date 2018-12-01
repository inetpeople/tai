defmodule Tai.Events.UnlockAssetBalanceOkTest do
  use ExUnit.Case, async: true

  test ".to_data/1 transforms decimal data to strings" do
    event = %Tai.Events.UnlockAssetBalanceOk{
      venue_id: :my_venue,
      account_id: :my_account,
      asset: :btc,
      qty: Decimal.new("0.1")
    }

    assert Tai.LogEvent.to_data(event) == %{
             venue_id: :my_venue,
             account_id: :my_account,
             asset: :btc,
             qty: "0.1"
           }
  end
end
