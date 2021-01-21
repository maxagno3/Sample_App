require "test_helper"

class MicropostInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:raptor)
  end

  test "micropost interface" do
    log_in_as @user
    get root_path
    assert_select "div.pagination"
    assert_select "input[type=file]"
    # Invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]", "/?page=2" #Correct pagination link
    # Valid submission
    # micropost = assigns(:micropost)
    content = "This micropost really ties the room together"
    # image = fixture_file_upload("../kitten.jpg", "image/jpeg")
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    # assert micropost.image.attached?
    follow_redirect!
    assert_match content, response.body
    # Delete
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
    # No delete links when visiting different user
    assert_select "a", text: "delete", count: 0
  end

  # test "micropost sidebar count" do
  #   log_in_as(@user)
  #   get root_url
  #   assert_match "#{@user.microposts.count} microposts", response.body
  #   # User with zero microposts
  #   other_user = users(:malory)
  #   log_in_as(other_user)
  #   get root_path
  #   assert_match "0 microposts", response.body
  #   other_user.microposts.create!(content: "A micropost")
  #   get root_path
  #   assert_match other_user.microposts.content, response.body
  # end
end
