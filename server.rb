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

get "/actors" do
  actor_list = db_connection do |conn|
    conn.exec("
    SELECT name
    FROM actors
    WHERE name LIKE 'Tom%'
    ORDER BY name ASC
    LIMIT 10")
  end
# binding.pry
  erb :'actors/index', locals: { actor_list: actor_list }
end

get "/actors/:actor_name" do
  actor_name = params[:actor_name]
  actor_info = db_connection do |conn|
    conn.exec("
    SELECT actors.name as Actor, movies.title as Movie, movies.year as Year, cast_members.character as Role
    FROM actors
    JOIN cast_members ON (actors.id = cast_members.actor_id)
    JOIN movies ON (movies.id = cast_members.movie_id)
    WHERE name = $1", [actor_name])
  end
# binding.pry
  erb :'actors/show', locals: {
    actor_name: actor_name,
    actor_info: actor_info}
end

get "/movies" do
  movie_list = db_connection do |conn|
    conn.exec("
    SELECT movies.title, movies.year, movies.rating, genres.name as genre, studios.name AS studio
    FROM movies
    JOIN studios ON (movies.studio_id = studios.id)
    JOIN genres ON (movies.genre_id = genres.id)
    ORDER BY movies.title ASC, movies.year ASC
    LIMIT 20")
  end
# binding.pry
  erb :'movies/index', locals: { movie_list: movie_list }
end

get "/movies/:movie_title" do
  movie_title = params[:movie_title]
  movie_info = db_connection do |conn|
    conn.exec("
    SELECT actors.name as Actor, movies.title as Movie, movies.year as Year, cast_members.character as Role, genres.name as genre, studios.name as studio
    FROM movies
    JOIN studios ON (movies.studio_id = studios.id)
    JOIN genres ON (movies.genre_id = genres.id)
    JOIN cast_members ON (movies.id = cast_members.movie_id)
    JOIN actors ON (actors.id = cast_members.actor_id)
    WHERE movies.title = $1", [movie_title])
  end
# binding.pry
  erb :'movies/show', locals: {
    movie_title: movie_title,
    movie_info: movie_info}
end

# post "/" do
#   long_url = params[:long_url]
#   short_url = create_short_url
#
#   if unique_long_url?(long_url)
#     db_connection do |conn|
#       conn.exec_params("INSERT INTO urls (long_url, short_url) VALUES ($1, $2)", [long_url, short_url])
#     end
#     redirect "/"
#   else
#     flash[:error] = "Hey, that URL has already been submitted!"
#     redirect "/"
#   end
# end
#
# get "/:short_url" do
#   short_url = params[:short_url]
#
#   long_result = db_connection do |conn|
#     conn.exec("SELECT long_url FROM urls WHERE short_url = $1", [short_url])
#   end
#   long_url = long_result.first["long_url"]
#
#   redirect long_url
# end
