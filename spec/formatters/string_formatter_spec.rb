require 'spec_helper'
require 'helpers/string_formatter'

describe StringFormatter do
  describe "#truncate" do
    let(:string) { "" }
    let(:count) { 0 }
    let(:truncated_string) { string.truncate(count) }

    context "with the string \"Hello world\"" do
      let(:string) { "Hello world" }

      context "and a character limit of 5" do
        let(:count) { 5 }
        specify { expect(truncated_string).to eq "Hello..." }
      end

      context "and a character limit of 10" do
        let(:count) { 10 }
        specify { expect(truncated_string).to eq "Hello..." }
      end

      context "and a character limit of 11" do
        let(:count) { 11 }
        specify { expect(truncated_string).to eq "Hello world" }
      end
    end
  end
end
