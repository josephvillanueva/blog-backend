class AddTagsToBlog < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :blog, :text
  end
end
