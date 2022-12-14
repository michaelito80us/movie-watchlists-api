class CreateWatchlists < ActiveRecord::Migration[7.0]
  def change
    create_table :watchlists do |t|
      t.string :name
      t.string :description
      t.references :user, null: false, foreign_key: true
      t.integer :unwatched_runtime, default: 0
      t.integer :total_items, default: 0
      t.integer :score_sum, default: 0

      t.timestamps
    end
  end
end
