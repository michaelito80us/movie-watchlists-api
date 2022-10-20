# app/jobs/movie_details_job.rb
class MovieDetailsJob < ApplicationJob
  queue_as :default

  def perform(movie)
    # Download the movie details from TMDB
    # create a new movie object
    # save the movie object
  end
end
