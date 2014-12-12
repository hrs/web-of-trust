module WebOfTrust
  class Uid
    attr_reader :email, :name, :node_id

    def initialize(options, gateway)
      keywords = options.fetch("data").fetch("keywords")
      @name = keywords.match(keyword_regex)[:name]
      @email = keywords.match(keyword_regex)[:email]
      @node_id = node_id_from_url(options.fetch("self"))
      @gateway = gateway
    end

    def to_person
      gateway.person(node_id)
    end

    def signed_by
      gateway.query(node_id) do |uid|
        uid.incoming(:SIGNS)
      end
    end

    def ==(other)
      self.class == other.class &&
        node_id == other.node_id
    end

    private

    attr_reader :gateway

    def keyword_regex
      /\A(?<name>.*)\s<(?<email>.*)>\z/x
    end

    def node_id_from_url(url)
      url.split("/").last.to_i
    end
  end
end
