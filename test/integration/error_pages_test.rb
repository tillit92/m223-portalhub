require "test_helper"

class ErrorPagesTest < ActionDispatch::IntegrationTest
  OLD_CHROME = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36"

  # file => the German headline it must show
  PAGES = {
    "404.html" => "Diese Dimension gibt es nicht",
    "422.html" => "Das hat nicht geklappt",
    "500.html" => "Hier ist etwas schiefgelaufen",
    "400.html" => "Diese Anfrage ergibt keinen Sinn",
    "406-unsupported-browser.html" => "Dein Browser ist zu alt für diese Dimension"
  }.freeze

  test "every error page is German and shows its headline" do
    PAGES.each do |file, headline|
      get "/#{file}"

      assert_response :success, file
      assert_select "html[lang=de]", 1, "#{file} must be German"
      assert_select "h1", headline
      assert_no_match(/The page you were looking for|Your browser is not supported|Maybe you tried to change|We're sorry|The change you wanted/i, response.body, "#{file} still has English default text")
    end
  end

  # file => the Rick GIF that page shows
  RICK = {
    "404.html" => "rick1.gif", "422.html" => "rick1.gif", "400.html" => "rick1.gif",
    "500.html" => "rick2.gif", "406-unsupported-browser.html" => "rick2.gif"
  }.freeze

  test "every error page shows a Rick GIF with an alt text" do
    RICK.each do |file, gif|
      get "/#{file}"

      assert_select "img.rick[src=?][alt]", "/bilder/#{gif}"
    end
  end

  test "the Rick GIFs for the error pages are served" do
    %w[ rick1.gif rick2.gif ].each do |gif|
      get "/bilder/#{gif}"

      assert_response :success
      assert_equal "image/gif", response.media_type
    end
  end

  test "pages you can leave offer a way back to the overview" do
    %w[ 404.html 422.html 500.html 400.html ].each do |file|
      get "/#{file}"

      assert_select "a.button[href=?]", "/", text: "Zurück zur Übersicht"
    end
  end

  test "the browser page names the minimum versions" do
    get "/406-unsupported-browser.html"

    assert_select "main", /Chrome ab 120/
    assert_select "main", /Firefox ab 121/
    assert_select "main", /Safari ab 17\.2/
  end

  test "an unknown portal shows the German 404 page, as visitors see it in production" do
    sign_in_as users(:morty)

    as_in_production do
      get portal_path(id: 0)
    end

    assert_response :not_found
    assert_select "h1", "Diese Dimension gibt es nicht"
  end

  test "a browser below the minimum versions gets the German page" do
    get new_session_path, headers: { "User-Agent" => OLD_CHROME }

    assert_response :not_acceptable
    assert_select "h1", "Dein Browser ist zu alt für diese Dimension"
  end

  private
    # The test environment shows Rails' developer page for exceptions. This
    # switches to what production does, the static page from public/, and puts
    # the setting back afterwards.
    KEY = "action_dispatch.show_detailed_exceptions".freeze

    def as_in_production
      original = Rails.application.env_config[KEY]
      Rails.application.env_config[KEY] = false
      yield
    ensure
      Rails.application.env_config[KEY] = original
    end
end
