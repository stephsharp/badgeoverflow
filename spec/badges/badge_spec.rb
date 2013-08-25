require 'spec_helper'
require 'stack_exchange/badges'
require 'json'
require 'ostruct'

BADGES = {
  :Altruist => '{
    "badge_id": 222,
    "rank": "bronze",
    "name": "Altruist",
    "description": "First bounty you manually awarded on another person\'s question",
    "award_count": 3055,
    "badge_type": "named",
    "link": "http://stackoverflow.com/badges/222/altruist"
  }'
}

def parsed_badge_with_name(badge_name)
  JSON.parse(BADGES[badge_name])
end

include StackExchange

describe Badge do
  let(:badge_hash) { Hash.new }
  let(:user_id) { nil }
  let(:badge) { Badge.new(badge_hash, user_id) }

  context "when initialised with #{parsed_badge_with_name(:Altruist)}" do
    let(:badge_hash) { parsed_badge_with_name(:Altruist) }

    it "has badge_id 222" do
      expect(badge.badge_id).to eq 222
    end
    it "has rank bronze" do
      expect(badge.rank).to eq "bronze"
    end
    it "has name Altruist" do
      expect(badge.name).to eq "Altruist"
    end
    it "has description \"First bounty you manually awarded on another person's question\"" do
      expect(badge.description).to eq "First bounty you manually awarded on another person's question"
    end
    it "has award_count 3055" do
      expect(badge.award_count).to eq 3055
    end
    it "has badge_type named" do
      expect(badge.badge_type).to eq "named"
    end
    it "has link http://stackoverflow.com/badges/222/altruist" do
      expect(badge.link).to eq "http://stackoverflow.com/badges/222/altruist"
    end

    context "and user id 123" do
      let(:user_id) { 123 }

      it "has user_id 123" do
        expect(badge.user_id).to eq 123
      end
    end
  end

  describe "::new" do
    context "with a name that is a badge subclass (Foobar < Badge)" do
      class Foobar < Badge; end

      let(:badge_hash) { {"name" => "Foobar"} }

      specify { expect(badge).to be_kind_of Badge }
      specify { expect(badge).to be_kind_of Foobar }
    end

    context "with a name that is not a badge subclass (Gorbypuff < OpenStruct)" do
      class Gorbypuff < OpenStruct; end

      let(:badge_hash) { {"name" => "Gorbypuff"} }

      specify { expect(badge).to be_kind_of Badge }
      specify { expect(badge).not_to be_kind_of Gorbypuff }
    end

    context "with a name containing spaces" do
      class NameWithSpaces < Badge; end

      let(:badge_hash) { {"name" => "Name With Spaces"} }

      specify { expect(badge).to be_kind_of NameWithSpaces }
    end
  end
end
