require "spec_helper"

describe WebOfTrust::JsonExporter do
  describe "#export" do
    it "exports the graph into a hash" do
      mike_key_id = 34869
      harry_key_id = 34880

      gateway = WebOfTrust::GraphGateway.new
      exporter = WebOfTrust::JsonExporter.new(gateway)

      hash = exporter.export

      expect(hash[:people].size).to eq 54
      expect(hash[:people]).to have_key(mike_key_id)
      expect(hash[:people][mike_key_id][:emails]).to include "mburns@thoughtbot.com"
      expect(hash[:people][mike_key_id][:names]).to include "Michael John Burns"
      # expect(hash[:people][mike_key_id][:fingerprint]).to include ""
      # expect(hash[:people][mike_key_id][:pub_key_id]).to include "25AE721B"

      expect(hash[:graph]).to have_key(mike_key_id)
      expect(hash[:graph][mike_key_id][:from]).to include harry_key_id
      expect(hash[:graph][mike_key_id][:to]).to include harry_key_id
    end
  end

  describe "#to_file" do
    it "dumps the exported json into a file" do
    end
  end
end
