class Recommendation < ApplicationRecord
  belongs_to :movie
  belongs_to :recommended_movie, class_name: 'Movie'
end
