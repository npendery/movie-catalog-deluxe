require 'sinatra'
require 'pg'
require 'pry'

enable :sessions

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def get_movies
  db_connection { |conn| conn.exec("SELECT * FROM movies") }
end

get "/main" do
  erb :main
end

get "/" do
  redirect "/main"
end

get "/actors" do
  actor_list = db_connection do |conn|
    conn.exec("
    SELECT actors.name, actors.id as id
    FROM actors
    WHERE actors.name LIKE 'Tom%'
    ORDER BY actors.name ASC
    LIMIT 10")
  end
# binding.pry
  erb :'actors/index', locals: { actor_list: actor_list }
end

get "/actors/:actor_id" do
  actor_id = params[:actor_id]
  actor_info = db_connection do |conn|
    conn.exec("
    SELECT actors.name as Actor, movies.title as Movie, movies.year as Year, cast_members.character as Role, actors.id as id
    FROM actors
    JOIN cast_members ON (actors.id = cast_members.id)
    JOIN movies ON (movies.id = cast_members.movie_id)
    WHERE actors.id = $1", [actor_id])
  end
  # binding.pry

  erb :'actors/show', locals: {
    actor_id: actor_id,
    actor_info: actor_info}
end

get "/movies" do
  movie_list = db_connection do |conn|
    conn.exec("
    SELECT movies.title, movies.year, movies.rating, genres.name as genre, studios.name AS studio, movies.id as id
    FROM movies
    JOIN studios ON (movies.studio_id = studios.id)
    JOIN genres ON (movies.genre_id = genres.id)
    ORDER BY movies.title ASC, movies.year ASC
    LIMIT 20")
  end
# binding.pry
  erb :'movies/index', locals: { movie_list: movie_list }
end

get "/movies/:movie_id" do
  movie_id = params[:movie_id]
  movie_info = db_connection do |conn|
    conn.exec("
    SELECT actors.name as Actor, movies.title as Movie, movies.year as Year, cast_members.character as Role, genres.name as genre, studios.name as studio, movies.id as id
    FROM movies
    JOIN studios ON (movies.studio_id = studios.id)
    JOIN genres ON (movies.genre_id = genres.id)
    JOIN cast_members ON (movies.id = cast_members.movie_id)
    JOIN actors ON (actors.id = cast_members.actor_id)
    WHERE movies.id = $1", [movie_id])
  end
# binding.pry
  erb :'movies/show', locals: {
    movie_id: movie_id,
    movie_info: movie_info}
end

# get "/movies/orderyear" do
#   year_list = db_connection do |conn|
#     conn.exec("
#     SELECT movies.title, movies.year, movies.rating, genres.name as genre, studios.name AS studio, movies.id as id
#     FROM movies
#     JOIN studios ON (movies.studio_id = studios.id)
#     JOIN genres ON (movies.genre_id = genres.id)
#     ORDER BY movies.year ASC, movies.title ASC
#     LIMIT 20")
#   end
# # binding.pry
#   erb :'movies/year_order', locals: { year_list: year_list }
# end
#
# get "/movies/orderrating" do
#   rating_list = db_connection do |conn|
#     conn.exec("
#     SELECT movies.title, movies.year, movies.rating, genres.name as genre, studios.name AS studio, movies.id as id
#     FROM movies
#     JOIN studios ON (movies.studio_id = studios.id)
#     JOIN genres ON (movies.genre_id = genres.id)
#     ORDER BY movies.rating DESC, movies.title ASC
#     LIMIT 20")
#   end
# # binding.pry
#   erb :'movies/ratings_order', locals: { rating_list: rating_list }
# end
