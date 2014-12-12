module WebOfTrust
  class GraphGateway
    attr_reader :conn

    def initialize
      @conn = Neography::Rest.new
    end

    def query(node_id, &block)
      results = conn.execute_cypher(node(node_id), &block)
      results["data"].flatten.map { |hash| objectify(hash) }
    end

    def objectify(hash)
      if hash["data"]["keywords"]
        Uid.new(hash, self)
      elsif hash["data"]["r_keyid"]
        Key.new(hash, self)
      end
    end

    def node(node_id)
      Neography::Node.new(conn.get_node(node_id))
    end

    def person(primary_node_id)
      uids = query(primary_node_id) do |uid|
        uid.incoming(:PRIMARILY_IDENTIFIED_BY).incoming(:IDENTIFIES)
      end.compact

      Person.new(uids, self)
    end

    def uid(node_id)
      objectify(conn.get_node(node_id))
    end

    def key(node_id)
      objectify(conn.get_node(node_id))
    end

    def uids
      conn.get_nodes_labeled("UID").map { |hash| objectify(hash) }
    end

    def keys
      conn.get_nodes_labeled("PubKey").map { |hash| objectify(hash) }
    end

    def people
      uids.map(&:to_person).select(&:valid?)
    end

    # def people_nodes
    #   people.inject({}) do |map, person|
    #     map.merge(person.node_id => person)
    #   end
    # end
  end
end
