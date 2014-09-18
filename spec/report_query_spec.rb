require 'minitest/autorun'
require_relative 'helpers/db'
require_relative '../src/report_query'

module ReportQuerySpec
  db = DbHelper.load_db('tmp/report_query.db')

  # params = {
  #   'dimension' => 'sports',
  #   'metrics' => [
  #     { 'agg' => 'avg', 'column' => 'odd' },
  #     { 'agg' => 'sum', 'column' => 'stake' }
  #   ],
  #   'filters' => [
  #     {
  #       'name' => 'sports',
  #       'expression' => '1' # soccer
  #     }
  #   ],
  #   'segment' => {
  #     'scope' => 'followeds',
  #     'condition' => {
  #       'name' => 'follower',
  #       'expression' => '1'
  #     }
  #   },
  #   'sort' => {
  #     'column' => 'dimension_name',
  #     'order' => 'asc'
  #   }
  # }
  #
  # ReportQuery::Query.new(db, params).print_debug

  describe ReportQuery::Query do
    it "returns all metrics" do
      params = {
        'dimension' => 'sports',
        'metrics' => [
          { 'agg' => 'avg', 'column' => 'stake' },
          { 'agg' => 'avg', 'column' => 'odd' },
          { 'agg' => 'avg', 'column' => 'stake_return' },
          { 'agg' => 'sum', 'column' => 'balance' }
        ]
      }

      result = ReportQuery::Query.new(db, params).dataset
      row = result.first

      row.has_key?(:avg_stake).must_equal true
      row.has_key?(:avg_odd).must_equal true
      row.has_key?(:avg_stake_return).must_equal true
      row.has_key?(:sum_balance).must_equal true
    end

    it "returns all dimension columns" do
      params = {
        'dimension' => 'sports',
        'metrics' => [
          { 'agg' => 'sum', 'column' => 'balance' }
        ]
      }

      result = ReportQuery::Query.new(db, params).dataset
      row = result.first

      row.has_key?(:total).must_equal true
      row.has_key?(:dimension_id).must_equal true
      row.has_key?(:dimension_name).must_equal true
    end

    it "accepts the sports dimension" do
      params = {
        'dimension' => 'sports',
        'metrics' => [
          { 'agg' => 'sum', 'column' => 'stake' }
        ]
      }

      result = ReportQuery::Query.new(db, params).dataset.all
      names = result.collect { |row| row.fetch(:dimension_name) }

      result.size.must_equal 2
      names.must_include 'soccer'
      names.must_include 'formula 1'
    end

    it "accepts the leagues dimension" do
      params = {
        'dimension' => 'leagues',
        'metrics' => [
          { 'agg' => 'sum', 'column' => 'stake' }
        ]
      }

      result = ReportQuery::Query.new(db, params).dataset.all
      names = result.collect { |row| row.fetch(:dimension_name) }

      result.size.must_equal 4
      names.must_equal ['eredivisie', 'jupiler league', 'qualification', 'race']
    end
  end
end
