class Movie < ApplicationRecord
  attr_accessor :full_details

  has_many :movie_casts, dependent: :destroy
  has_and_belongs_to_many :genres
  has_many :casts, through: :movie_casts
  has_many :watchlist_movies, dependent: :destroy
  has_many :watchlists, through: :watchlist_movies
  has_many :user_histories, dependent: :destroy

  has_many :recommended_movies, class_name: 'Movie', foreign_key: 'recommended_by_id'
  # has_many :is_recommended_movies, class_name: 'Movie', foreign_key: 'is_recommended_movie_id'
  # has_many :recommended_movies, through: :is_recommended_movies
  # has_many :is_recommended_movies, through: :recommended_movies

  def full_details?
    full_details
  end
end
