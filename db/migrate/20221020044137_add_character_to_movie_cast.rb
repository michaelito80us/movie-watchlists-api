class AddCharacterToMovieCast < ActiveRecord::Migration[7.0]
  def change
    add_column :movie_casts, :character, :string
  end
end
