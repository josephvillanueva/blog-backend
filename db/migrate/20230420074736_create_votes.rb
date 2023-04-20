class CreateVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :votes do |t|
      t.integer :upvote
      t.integer :downvote

      t.timestamps
    end
  end
end
