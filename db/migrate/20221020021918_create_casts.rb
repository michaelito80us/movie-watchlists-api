class CreateCasts < ActiveRecord::Migration[7.0]
  def change
    create_table :casts do |t|
      t.string :name
      t.string :image_url
      t.string :tmdb_cast_id

      t.timestamps
    end
  end
end
