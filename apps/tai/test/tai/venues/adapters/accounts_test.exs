defmodule Tai.Venues.Adapters.AccountsTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    start_supervised!(Tai.TestSupport.Mocks.Server)
    HTTPoison.start()
    :ok
  end

  setup do
    on_exit(fn ->
      :ok = Application.stop(:tai)
    end)

    {:ok, _} = Application.ensure_all_started(:tai)
    :ok
  end

  @test_venues Tai.TestSupport.Helpers.test_venue_adapters_accounts()

  @test_venues
  |> Enum.map(fn {_, venue} ->
    @venue venue
    @credential_id venue.credentials |> Map.keys() |> List.first()

    test "#{venue.id} returns a list of accounts" do
      setup_venue(@venue.id)

      use_cassette "venue_adapters/shared/accounts/#{@venue.id}/success" do
        assert {:ok, accounts} = Tai.Venues.Client.accounts(@venue, @credential_id)
        assert Enum.count(accounts) > 0
        assert [%Tai.Venues.Account{} = account | _] = accounts
        assert account.venue_id == @venue.id
        assert account.credential_id == @credential_id
        assert Decimal.cmp(account.free, Decimal.new(0)) != :lt
        assert Decimal.cmp(account.locked, Decimal.new(0)) != :lt
      end
    end
  end)

  def setup_venue(:mock) do
    Tai.TestSupport.Mocks.Responses.Accounts.for_venue_and_credential(
      :mock,
      :main,
      [
        %{asset: :btc, free: Decimal.new("0.1"), locked: Decimal.new("0.2")},
        %{asset: :ltc, free: Decimal.new("0.3"), locked: Decimal.new("0.4")}
      ]
    )
  end

  def setup_venue(_), do: nil
end
