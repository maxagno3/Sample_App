require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:raptor)
  end

  test "unsuccessful user edit" do
    log_in_as @user
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), params: {
      user: {
        name: "",
        email: "fooatbar.com",
        password: "foo",
        password_confirmation: "bar"
      }
    }
    assert_template "users/edit"
    assert_select "div.alert", "The form contains 4 errors."
  end

  test "successful user edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to edit_user_path(@user)
    get edit_user_path(@user)
    get edit_user_path(@user)
    log_in_as @user
    assert_redirected_to @user
    name = "Raptor"
    email = "raptor@example.com"
    patch user_path(@user), params: {
      user: {
        name: name,
        email: email,
        password: "",
        password_confirmation: ""
      }
    }
    assert_not flash.empty? # Check for non empty flash message.
    assert_redirected_to @users # Check for successful redirect.
    @user.reload # Reload the user’s values from the database and confirm that they were successfully updated.
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
