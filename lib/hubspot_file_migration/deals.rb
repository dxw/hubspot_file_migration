module HubspotFileMigration
  class Deals
    def self.all
      return deals
    end

    def self.find_by_id(id)
      deals.find { |d| d.properties['pipeline_deals_deal_id'].to_i == id.to_i }
    end

    def self.deals
      @@deals ||= begin
        hasMore = true
        offset = nil
        deals = []

        while hasMore == true
          hubspot_deals = Hubspot::Deal.all(properties: 'pipeline_deals_deal_id', offset: offset)
          deals += hubspot_deals['deals']
          hasMore = hubspot_deals['hasMore']
          offset = hubspot_deals['offset']
        end

        deals
      end
    end
  end
end