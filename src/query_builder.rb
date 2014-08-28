require 'byebug'
require 'date'
require 'sequel'
require_relative 'query_builder/create_schema'
require_relative 'query_builder/seed'

module QueryBuilder

  # DB = Sequel.sqlite('query_builder.db')
  DB = Sequel.sqlite

  QueryBuilder::CreateSchema.run(DB)
  QueryBuilder::SeedDB.run(DB)

  sports = DB[:sports]
  puts "Sports count: #{ sports.count }"
  puts "The average position is: #{ sports.avg(:position) }"

  picks = DB[:picks]
  puts "picks count: #{ picks.count }"
  puts "The average odd is: #{ picks.avg(:odd) }"

end
