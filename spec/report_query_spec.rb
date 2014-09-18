require_relative 'helpers/db'
require_relative '../src/report_query'

module ReportQuerySpec
  db = DbHelper.load_db('tmp/report_query.db')

  params = {
    'dimension' => 'sports',
    'metrics' => [
      { 'agg' => 'avg', 'column' => 'odd' },
      { 'agg' => 'sum', 'column' => 'stake' }
    ],
    'filters' => [
      {
        'name' => 'sports',
        'expression' => '1' # soccer
      }
    ],
    'segment' => {
      'scope' => 'followeds',
      'condition' => {
        'name' => 'follower',
        'expression' => '1'
      }
    },
    'sort' => {
      'column' => 'dimension_name',
      'order' => 'asc'
    }
  }

  ReportQuery::Query.new(db, params).print_debug
end
