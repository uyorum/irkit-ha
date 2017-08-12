require File.expand_path '../spec_helper.rb', __FILE__

RSpec.describe "Sinatra Application" do
  let(:all_device_name) { ['device1', 'device2'] }
  let(:commands_of_first_device) { ['command1', 'command2'] }

  describe "get /devices" do
    it "returns status 200" do
      get '/devices'
      expect(last_response.status).to eq(200)
    end

    it "returns list of device name" do
      get '/devices'
      expect(last_response.body).to eq(all_device_name.to_json)
    end
  end

  describe "get /devices/:device_name" do
    context "with valid device name" do
      it "returns status 200" do
        get "/devices/#{all_device_name.first}"
        expect(last_response.status).to eq(200)
      end

      it "returns the property of the device" do
        get "/devices/#{all_device_name.first}"
        expect(last_response.body).to eq({ name: all_device_name.first }.to_json)
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

  describe "get /devices/:device_name/commands" do
    context "with valid device name" do
      it "returns status 200" do
        get "/devices/#{all_device_name.first}/commands"
        expect(last_response.status).to eq(200)
      end

      it "returns the list of commands" do
        get "/devices/#{all_device_name.first}/commands"
        expect(last_response.body).to eq(commands_of_first_device.to_json)
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

  describe "post /devices/:device_name/exec" do
    context "with valid request", vcr: true do
      let(:params) {{ command: commands_of_first_device.first }}

      it "returns status 200" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.status).to eq(200)
      end

      it "returns the message" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.body).to eq({ message: 'executed command' }.to_json)
      end
    end

    context "with invalid device name" do
      let(:params) {{ command: commands_of_first_device.first }}

      it "returns status 404" do
        get '/devices/invalid_name/exec', params
        expect(last_response.status).to eq(404)
      end

      it "returns the error message" do
        get '/devices/invalid_name/exec', params
        expect(last_response.body).to eq({ message: 'device not found' }.to_json)
      end
    end

    context "with undefined command" do
      let(:params) {{ command: 'invalid_command' }}

      it "returns status 400" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.status).to eq(400)
      end

      it "returns the message" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.body).to eq({ message: 'unknown command' }.to_json)
      end
    end

    context "if failed to issue request" do
      let(:params) {{ command: commands_of_first_device.first }}

      before :each do
        allow_any_instance_of(IRKit::Device)
          .to receive_message_chain(:post_messages, :response, :code).and_return("500")
      end

      it "returns status 500" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.status).to eq(500)
      end

      it "returns the message" do
        post "/devices/#{all_device_name.first}/exec", params
        expect(last_response.body).to eq({ message: 'failed to execute command' }.to_json)
      end
    end
  end
end
