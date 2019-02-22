require './lib/hubspot_file_migration'

HubspotFileMigration::Documents.all.each do |document|
  next if document.deal.nil?

  file = HubspotFileMigration::File.create(document)
  deal = HubspotFileMigration::Deals.find_by_id(document.deal.id)

  puts "Associating file #{file.id} with deal #{deal.deal_id}"

  HubspotFileMigration::Engagement.create(file.id, deal.deal_id)
end