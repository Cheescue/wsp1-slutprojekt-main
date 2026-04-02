require 'debug'
require 'awesome_print'

class App < Sinatra::Base

  setup_development_features(self)

  def db
    return @db if @db

    @db = SQLite3::Database.new("db/sqlite.db")
    @db.results_as_hash = true
    @db
  end

  get '/' do
    redirect '/pizzashoppen'
  end

  get '/pizzashoppen' do
    @pizza = db.execute("SELECT * FROM pizza")
    ap @pizza
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

end