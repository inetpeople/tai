defmodule Tai.Events.AdvisorHandleEventErrorTest do
  use ExUnit.Case, async: true

  test ".to_data/1 transforms error & stacktrace to a string" do
    attrs = [
      event: {:event, :some_event},
      error: %RuntimeError{message: "!!!This is an ERROR!!!"},
      stacktrace: [
        {MyAdvisor, :execute_handle_event, 2, [file: 'lib/tai/advisor.ex', line: 226]}
      ]
    ]

    event = struct(Tai.Events.AdvisorHandleEventError, attrs)

    assert %{} = json = Tai.LogEvent.to_data(event)
    assert json.event == "{:event, :some_event}"
    assert json.error == "%RuntimeError{message: \"!!!This is an ERROR!!!\"}"

    assert json.stacktrace ==
             "[{MyAdvisor, :execute_handle_event, 2, [file: 'lib/tai/advisor.ex', line: 226]}]"
  end
end
