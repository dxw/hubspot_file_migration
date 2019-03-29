require './lib/hubspot_file_migration'

documents = if ENV['RETRY'].nil?
  puts 'Getting all documents...'
  HubspotFileMigration::Documents.all
else
  puts 'Fetching documents from docs.csv'
  CSV.read('docs.csv', { headers: true }).map do |r|
    PipelineDeals::Document.find(r['Document ID'])
  end
end

failures = []
remaining_documents = nil

def generate_csv(filename, arr)
  CSV.open(filename, 'wb') do |csv|
    csv << ['Document ID', 'Document title']
    arr.each do |f|
      csv << [f.id, f.title]
    end
  end
end

documents.each_with_index do |document, index|
  next if document.deal.nil?

  deal = HubspotFileMigration::Deals.find_by_id(document.deal.id)

  next if deal.nil?

  if HubspotFileMigration::File.exists_for_deal?(deal.deal_id, document)
    puts "File #{document.attributes['title']} already exists for deal #{deal.deal_id} - skipping"
    next
  end

  file = HubspotFileMigration::File.create(document)

  if file
    puts "Associating file #{file.id} with deal #{deal.deal_id}"
    HubspotFileMigration::Engagement.create(file.id, deal.deal_id)
  else
    # Queue up to try again
    failures << document
  end

rescue => e
  generate_csv('docs.csv', documents[index..-1])
  puts 'Hit an error. Remaining documents are in docs.csv'
  raise e
end

generate_csv('failures.csv', failures)
puts "Documents uploaded. See `failures.csv` for a list of failed uploads."
