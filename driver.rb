$LOAD_PATH.unshift(File.dirname(__FILE__))

require "web_of_trust"

gateway = WebOfTrust::GraphGateway.new
WebOfTrust::JsonExporter.new(gateway).to_file("export.json")
