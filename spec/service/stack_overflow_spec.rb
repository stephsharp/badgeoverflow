require 'spec_helper'
require 'stack_exchange/service'

include StackExchange::Service

describe StackOverflow, '.fetch' do
  BASE_URL = "http://api.stackexchange.com/2.1"
  PARAMS = "site=stackoverflow"

  def url_with(resource)
    "#{BASE_URL}/#{resource}/?#{PARAMS}"
  end

  let(:resource) { :users }
  let(:body)     { "{}" }
  let(:endpoint) { url_with(resource) }

  before { stub_request(:get, endpoint).to_return(:body => body) }

  context "with no block given" do
    specify { expect { StackOverflow.fetch(resource) }.not_to raise_error }
  end

  describe "requests" do
    context "with :users resource" do
      let(:resource) { :users }

      it "hits /users/ endpoint" do
        StackOverflow.fetch(:users)
        a_request(:get, url_with("users")).should have_been_made
      end
    end

    context "with :badges resource" do
      let (:resource) { :badges }

      it "hits /badges/ endpoint" do
        StackOverflow.fetch(:badges)
        a_request(:get, url_with("badges")).should have_been_made
      end
    end
  end

  describe "responses" do
    context "with no 'items' key" do
      before { stub_request(:get, endpoint).to_return(:body => "{}") }

      specify { expect { |b| StackOverflow.fetch(resource, &b) }.to yield_with_args(nil) }
    end
  end
end
