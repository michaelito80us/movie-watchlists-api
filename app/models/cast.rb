class Cast < ApplicationRecord
  has_many :movie_casts, dependent: :destroy
  has_many :movies, through: :movie_casts
end
