require_relative 'spec_helper'
require 'service/stack_overflow'

include Service

describe StackOverflow, '.fetch' do
  describe "responses" do
    let(:endpoint) { "http://api.stackexchange.com/2.1/#{resource}/?site=stackoverflow" }
    let(:resource) { :users }
    let(:body) { nil }

    before { stub_request(:get, endpoint).to_return(:body => body) }

    context "with no 'items' key" do\
      let(:body) { "{}" }

      specify { expect { |b| StackOverflow.fetch(resource, &b) }.to yield_with_args(nil) }
    end
  end
end
