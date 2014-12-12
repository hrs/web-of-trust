require "spec_helper"

describe WebOfTrust::Uid do
  describe "#==" do
    it "works" do
      expect(mike).to eq mike
    end
  end

  describe "#signed_by" do
    it "returns an array of keys that signed this uid" do
      expect(mike.signed_by).to include harrys_key
    end
  end

  def mike
    WebOfTrust::GraphGateway.new.uid(34924)
  end

  def harrys_key
    WebOfTrust::GraphGateway.new.key(34880)
  end
end
