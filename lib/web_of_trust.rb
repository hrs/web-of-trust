require "neography"
require "neo4j-cypher"
require "neo4j-cypher/neography"

require "pp"

Neography.configure do |config|
  config.protocol = "http://"
  config.server = "localhost"
  config.port = 7474
  config.directory = ""  # prefix this path with '/'
  config.cypher_path = "/cypher"
  # config.gremlin_path = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file = "neography.log"
  config.log_enabled = true
  config.slow_log_threshold = 0    # time in ms for query logging
  config.max_threads = 20
  config.authentication = nil  # 'basic' or 'digest'
  config.username = nil
  config.password = nil
  config.parser = MultiJsonParser
  config.http_send_timeout = 1200
  config.http_receive_timeout = 1200
  config.persistent = true
end

class Uid
  attr_reader :email, :name, :node_id

  def initialize(options, web)
    keywords = options.fetch("data").fetch("keywords")
    @name = keywords.match(keyword_regex)[:name]
    @email = keywords.match(keyword_regex)[:email]
    @node_id = node_id_from_url(options.fetch("self"))
    @web = web
  end

  def to_person
    web.person(node_id)
  end

  private

  attr_reader :web

  def keyword_regex
    /\A(?<name>.*)\s<(?<email>.*)>\z/x
  end

  def node_id_from_url(url)
    url.split("/").last.to_i
  end
end

class Person
  attr_reader :uids

  def initialize(uids, web)
    @uids = uids
    @web = web
  end

  def signed_keys_of
    key.signed_people
  end

  def key
    result = web.conn.execute_cypher(Neography::Node.new(web.conn.get_node(uids.first.node_id))) do |uid|
      uid.outgoing(:IDENTIFIES)
    end

    Key.new(result["data"].first.first, web)
  end

  def to_s
    uids.first.name
  end

  private

  attr_reader :web
end

class Key
  attr_reader :fingerprint, :id
  def initialize(options, web)
    fingerprint = options.fetch("data").fetch("uuid").reverse
    @fingerprint = quads(fingerprint).join(" ")
    @id = quads(fingerprint).pop(2).join
    @web = web
    @node_id = node_id_from_url(options.fetch("self"))
  end

  def signed_uids
    result = web.conn.execute_cypher(Neography::Node.new(web.conn.get_node(node_id))) do |key|
      key.outgoing(:SIGNS)
    end

    result["data"].flatten.select { |hash| hash["data"]["keywords"] }.map { |hash| Uid.new(hash, web) }
  end

  def signed_people
    signed_uids.map(&:to_person).uniq
  end

  private

  attr_reader :web, :node_id

  def quads(fingerprint)
    fingerprint.upcase.chars.each_slice(4).map(&:join)
  end

  def node_id_from_url(url)
    url.split("/").last.to_i
  end
end

class WebOfTrust
  attr_reader :conn

  def initialize
    @conn = Neography::Rest.new
  end

  def person(uid_node_id)
    initial_uid_node = Neography::Node.new(conn.get_node(uid_node_id))

    result = conn.execute_cypher(initial_uid_node) do |uid|
      uid.incoming(:PRIMARILY_IDENTIFIED_BY).incoming(:IDENTIFIES)
    end

    uids = result["data"].flatten.select { |hash| hash["data"]["keywords"] }.map { |hash| Uid.new(hash, self) }

    Person.new(uids, self)
  end

  def uids
    conn.get_nodes_labeled("UID")
  end

  def keys
    conn.get_nodes_labeled("PubKey")
  end

  def labels
    conn.list_labels
  end

  def people
    uids.map do |uid|
      Uid.new(uid, self)
    end
  end

  def people_nodes
    people.inject({}) do |map, person|
      map.merge(person.node_id => person)
    end
  end
end

# p @neo.list_node_indexes
# nodes = @neo.get_nodes([148143])

# nodes = @neo.get_nodes_labeled("UID")
# pp nodes.first.to_h
# p nodes.size

# johan = @conn.find_nodes_labeled("UID", "keywords" => "Johan Lundberg <lundberg@sunet.se>")
# p johan

# pp Neography::Rest.new.get_nodes_labeled("UAT").first


# WebOfTrust.new.person(34924)
# p WebOfTrust.new.key(34869)

web = WebOfTrust.new

# mike = web.person(34924)

# result = web.conn.execute_cypher(mike) do |me|
#   me.incoming(:PRIMARILY_IDENTIFIED_BY).outgoing(:SIGNS)
# end

# pp result["data"].flatten.select { |hash| hash["data"]["keywords"] }.map { |hash| Uid.new(hash) }

mike = web.person(34924)

mike.signed_keys_of
