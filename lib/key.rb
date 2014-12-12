module WebOfTrust
  class Key
    attr_reader :fingerprint, :id, :node_id

    def initialize(options, gateway)
      if options["data"]["uuid"]
        fingerprint = options.fetch("data").fetch("uuid").reverse
        @fingerprint = quads(fingerprint).join(" ")
        @id = quads(fingerprint).pop(2).join
      end

      @gateway = gateway
      @node_id = node_id_from_url(options.fetch("self"))
    end

    def ==(other)
      self.class == other.class &&
        node_id == other.node_id
    end

    def signed_uids
      signed_objects.select { |object| object.is_a?(Uid) }
    end

    def signed_people
      signed_uids.
        map(&:to_person).
        select(&:valid?).
        reject { |person| person.owns_key?(self) }
    end

    def signed_objects
      gateway.query(node_id) { |key| key.outgoing(:SIGNS) }
    end

    def owner_uid
      @owner_uid ||= gateway.query(node_id) { |key|
        key.outgoing(:PRIMARILY_IDENTIFIED_BY)
      }.select { |obj| obj.is_a?(Uid) }.first
    end

    def owner
      @owner ||= (owner_uid && owner_uid.to_person)
    end

    private

    attr_reader :gateway

    def quads(fingerprint)
      fingerprint.upcase.chars.each_slice(4).map(&:join)
    end

    def node_id_from_url(url)
      url.split("/").last.to_i
    end
  end
end
