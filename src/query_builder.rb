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

  def self.metric(function_name, column_name)
    Sequel::SQL::Function.new(function_name,
        Sequel::SQL::QualifiedIdentifier.new('picks', column_name)).
      as("#{function_name}_#{column_name}")
  end

  def self.dimension_columns(table_name)
    [
      Sequel::SQL::QualifiedIdentifier.new(table_name, 'id').as('dimension_id'),
      Sequel::SQL::QualifiedIdentifier.new(table_name, 'name').as('dimension_name')
    ]
  end

  def self.metric_columns
    [
      metric('avg', 'odd'),
      metric('sum', 'stake')
    ]
  end

  def self.apply_dimension(dataset, table_name)
    dataset.join(table_name, id: :league_id).
      group(Sequel::SQL::QualifiedIdentifier.new(table_name, 'id'))
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

  # print_result_set(sports)


  leagues = DB[:picks].
    select { |o| [
      o.count(o.picks__id).as('total')
    ] + dimension_columns('leagues') + metric_columns }

  print_result_set(apply_dimension(leagues, 'leagues'))

  # params = {
  #   dimension: 'sports',
  #   metrics: [
  #     { agg: 'avg', column: 'odd' },
  #     { agg: 'sum', column: 'stake' }
  #   ]
  # }

end
