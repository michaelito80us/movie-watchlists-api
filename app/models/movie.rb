class Movie < ApplicationRecord
  attr_accessor :full_details

  has_many :movie_genres, dependent: :destroy
  has_many :movie_casts, dependent: :destroy
  has_many :genres, through: :movie_genres
  has_many :casts, through: :movie_casts
  has_many :watchlist_movies, dependent: :destroy
  has_many :watchlists, through: :watchlist_movies
  has_many :user_histories, dependent: :destroy

  def full_details?
    full_details
  end
end
