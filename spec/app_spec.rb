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

  describe "get /devices/:name" do
    context "with valid device name" do
      it "returns status 200" do
        get '/devices/livingroom'
        expect(last_response.status).to eq(200)
      end

      it "returns the property of the device" do
        get '/devices/livingroom'
        expect(last_response.body).to eq({ name: 'livingroom' }.to_json)
      end
    end

    context "with invalid device name" do
      it "returns status 404" do
        get '/devices/invalid_name'
        expect(last_response.status).to eq(404)
      end

      it "returns the error message" do
        get '/devices/invalid_name'
        expect(last_response.body).to eq({ message: 'device not found' }.to_json)
      end
    end
  end

  describe "get /devices/:name/commands" do
    context "with valid device name" do
      it "returns status 200" do
        get '/devices/livingroom/commands'
        expect(last_response.status).to eq(200)
      end

      it "returns the list of commands" do
        get '/devices/livingroom/commands'
        expect(last_response.body).to eq(['command1', 'command2'].to_json)
      end
    end

    context "with invalid device name" do
      it "returns status 404" do
        get '/devices/invalid_name/commands'
        expect(last_response.status).to eq(404)
      end

      it "returns the error message" do
        get '/devices/invalid_name/commands'
        expect(last_response.body).to eq({ message: 'device not found' }.to_json)
      end
    end
  end

  describe "post /devices/:name/exec" do
    context "with valid request", vcr: true do
      let(:params) {{ command: 'command1' }}

      it "returns status 200" do
        post '/devices/livingroom/exec', params
        expect(last_response.status).to eq(200)
      end

      it "returns the message" do
        post '/devices/livingroom/exec', params
        expect(last_response.body).to eq({ message: 'executed command' }.to_json)
      end
    end

    context "with undefined command" do
      let(:params) {{ command: 'invalid_command' }}

      it "returns status 400" do
        post '/devices/livingroom/exec', params
        expect(last_response.status).to eq(400)
      end

      it "returns the message" do
        post '/devices/livingroom/exec', params
        expect(last_response.body).to eq({ message: 'unknown command' }.to_json)
      end
    end

    context "if failed to issue request" do
      let(:params) {{ command: 'command1' }}

      before :each do
        allow_any_instance_of(IRKit::Device)
          .to receive_message_chain(:post_messages, :response, :code).and_return("500")
      end

      it "returns status 500" do
        post '/devices/livingroom/exec', params
        expect(last_response.status).to eq(500)
      end

      it "returns the message" do
        post '/devices/livingroom/exec', params
        expect(last_response.body).to eq({ message: 'failed to execute command' }.to_json)
      end
    end
  end
end
