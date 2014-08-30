require 'bundler/setup'
Bundler.require(:default, :development)

require 'date'

module QueryBuilder
  DB_FILE = 'tmp/query_builder.db'

  if File.exists? DB_FILE
    DB = Sequel.sqlite(DB_FILE)
  else
    File.new(DB_FILE, 'w+')
    DB = Sequel.sqlite(DB_FILE)

    require_relative 'query_builder/create_schema'
    require_relative 'query_builder/seed'

    QueryBuilder::CreateSchema.run(DB)
    QueryBuilder::SeedDB.run(DB)
  end

  puts "picks count: #{ DB[:picks].count }"

  rs = DB[:picks].
    select {[ count(:picks__id), avg(:picks__odd), :sports__name ]}.
    join(:leagues, id: :league_id).
    join(:sports, id: :sport_id).
    group(:sports__id)

  puts rs.sql

  rs.each do |row|
    puts row.inspect
  end

  # params = {
  #   dimension: :sports,
  #   metrics: [:, :odd, :stake]
  # }

end
