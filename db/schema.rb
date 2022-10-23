# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_10_22_152533) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "casts", force: :cascade do |t|
    t.string "name"
    t.string "image_url"
    t.string "tmdb_cast_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres", force: :cascade do |t|
    t.string "name"
    t.integer "tmdb_genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "genres_movies", id: false, force: :cascade do |t|
    t.bigint "movie_id"
    t.bigint "genre_id"
    t.index ["genre_id"], name: "index_genres_movies_on_genre_id"
    t.index ["movie_id"], name: "index_genres_movies_on_movie_id"
  end

  create_table "movie_casts", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "cast_id", null: false
    t.string "character"
    t.string "job"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cast_id"], name: "index_movie_casts_on_cast_id"
    t.index ["movie_id"], name: "index_movie_casts_on_movie_id"
  end

  create_table "movies", force: :cascade do |t|
    t.string "name"
    t.integer "duration"
    t.integer "score"
    t.string "overview"
    t.date "release_date"
    t.string "poster_url"
    t.integer "tmdb_movie_id"
    t.string "trailer_url"
    t.decimal "popularity"
    t.boolean "complete_data", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies_genres", id: false, force: :cascade do |t|
    t.bigint "movie_id"
    t.bigint "genre_id"
    t.index ["genre_id"], name: "index_movies_genres_on_genre_id"
    t.index ["movie_id"], name: "index_movies_genres_on_movie_id"
  end

  create_table "user_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.datetime "visited_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_user_histories_on_movie_id"
    t.index ["user_id"], name: "index_user_histories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.string "name"
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "watchlist_movies", force: :cascade do |t|
    t.bigint "watchlist_id", null: false
    t.bigint "movie_id", null: false
    t.boolean "watched"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_watchlist_movies_on_movie_id"
    t.index ["watchlist_id"], name: "index_watchlist_movies_on_watchlist_id"
  end

  create_table "watchlists", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.bigint "user_id", null: false
    t.integer "unwatched_runtime", default: 0
    t.integer "total_items", default: 0
    t.integer "score_sum"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_watchlists_on_user_id"
  end

  add_foreign_key "movie_casts", "casts"
  add_foreign_key "movie_casts", "movies"
  add_foreign_key "user_histories", "movies"
  add_foreign_key "user_histories", "users"
  add_foreign_key "watchlist_movies", "movies"
  add_foreign_key "watchlist_movies", "watchlists"
  add_foreign_key "watchlists", "users"
end
