module ReportQueryDB
  module Seed
    module SeedLeagues

      def self.run(db)
        sports = db[:sports]
        soccer_id = SeedDB.id_for_name(sports, 'soccer')
        formula_one_id = SeedDB.id_for_name(sports, 'formula 1')

        leagues = db[:leagues]

        leagues.insert  name: 'eredivisie',
                        sport_id: soccer_id,
                        position: 0
        leagues.insert  name: 'jupiler league',
                        sport_id: soccer_id,
                        position: 1

        leagues.insert  name: 'qualification',
                        sport_id: formula_one_id,
                        position: 0
        leagues.insert  name: 'race',
                        sport_id: formula_one_id,
                        position: 1
      end

    end
  end
end


