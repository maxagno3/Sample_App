require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:raptor)
    @other_user = users(:scorpion)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit if logged in as a wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update if logged in as a wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name, email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect to index if not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should not allow admin attribute to be edited via the web" do
    log_in_as @other_user
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
    user: {
        password: "password",
        password_confirmation: "password",
        admin: true
      }
    }
    assert_not @other_user.reload.admin?
  end

  test "should redirect destroy to login page when not logged in" do
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy to home page when logged in as non admin" do
    log_in_as(@other_user)
    assert_no_difference "User.count" do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
end
