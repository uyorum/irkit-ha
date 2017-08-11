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

  describe "get /devices/:device" do
    context "with valid device name" do
      it "returns status 200" do
        get '/devices/livingroom'
        expect(last_response.status).to eq(200)
      end

      it "returns the property of the device" do
        get '/devices/livingroom'
        expect(last_response.body).to eq({name: 'livingroom'}.to_json)
      end
    end

    context "with invalid device name" do
      it "returns status 404" do
        get '/devices/invalid_name'
        expect(last_response.status).to eq(404)
      end

      it "returns the empty json" do
        get '/devices/invalid_name'
        expect(last_response.body).to eq({}.to_json)
      end
    end
  end
end
