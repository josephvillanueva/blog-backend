class AddUsernameToBlogs < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :username, :string
  end
end
