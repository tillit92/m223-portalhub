require "test_helper"

# Where the custom images show up. The files themselves are the project's own
# artwork; these tests only check that the pages use them where intended.
class ImagesTest < ActionDispatch::IntegrationTest
  test "the logo is the portal image, on the login page and in the navigation" do
    get new_session_path
    assert_select ".auth__content .brand img.brand__mark[src*=portal]"

    sign_in_as users(:morty)
    get root_path
    assert_select ".site-header .brand img.brand__mark[src*=portal]"
  end

  test "the logo image is decorative and has an empty alt text" do
    sign_in_as users(:morty)

    get root_path

    assert_select ".site-header .brand img.brand__mark[alt='']"
  end

  test "the login page shows the portal gif together with the portal gun on its stage" do
    get new_session_path

    assert_select ".auth__stage img.auth__portal[src*=portal][alt]"
    assert_select ".auth__stage img.auth__gun[src*=gun]"
  end

  test "the favicon is the portal image, as a PNG only" do
    get new_session_path

    assert_select "link[rel=icon][href=?][type='image/png']", "/icon.png"
    assert_select "link[rel=icon][type='image/svg+xml']", 0

    get "/icon.png"
    assert_response :success
    assert_equal "image/png", response.media_type
  end

  test "an empty portal overview shows Rick" do
    sign_in_as users(:morty)
    Portal.destroy_all

    get root_path

    assert_select ".empty img.empty__image[src*=rick]"
  end

  test "an empty list of bookings shows Rick" do
    sign_in_as users(:beth)

    get bookings_path

    assert_select ".empty img.empty__image[src*=rick]"
  end

  test "a page with content does not show the empty state image" do
    sign_in_as users(:morty)

    get root_path
    assert_select ".empty__image", 0

    get bookings_path
    assert_select ".empty__image", 0
  end

  test "every image on the pages has an alt text" do
    get new_session_path
    sign_in_as users(:morty)
    Portal.destroy_all
    get root_path

    assert_select "img:not([alt])", 0
  end
end
