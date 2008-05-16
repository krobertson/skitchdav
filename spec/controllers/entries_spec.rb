require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Entries, "index action" do
  before(:each) do
    dispatch_to(Entries, :index)
  end
end