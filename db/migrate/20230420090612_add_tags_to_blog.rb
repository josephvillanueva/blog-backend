class AddTagsToBlog < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :tag, :text, array: true, default: []
  end
end
