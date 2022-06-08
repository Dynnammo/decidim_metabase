# frozen_string_literal: true

module DecidimMetabase
  # HttpRequests contains HTTP queries to work with Metabase
  class QueryInterpreter
    def self.interpreter!(configs, card, cards)
      query = interpret_host(card.query, configs["host"])

      card.dependencies.each do |dep|
        query = interpret(query, cards, dep)
      end

      query
    end

    def self.interpret_host(query, host)
      return query unless interpret_host?(query)

      query.gsub!("$HOST", "'#{host}'")
    end

    def self.interpret_host?(query)
      query.match?(/\$HOST/)
    end

    def self.interpret?(query, key)
      query.include?("{{##{key}}}")
    end

    def self.interpret(query, cards, key)
      return query unless interpret?(query, key)

      target = find_card_by(key, cards)
      unless target.respond_to?(:id) && target&.id.is_a?(Integer)
        puts "ID not found"
        return query
      end

      query.gsub!("{{##{key}}}", "{{##{target&.id}}}")
    end


    def self.find_card_by(name, cards)
      found = cards.select { |card| card.name == name }
      return found.first if found.count == 1

      found.select { |elem| elem.instance_of?(DecidimMetabase::Object::Card) }.first
    end
  end
end