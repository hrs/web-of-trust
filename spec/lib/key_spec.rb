require "spec_helper"

describe WebOfTrust::Key do
  describe "#signed_uids" do
    it "returns a list of uids signed by the key" do
      expect(key.signed_uids).not_to include nil

      key.signed_uids.each do |uid|
        expect(uid.class).to be WebOfTrust::Uid
      end
    end
  end

  describe "#signed_people" do
    it "returns a list of people associated with the uids signed by the key" do
      expect(key.signed_people).not_to include nil

      key.signed_people.each do |person|
        expect(person.class).to be WebOfTrust::Person
        expect(person.uids).not_to be_empty
      end
    end

    it "doesn't include self" do
      key.signed_people.each do |person|
        expect(person.uids).not_to include key.owner_uid
      end
      # Person == Person?
    end
  end

  describe "#owner_uid" do
    it "returns Mike Burns" do
      expect(key.owner_uid.name).to eq "Michael John Burns"
    end
  end

  def key
    @key ||= WebOfTrust::GraphGateway.new.key(34869)
  end
end
