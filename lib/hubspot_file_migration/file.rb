module HubspotFileMigration
  class File
    attr_reader :id

    def initialize(document)
      @document = document
      url = @document.public_link
      @file = open(url)
    end

    def self.find(id)
      response = Faraday.new('http://api.hubapi.com').get("/filemanager/api/v2/files/#{id}?hapikey=#{ENV['HUBSPOT_API_KEY']}")
      JSON.parse(response.body)
    end

    def self.create(document)
      retries ||= 0
      file = new(document)
      file.upload!
      file
    rescue
      puts "Error uploading file. Retrying..."
      sleep retries * 5
      if (retries += 1) < 3
        retry
      else
        return nil
      end
    end

    def self.exists_for_deal?(deal_id, document)
      engagements = Hubspot::Engagement.find_by_association(deal_id, 'deal')
      notes = engagements.select { |e| e.engagement['type'] == 'NOTE' }
      file_ids = notes.map { |n| n.attachments.first['id'] }
      files = file_ids.map { |id| find(id) }
      files.select { |f| f['file_hash'] == document.etag }.present?
    end

    def upload!
      payload = { file: Faraday::UploadIO.new(@file, mime_type, @document.title) }
      response = connection.post("/filemanager/api/v2/files?hapikey=#{ENV['HUBSPOT_API_KEY']}", payload)
      @json = JSON.parse(response.body)
      @id = @json['objects'].first['id']
    end

    def mime_type
      MimeMagic.by_magic(@file).type
    end

    def connection
      Faraday.new('http://api.hubapi.com') do |f|
        f.request :multipart
        f.request :url_encoded
        f.adapter :net_http
      end
    end
  end
end