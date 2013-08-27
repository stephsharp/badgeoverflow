require 'spec_helper'
require 'stack_exchange/service'

include StackExchange::Service

describe StackOverflow, '.fetch' do
  BASE_URL = "http://api.stackexchange.com/2.1"
  PARAMS = { site: "stackoverflow", page: 1, pagesize: 30 }

  def url_with(resource, params = nil)
    params ||= Hash.new
    "#{BASE_URL}/#{resource}/?#{PARAMS.merge(params).map{|k,v|"#{k}=#{v}"}.join('&')}"
  end

  let(:resource) { :users }
  let(:body)     { '{"has_more": false}' }
  let(:params)   { nil }
  let(:endpoint) { url_with(resource,params) }

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
      before { stub_request(:get, endpoint).to_return(:body => '{"has_more": false}') }

      specify { expect { |b| StackOverflow.fetch(resource, &b) }.to yield_with_args(nil) }
    end

    context "with 2 pages" do
      let(:first_page_body)  { '{"items":[{"foo":"bar"}],"has_more": true}' }
      let(:second_page_body) { '{"items":[{"baz":"quux"}],"has_more": false}' }

      before do
        stub_request(:get, url_with(:badges, :page => 1)).to_return(:body => first_page_body)
        stub_request(:get, url_with(:badges, :page => 2)).to_return(:body => second_page_body)
      end

      it "requests page 2" do
        StackOverflow.fetch(:badges)
        a_request(:get, url_with(:badges, :page => 2)).should have_been_made
      end

      it "yields the concatenated array of items" do
        expected_args = [{"foo"=>"bar"},{"baz"=>"quux"}]
        expect { |b| StackOverflow.fetch(:badges, &b) }.to yield_with_args expected_args
      end
    end
  end
end
