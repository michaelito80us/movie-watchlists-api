class CreateUserHistories < ActiveRecord::Migration[7.0]
  def change
    create_table :user_histories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true
      t.datetime :visited_on

      t.timestamps
    end
  end
end
