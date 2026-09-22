# Links comments and votes to the posts they belong to, replaces the
# upvote/downvote counter table with one vote per user per post, and drops
# the unused tags table and duplicated blog columns. Tags live on each post.
class ReworkCommentsVotesAndTags < ActiveRecord::Migration[7.0]
  def change
    add_reference :comments, :blog, null: false, foreign_key: true

    drop_table :votes do |t|
      t.integer :upvote
      t.integer :downvote
      t.timestamps
    end

    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :blog, null: false, foreign_key: true
      t.integer :value, null: false
      t.timestamps
    end
    add_index :votes, %i[user_id blog_id], unique: true

    drop_table :tags do |t|
      t.string :tag
      t.timestamps
    end

    remove_column :blogs, :blog, :text
    remove_column :blogs, :username, :string
    rename_column :blogs, :tag, :tags
    change_column_default :blogs, :status, from: nil, to: "published"

    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
