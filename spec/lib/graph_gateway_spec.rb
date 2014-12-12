require "spec_helper"

describe WebOfTrust::GraphGateway do
  describe "#person" do
    it "can find Mike Burns" do
      mike = WebOfTrust::GraphGateway.new.person(34924)

      expect(mike.uids.first.name).to eq "Michael John Burns"
      expect(mike.uids.first.email).to eq "mburns@thoughtbot.com"
    end
  end

  describe "#key" do
    it "can find Mike's key" do
      key = WebOfTrust::GraphGateway.new.key(34869)

      expect(key.fingerprint).
        to eq "5FD8 2CE6 A646 3285 538F C3A5 3E67 61F7 2846 B014"
    end
  end

  describe "#people" do
    it "returns every person in the graph =(" do
      expect(WebOfTrust::GraphGateway.new.people.size).to eq 54
    end
  end
end
