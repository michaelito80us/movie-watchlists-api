class Recommendation < ApplicationRecord
  belongs_to :recommended_movie, class_name: 'Movie'
  belongs_to :is_recommended_movie, class_name: 'Movie'
end
