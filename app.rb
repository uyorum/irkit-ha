require 'sinatra'
require 'sinatra/config_file'
require 'irkit'

environment = ENV['RACK_ENV'] || 'development'
config_file "config/#{environment}.yml"

before %r{/devices/([\w]+).*} do
  @target_device = settings.devices.select {|device| device['name'] == params[:captures].first}.first
  halt 404, { message: 'device not found' }.to_json unless @target_device
end

before '/devices/:device_name/exec' do
  ir_json = @target_device['commands'][params[:command]]
  halt 400, { message: "unknown command" }.to_json unless ir_json
  @ir_data = JSON.parse(ir_json)
end

get '/devices' do
  devices = []
  settings.devices.each do |device|
    devices << device['name']
  end
  devices.to_json
end

get '/devices/:device_name' do
  return { name: @target_device['name'] }.to_json
end

get '/devices/:device_name/commands' do
  return (@target_device['commands'] || [] ).keys.to_json
end

post '/devices/:device_name/exec' do
  irkit = IRKit::Device.new(address: @target_device['address'])
  response = irkit.post_messages(@ir_data)
  unless response.response.code == "200"
    status 500
    return { message: 'failed to execute command' }.to_json
  end

  return { message: 'executed command' }.to_json
end
