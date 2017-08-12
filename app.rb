require 'sinatra'
require 'sinatra/config_file'
require 'hashie'
require 'irkit'

environment = ENV['RACK_ENV'] || 'development'
config_file "config/#{environment}.yml"

def symbolize_keys(hash)
  return nil unless hash
  hash.map{|k,v| [k.to_sym, v] }.to_h
end

all_devices = {}
settings.devices.each do |device|
  name = device['name'].to_sym
  new_entry = Hashie::Mash.new(
    name: name,
    api: IRKit::Device.new(address: device['address']),
    commands: symbolize_keys(device['commands']),
  )
  all_devices[name] = new_entry
end

before %r{/devices/([\w]+).*} do
  device_name = params[:captures].first.to_sym
  @target_device = all_devices[device_name]
  halt 404, { message: 'device not found' }.to_json unless @target_device
end

before '/devices/:device_name/exec' do
  command = params[:command].to_sym
  ir_json = @target_device.commands[command]
  halt 400, { message: "unknown command" }.to_json unless ir_json
  @ir_data = JSON.parse(ir_json)
end

get '/devices' do
  all_devices.keys.to_json
end

get '/devices/:device_name' do
  { name: @target_device.name }.to_json
end

get '/devices/:device_name/commands' do
  (@target_device.commands || {}).keys.to_json
end

post '/devices/:device_name/exec' do
  response = @target_device.api.post_messages(@ir_data)
  unless response.response.code == "200"
    halt 500, { message: 'failed to execute command' }.to_json
  end

  { message: 'executed command' }.to_json
end
