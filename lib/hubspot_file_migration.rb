require 'dotenv'
Dotenv.load

require 'open-uri'
require 'mimemagic'
require 'faraday'

require 'pipeline_deals'
require 'hubspot-ruby'

require_relative 'hubspot_file_migration/deals'
require_relative 'hubspot_file_migration/engagement'
require_relative 'hubspot_file_migration/file'
require_relative 'hubspot_file_migration/documents'

PipelineDeals.configure do |config|
  config.api_key = ENV['PIPELINE_DEALS_API_KEY']
end

Hubspot.configure({hapikey: ENV['HUBSPOT_API_KEY']})

module HubspotFileMigration
end