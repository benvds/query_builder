module ReportQueryDB
  module Seed
    module SeedUsersAndRelationships

      def self.run(db)

        users = db[:users]
        relationships = db[:relationships]

        follows_two = users.insert username: 'FollowesTwo'
        follows_none = users.insert username: 'FollowesNone'
        followed_by_two = users.insert username: 'FollowedByTwo'
        followed_by_none = users.insert username: 'FollowedByNone'

        relationships.insert    followed_id: follows_none,
                                follower_id: follows_two
        relationships.insert    followed_id: followed_by_two,
                                follower_id: follows_two
        relationships.insert    followed_id: followed_by_two,
                                follower_id: followed_by_none
      end

    end
  end
end
