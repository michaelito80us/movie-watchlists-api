class AddWatchProviderToMovies < ActiveRecord::Migration[7.0]
  def change
    add_column :movies, :watch_provider, :string
  end
end
