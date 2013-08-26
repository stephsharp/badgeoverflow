require 'spec_helper'
require './jobs/unearned_badges'

describe UnearnedBadgesJob do
  let(:user_id) { 1 }
  let(:job) { UnearnedBadgesJob.new(user_id) }

  describe "#user_id" do
    context "when initialised to 123" do
      let(:user_id) { 123 }

      specify { expect(job.user_id).to eq 123 }
    end
  end
end
