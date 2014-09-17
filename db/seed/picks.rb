module ReportQueryDB
  module Seed
    module SeedPicks

      MAX_DAYS_AGO = 28
      MAX_STAKE = 10
      ODD_RANGE = 2.0
      ODD_BASE = 1
      ODD_ROUND = 2

      def self.run(db)

        picks = db[:picks]
        user_id = db[:users].first(username: 'FollowedByTwo').fetch(:id)

        db[:sports].each do |sport|
          db[:leagues].where(sport_id: sport[:id]).each do |league|
            db[:pick_types].
              join(:pick_type_categories, id: :pick_type_category_id).
              where(pick_type_categories__sport_id: sport[:id]).each do |pick_type|

              uid = "#{sport[:id]}-#{league[:id]}-#{pick_type[:id]}"
              picks.insert  user_id: user_id,
                            league_id: league[:id],
                            pick_type_id: pick_type[:id],
                            match: "match: #{uid}",
                            pick: "pick: #{uid}",
                            start_at: DateTime.now - rand(MAX_DAYS_AGO),
                            stake: rand(MAX_STAKE),
                            odd: (Random.rand(ODD_RANGE) +
                                  ODD_BASE).round(ODD_ROUND),
                            created_at: DateTime.now,
                            updated_at: DateTime.now
            end
          end
        end

      end

    end
  end
end
