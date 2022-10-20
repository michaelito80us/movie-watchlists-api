class Cast < ApplicationRecord
  has_many :movie_cast
  has_many :movies, through: :movie_cast
end
