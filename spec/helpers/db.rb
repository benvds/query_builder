require 'sequel'

module DbHelper
  def self.load_db(filename)
    if File.exists? filename
      db = Sequel.sqlite(filename)
    else
      require_relative '../../db/create_schema'
      require_relative '../../db/seed'

      File.new(filename, 'w+')
      db = Sequel.sqlite(filename)

      ReportQueryDB::CreateSchema.run(db)
      ReportQueryDB::Seed.run(db)
    end

    db
  end
end
