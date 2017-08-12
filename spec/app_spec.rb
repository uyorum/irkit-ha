require File.expand_path '../spec_helper.rb', __FILE__

RSpec.describe "Sinatra Application" do
  let(:all_device_name) { ['device1', 'device2'] }

  let(:irkit_device) { 'device1' }
  let(:irkit_commands) { ['command1', 'command2'] }

  let(:internet_api_device) { 'device2' }
  let(:internet_api_commands) { ['command3', 'command4'] }

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
        get "/devices/#{irkit_device}"
        expect(last_response.status).to eq(200)
      end

      it "returns the property of the device" do
        get "/devices/#{irkit_device}"
        expect(last_response.body).to eq({ name: irkit_device, type: 'irkit' }.to_json)
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
        get "/devices/#{irkit_device}/commands"
        expect(last_response.status).to eq(200)
      end

      it "returns the list of commands" do
        get "/devices/#{irkit_device}/commands"
        expect(last_response.body).to eq(irkit_commands.to_json)
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
      context "with type irkit" do
        let(:params) {{ command: irkit_commands.first }}

        it "returns status 200" do
          post "/devices/#{irkit_device}/exec", params
          expect(last_response.status).to eq(200)
        end

        it "returns the message" do
          post "/devices/#{irkit_device}/exec", params
          expect(last_response.body).to eq({ message: 'executed command' }.to_json)
        end
      end

      context "with type internet api" do
        let(:params) {{ command: internet_api_commands.first }}

        it "returns status 200" do
          post "/devices/#{internet_api_device}/exec", params
          expect(last_response.status).to eq(200)
        end

        it "returns the message" do
          post "/devices/#{internet_api_device}/exec", params
          expect(last_response.body).to eq({ message: 'executed command' }.to_json)
        end
      end
    end

    context "with invalid device name" do
      let(:params) {{ command: irkit_commands.first }}

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
        post "/devices/#{irkit_device}/exec", params
        expect(last_response.status).to eq(400)
      end

      it "returns the message" do
        post "/devices/#{irkit_device}/exec", params
        expect(last_response.body).to eq({ message: 'unknown command' }.to_json)
      end
    end

    context "if failed to issue request" do
      let(:params) {{ command: irkit_commands.first }}

      before :each do
        allow_any_instance_of(IRKit::Device)
          .to receive_message_chain(:post_messages, :response, :code).and_return("500")
      end

      it "returns status 500" do
        post "/devices/#{irkit_device}/exec", params
        expect(last_response.status).to eq(500)
      end

      it "returns the message" do
        post "/devices/#{irkit_device}/exec", params
        expect(last_response.body).to eq({ message: 'failed to execute command' }.to_json)
      end
    end

    context "with internet api client" do

    end
  end
end
