require "neography"
require "neo4j-cypher"
require "neo4j-cypher/neography"

require "graph_gateway"
require "json_exporter"
require "key"
require "person"
require "uid"

Neography.configure do |config|
  config.protocol = "http://"
  config.server = "localhost"
  config.port = 7474
  config.directory = ""  # prefix this path with '/'
  config.cypher_path = "/cypher"
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

module WebOfTrust
end
