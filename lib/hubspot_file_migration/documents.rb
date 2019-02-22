module HubspotFileMigration
  class Documents
    def self.all
      return documents
    end

    def self.documents
      @@documents ||= begin
        documents = PipelineDeals::Document.all
        pagination = documents.pagination

        page = 1
        docs = []

        while page <= pagination['pages']
          docs += PipelineDeals::Document.find(:all, params: { page: page })
          page +=1
        end

        docs
      end
    end
  end
end