# Shared by the tests that read lists and tables of Portals: finds the row for
# one Portal by its title and checks its text, so a value cannot be credited to
# the wrong row. Lists use the defaults; tables pass `row: "tbody tr", title: "th"`.
module RowTestHelper
  def assert_row(name, *patterns, row: "main li", title: "h2")
    found = css_select(row).find { |item| item.at_css(title).text.strip == name }
    assert found, "expected a row for #{name}"
    patterns.each { |pattern| assert_match pattern, found.text }
    found
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include RowTestHelper
end
