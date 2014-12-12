require "json"

module WebOfTrust
  class JsonExporter
    def initialize(gateway)
      @gateway = gateway
    end

    def export
      {
        people: people_hash,
        graph: graph_hash,
      }
    end

    def to_file(filename)
      File.open(filename, "w") do |f|
        f.puts(export.to_json)
      end
    end

    private

    attr_reader :gateway

    def people_hash
      gateway.people.inject({}) do |map, person|
        map.merge(person.key_id => person.to_h)
      end
    end

    def graph_hash
      gateway.people.inject({}) do |map, person|
        map.merge(
          person.key_id => {
            from: person.people_signed_by.map(&:key_id).uniq,
            to: person.signed_keys_of.map(&:key_id).uniq,
          }
        )
      end
    end
  end
end
