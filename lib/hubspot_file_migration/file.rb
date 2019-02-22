module HubspotFileMigration
  class File
    attr_reader :id

    def initialize(document)
      @document = document
      url = @document.public_link
      @file = open(url)
    end

    def self.create(document)
      file = new(document)
      file.upload!
      file
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