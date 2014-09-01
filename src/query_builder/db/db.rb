module QueryBuilder
  module DB

    def self.load_db(filename)
      if File.exists? filename
        db = Sequel.sqlite(filename)
      else
        File.new(filename, 'w+')
        db = Sequel.sqlite(filename)

        require_relative 'create_schema'
        require_relative 'seed'

        QueryBuilder::CreateSchema.run(db)
        QueryBuilder::SeedDB.run(db)
      end

      db
    end

  end
end
