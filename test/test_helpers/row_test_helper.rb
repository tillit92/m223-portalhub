# Shared by the tests that read the Portal and Booking lists: finds the list
# row for one Portal by its heading and checks its text, so a value cannot be
# credited to the wrong row.
module RowTestHelper
  def assert_row(name, *patterns)
    row = css_select("main li").find { |item| item.at_css("h2").text.strip == name }
    assert row, "expected a row for #{name}"
    patterns.each { |pattern| assert_match pattern, row.text }
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include RowTestHelper
end
