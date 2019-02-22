module HubspotFileMigration
  class Engagement
    def initialize(file_id, deal_id)
      @file_id = file_id
      @deal_id = deal_id
    end

    def self.create(file_id, deal_id)
      new(file_id, deal_id).create!
    end

    def create!
      Hubspot::Engagement.create!({
        engagement: {
          type: 'NOTE'
        },
        attachments: [
          {
            id: @file_id
          }
        ],
        associations: {
          deal_ids: [
            @deal_id
          ]
        },
        metadata: {}
      })
    end
  end
end