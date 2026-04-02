require 'sqlite3'
require_relative '../config'

class Seeder

  def self.seed!
    puts "Using db file: #{DB_PATH}"
    puts "🧹 Dropping old tables..."
    drop_tables
    puts "🧱 Creating tables..."
    create_tables
    puts "🍎 Populating tables..."
    populate_tables
    puts "✅ Done seeding the database!"
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS pizza')
  end

  def self.create_tables
    db.execute('CREATE TABLE pizza (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category_id INTEGER,
                description TEXT)')
  end

  def self.populate_tables
    db.execute('INSERT INTO pizza (name, price) VALUES ("Kebab Pizza", "5")')
    db.execute('INSERT INTO pizza (name, price) VALUES ("Margarita", "5")')
    db.execute('INSERT INTO pizza (name, price) VALUES ("Vesuvio", "3")')
    db.execute('INSERT INTO pizza (name, price) VALUES ("Alex Special", "5")')
  end

  private

  def self.db
    @db ||= begin
      db = SQLite3::Database.new(DB_PATH)
      db.results_as_hash = true
      db
    end
  end

end

Seeder.seed!