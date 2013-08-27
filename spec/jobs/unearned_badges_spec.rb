require 'spec_helper'
require './jobs/unearned_badges'

describe UnearnedBadgesJob do
  let(:user_id) { 1 }
  let(:job) { UnearnedBadgesJob.new(user_id) }

  describe "::run" do
    let(:job) { double('job') }

    it "instantiates a job with the supplied arguments" do
      job.stub(:run)

      UnearnedBadgesJob.stub(:new) do |*args|
        expect(args).to eq [123]
        job
      end

      UnearnedBadgesJob.run(123)
    end
  end

  describe "#user_id" do
    context "when initialised to 123" do
      let(:user_id) { 123 }

      specify { expect(job.user_id).to eq 123 }
    end
  end

  describe "#service" do
    let(:service) { job.service }

    specify { expect(service).to be_kind_of StackExchangeService }
    specify { expect(service.site).to eq 'stackoverflow' }
    specify { expect(service.api_version).to eq 2.1 }
  end
end
