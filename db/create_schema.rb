module ReportQueryDB
  module CreateSchema
    def self.run(db)
      db.create_table :users do
        primary_key   :id
        String        :username
        String        :role, default: 'user'
      end

      db.create_table :relationships do
        Integer       :followed_id
        Integer       :follower_id
        String        :state

        index [:followed_id, :follower_id, :state], unique: true
      end

      db.create_table :sports do
        primary_key   :id
        String        :name
        Integer       :position
      end

      db.create_table :leagues do
        primary_key   :id
        foreign_key   :sport_id, :sports
        String        :name
        Integer       :position
      end

      db.create_table :pick_type_categories do
        primary_key   :id
        foreign_key   :sport_id, :sports
        String        :name
        Integer       :position
      end

      db.create_table :pick_types do
        primary_key   :id
        foreign_key   :pick_type_category_id, :pick_type_categories
        String        :name
        Integer       :position
      end

      db.create_table :picks do
        primary_key   :id
        foreign_key   :user_id, :users
        foreign_key   :league_id, :leagues
        foreign_key   :pick_type_id, :pick_types

        String        :match
        String        :pick

        DateTime      :start_at
        Integer       :stake
        Float         :odd
        Integer       :result

        Float         :stake_return
        Float         :balance

        DateTime      :created_at
        DateTime      :updated_at
      end
    end
  end
end
