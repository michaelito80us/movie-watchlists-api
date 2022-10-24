# app/jobs/get_movie_details_job.rb
class GetMovieDetailsJob < ApplicationJob
  queue_as :default

  include AddMovie

  def perform(movie)
    puts '******** performing later ********'
    tmdb_movie_id = movie.tmdb_movie_id
    movie = show_api_call(tmdb_movie_id)
    puts '******** movie ********'
    puts movie.duration
    movie.save
  end
end
