require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:raptor)
    @non_admin = users(:scorpion)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    first_page_users = User.paginate(page: 1)
    first_page_users.each do |user|
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: 'Delete'
      end
    end
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non admin" do
    log_in_as @non_admin
    get users_path
    assert_select "a", text: "Delete", count: 0
  end
end
