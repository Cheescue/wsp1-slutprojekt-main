require 'debug'
require 'awesome_print'
require 'bcrypt'
require 'securerandom'

class App < Sinatra::Base

  setup_development_features(self)

  def db
    return @db if @db

    @db = SQLite3::Database.new("db/sqlite.db")
    @db.results_as_hash = true
    @db
  end
  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  before do
    ap session[:user_id]
    if session[:user_id]
      @current_user = db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
      ap @current_user
    end
  end

  get '/' do
    redirect '/pizzashoppen'
  end

  get '/pizzashoppen' do
    @pizza = db.execute("SELECT * FROM pizza")
    erb :"pizzashoppen/index"
  end

  post '/pizzashoppen' do
    name = params['pizza_name']
    price = params['pizza_price']

    db.execute('INSERT INTO pizza (name, price) VALUES (?, ?)', [name, price])

    redirect '/pizzashoppen'
  end

  post '/pizza/:id/delete' do
    id = params['id']

    db.execute('DELETE FROM pizza WHERE id = ?', [id])

    redirect '/pizzashoppen'
  end

  get '/pizza/:id/edit' do
    id = params['id']
    @pizza = db.execute('SELECT * FROM pizza WHERE id = ?', [id]).first
    erb :"pizzashoppen/edit"
  end

  post '/pizza/:id' do
    id = params['id']
    name = params['pizza_name']
    price = params['pizza_price']

    db.execute('UPDATE pizza SET name = ?, price = ? WHERE id = ?', [name, price, id])

    redirect '/pizzashoppen'
  end

  get '/login' do
    erb(:"pizzashoppen/login")
  end

  post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]

    user = db.execute("SELECT *
            FROM users
            WHERE username = ?",
            request_username).first

    unless user
      ap "/login : Invalid username."
      status 401
      redirect "/login"
    end

    db_id = user["id"].to_i
    ap db_id
    db_password_hashed = user["password"].to_s

    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    if bcrypt_db_password == request_plain_password
      ap "/login : Logged in "
      session[:user_id] = db_id
      ap session[:user_id]
      redirect("/")
    else
      ap "/login : Invalid password."
      status 401
      redirect '/login'
    end
  end

  post '/logout' do
    ap "Logging out"
    session.clear
    redirect '/'
  end

  get '/signup' do
    erb(:"pizzashoppen/signup")
  end

  post '/signup' do
    request_username = params[:username]
    request_plain_password = params[:password]

    password_hashed = BCrypt::Password.create(request_plain_password)

    db.execute("INSERT INTO users (username, password) VALUES (?,?)", [request_username, password_hashed])

    user = db.execute("SELECT * FROM users WHERE username = ? AND password = ?", [request_username, password_hashed]).first
    db_id = user["id"].to_i
    session[:user_id] = db_id
    ap session[:user_id]
    ap "FUCK FUCK FUCK"

    redirect('/')


  end

end