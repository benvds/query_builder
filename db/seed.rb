require_relative 'seed/users_and_relationships'
require_relative 'seed/sports'
require_relative 'seed/leagues'
require_relative 'seed/pick_type_categories'
require_relative 'seed/pick_types'
require_relative 'seed/picks'

module ReportQueryDB
  module Seed

    def self.id_for_name(ds, name)
      ds.select(:id).where(name: name).first![:id]
    end

    def self.run(db)
      ReportQueryDB::Seed::SeedUsersAndRelationships.run(db)
      ReportQueryDB::Seed::SeedSports.run(db)
      ReportQueryDB::Seed::SeedLeagues.run(db)
      ReportQueryDB::Seed::SeedPickTypeCategories.run(db)
      ReportQueryDB::Seed::SeedPickTypes.run(db)
      ReportQueryDB::Seed::SeedPicks.run(db)
    end

  end
end
