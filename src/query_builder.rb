require 'bundler/setup'
Bundler.require(:default, :development)

require 'date'
require_relative 'query_builder/create_schema'
require_relative 'query_builder/seed'

module QueryBuilder
  DB_FILE = 'tmp/query_builder.db'

  if File.exists? DB_FILE
    DB = Sequel.sqlite(DB_FILE)
  else
    File.new(DB_FILE, 'w+')
    DB = Sequel.sqlite(DB_FILE)
    QueryBuilder::CreateSchema.run(DB)
    QueryBuilder::SeedDB.run(DB)
  end

  sports = DB[:sports]
  puts "Sports count: #{ sports.count }"
  puts "The average position is: #{ sports.avg(:position) }"

  picks = DB[:picks]
  puts "picks count: #{ picks.count }"
  puts "The average odd is: #{ picks.avg(:odd) }"

end
