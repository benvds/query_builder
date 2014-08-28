require_relative 'seed/sports'
require_relative 'seed/leagues'
require_relative 'seed/pick_type_categories'
require_relative 'seed/pick_types'
require_relative 'seed/picks'

module QueryBuilder
  module SeedDB

    def self.id_for_name(ds, name)
      ds.select(:id).where(name: name).first![:id]
    end

    def self.run(db)
      QueryBuilder::SeedDB::SeedSports.run(db)
      QueryBuilder::SeedDB::SeedLeagues.run(db)
      QueryBuilder::SeedDB::SeedPickTypeCategories.run(db)
      QueryBuilder::SeedDB::SeedPickTypes.run(db)
      QueryBuilder::SeedDB::SeedPicks.run(db)
    end

  end
end
