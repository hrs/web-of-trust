require "spec_helper"

describe WebOfTrust::Person do
  describe "#to_h" do
    it "returns a hash contains names and emails" do
      expect(mike.to_h[:names]).to include "Michael John Burns"
      expect(mike.to_h[:emails]).
        to include "mburns@thoughtbot.com", "mike@mike-burns.com"
    end
  end

  describe "#key_id" do
    it "returns the node_id of the person's key" do
      expect(mike.key_id).to eq 34869
    end
  end

  describe "#people_signed_by" do
    it "returns an array of people that have signed this person's uids" do
      expect(mike.people_signed_by).to include harry
    end

    it "doesn't return self" do
      expect(mike.people_signed_by).not_to include mike
    end
  end

  def mike
    @mike ||= WebOfTrust::GraphGateway.new.person(34924)
  end

  def harry
    @harry ||= WebOfTrust::GraphGateway.new.person(37069)
  end
end
