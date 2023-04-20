class AddStatusToBlog < ActiveRecord::Migration[7.0]
  def change
    add_column :blogs, :status, :string
  end
end
