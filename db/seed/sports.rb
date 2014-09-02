module ReportQueryDB
  module Seed
    module SeedSports

      def self.run(db)
        sports = db[:sports]

        sports.insert name: 'soccer', position: 0
        sports.insert name: 'formula 1', position: 1
      end

    end
  end
end

