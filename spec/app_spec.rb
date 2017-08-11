require File.expand_path '../spec_helper.rb', __FILE__

RSpec.describe "My Sinatra Application" do
  describe "get /devices" do
    it "returns status 200" do
      get '/devices' do
        expect(last_response.status).to eq(200)
      end
    end

    it "returns list of device name" do
      get '/devices'
      expect(last_response.body).to eq(['livingroom', 'bedroom'].to_json)
    end
  end
end
