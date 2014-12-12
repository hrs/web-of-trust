module WebOfTrust
  class Person
    attr_reader :uids

    def initialize(uids, gateway)
      @uids = uids
      @gateway = gateway
    end

    def ==(other)
      self.class == other.class &&
        uids.map(&:node_id).sort == other.uids.map(&:node_id).sort
    end

    def signed_keys_of
      key.
        signed_people.
        reject { |person| person == self }.
        compact
    end

    def people_signed_by
      uids.
        map(&:signed_by).
        flatten.
        compact.
        uniq.
        map(&:owner).
        reject { |person| person == self }.
        compact
    end

    def owns_key?(key)
      uids.include?(key.owner_uid)
    end

    def key
      gateway.query(uids.first.node_id) do |uid|
        uid.outgoing(:IDENTIFIES)
      end.first
    end

    def key_id
      key.node_id
    end

    def to_s
      uids.first.name
    end

    def to_h
      {
        names: uids.map(&:name).uniq,
        emails: uids.map(&:email).uniq,
      }
    end

    def valid?
      !uids.empty?
    end

    private

    attr_reader :gateway
  end
end
