require 'bundler/setup'
Bundler.require(:default, :development)

require 'date'

# TODO this file is more of a spec helper

require_relative 'query_builder/db/db'
require_relative 'query_builder/query'

module QueryBuilder
  DATABASE = QueryBuilder::DB.load_db('tmp/query_builder.db')

  params = {
    'dimension' => 'sports',
    'metrics' => [
      { 'agg' => 'avg', 'column' => 'odd' },
      { 'agg' => 'sum', 'column' => 'stake' }
    ],
    'filters' => [
      {
        'table' => 'sports',
        'column' => 'id',
        'value' => '1' # soccer
      }
    ],
    'sort' => {
      'column' => 'dimension_name',
      'order' => 'asc'
    }
  }

  ReportQuery.new(params).print_debug

end
