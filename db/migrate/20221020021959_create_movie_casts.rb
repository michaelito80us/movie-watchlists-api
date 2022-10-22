class CreateMovieCasts < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_casts do |t|
      t.references :movie, null: false, foreign_key: true
      t.references :cast, null: false, foreign_key: true
      t.string :character
      t.string :job

      t.timestamps
    end
  end
end
