module ReportQueryDB
  module Seed
    module SeedPickTypeCategories

      def self.run(db)
        sports = db[:sports]
        soccer_id = SeedDB.id_for_name(sports, 'soccer')
        formula_one_id = SeedDB.id_for_name(sports, 'formula 1')

        ptcs = db[:pick_type_categories]

        ptcs.insert name: '1x2',
                    sport_id: soccer_id,
                    position: 0
        ptcs.insert name: 'over/under',
                    sport_id: soccer_id,
                    position: 1

        ptcs.insert name: 'h2h',
                    sport_id: formula_one_id,
                    position: 0
        ptcs.insert name: 'position',
                    sport_id: formula_one_id,
                    position: 1

      end

    end
  end
end

