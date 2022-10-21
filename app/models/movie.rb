class Movie < ApplicationRecord
  attr_accessor :full_details

  has_many :movie_genres, dependent: :destroy
  has_many :movie_casts, dependent: :destroy
  has_many :genres, through: :movie_genres
  has_many :casts, through: :movie_casts

  def full_details?
    full_details
  end
end
