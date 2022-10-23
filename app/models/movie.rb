class Movie < ApplicationRecord
  attr_accessor :full_details

  has_many :movie_casts, dependent: :destroy
  has_and_belongs_to_many :genres
  has_many :casts, through: :movie_casts
  has_many :watchlist_movies, dependent: :destroy
  has_many :watchlists, through: :watchlist_movies
  has_many :user_histories, dependent: :destroy

  has_many :recommendations, dependent: :destroy
  has_many :recommended_movies, through: :recommendations

  def full_details?
    full_details
  end
end
