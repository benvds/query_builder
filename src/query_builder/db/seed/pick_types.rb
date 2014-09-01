module QueryBuilder
  module SeedDB
    module SeedPickTypes

      def self.run(db)
        ptcs = db[:pick_type_categories]
        onextwo_id = SeedDB.id_for_name(ptcs, '1x2')
        ou_id = SeedDB.id_for_name(ptcs, 'over/under')
        h2h_id = SeedDB.id_for_name(ptcs, 'h2h')
        position_id = SeedDB.id_for_name(ptcs, 'position')

        pick_types = db[:pick_types]

        pick_types.insert   name: '1',
                            pick_type_category_id: onextwo_id,
                            position: 0
        pick_types.insert   name: '2',
                            pick_type_category_id: onextwo_id,
                            position: 1
        pick_types.insert   name: 'over',
                            pick_type_category_id: ou_id,
                            position: 0
        pick_types.insert   name: 'under',
                            pick_type_category_id: ou_id,
                            position: 1

        pick_types.insert   name: 'h2h',
                            pick_type_category_id: h2h_id,
                            position: 0
        pick_types.insert   name: 'winner',
                            pick_type_category_id: position_id,
                            position: 0
        pick_types.insert   name: 'top 3',
                            pick_type_category_id: position_id,
                            position: 1

      end

    end
  end
end
