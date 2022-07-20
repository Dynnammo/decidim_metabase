# frozen_string_literal: true

module DecidimMetabase
  module Api
    # CollectionNotFound raise when collection was not found in Metabase
    class CollectionNotFound < DecidimMetabase::Api::ResponseError
      def initialize(response = nil, msg = "Collection is not present")
        super(response, msg)
      end
    end

    # Defines Metabase Collection
    class Collection < Api
      def collections
        request = @http_request.get("/api/collection")
        body = JSON.parse(request.body)

        @collections = body
      end

      def related_cards(collection_name)
        collection_id = find_by(collection_name)["id"]
        request = @http_request.get("/api/collection/#{collection_id}/items", { "models" => ["card"] })
        JSON.parse(request.body)
      end

      def create_collection!(name)
        request = @http_request.post("/api/collection", {
                                       name: name,
                                       color: "#509AA3",
                                       parent_id: nil,
                                       namespace: nil,
                                       authority_level: nil
                                     })

        json = JSON.parse(request.body)

        puts "Collection ID/#{json["id"]} successfully created".colorize(:green)

        json
      end

      # Find a unique collection from available collections
      def find_by(name = "")
        return if name == "" || name.nil?

        collections&.select { |coll| name == coll["name"] }&.first
      end

      # Find existing collection or create it if not exists
      def find_or_create!(name)
        found = find_by name

        unless found.nil? || found.empty?
          puts "Collection '#{name}' is already existing".colorize(:yellow)
          return found
        end

        puts "Creating collection '#{name}'...".colorize(:green)
        create_collection!(name)
      end
    end
  end
end
