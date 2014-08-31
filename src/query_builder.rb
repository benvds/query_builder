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

  def self.print_result_set(result_set)
    puts ""
    puts result_set.sql
    puts ""

    result_set.each do |row|
      puts row.inspect
    end

    puts ""
  end

  def self.qualified_column(column_name)
    table = 'picks'
    Sequel::SQL::QualifiedIdentifier.new(table, column_name)
  end

  def self.metric(function_name, column_name)
    Sequel::SQL::Function.new(function_name, qualified_column(column_name)).
      as("#{function_name}_#{column_name}")
  end

  sports = DB[:picks].
    select { |o| [
      o.count(o.picks__id).as('total'),
      o.sports__id.as('dimension_id'),
      o.sports__name.as('dimension_name'),
      metric('avg', 'odd'),
      metric('sum', 'stake')
    ]}.
    join(:leagues, id: :league_id).
    join(:sports, id: :sport_id).
    group(:sports__id)

  print_result_set(sports)

  leagues = DB[:picks].
    select { |o| [
      o.count(o.picks__id).as('total'),
      o.leagues__id.as('dimension_id'),
      o.leagues__name.as('dimension_name'),
      metric('avg', 'odd'),
      metric('sum', 'stake')
    ]}.
    join(:leagues, id: :league_id).
    group(:leagues__id)

  print_result_set(leagues)

  # params = {
  #   dimension: 'sports',
  #   metrics: [
  #     { agg: 'avg', column: 'odd' },
  #     { agg: 'sum', column: 'stake' }
  #   ]
  # }

end
