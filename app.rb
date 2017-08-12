require 'sinatra'
require 'sinatra/config_file'
require 'irkit'

environment = ENV['RACK_ENV'] || 'development'
config_file "config/#{environment}.yml"

get '/devices' do
  devices = []
  settings.devices.each do |device|
    devices << device['name']
  end
  devices.to_json
end

get '/devices/:name' do
  target_device = settings.devices.select {|device| device['name'] == params[:name]}.first
  if target_device
    return { name: target_device['name'] }.to_json
  else
    status 404
    return { message: 'device not found' }.to_json
  end
end

get '/devices/:name/commands' do
  target_device = settings.devices.select {|device| device['name'] == params[:name]}.first
  unless target_device
    status 404
    return { message: 'device not found' }.to_json
  end
  return (target_device['commands'] || [] ).keys.to_json
end

post '/devices/:name/exec' do
  payload = JSON.parse(request.body.read)
  target_device = settings.devices.select {|device| device['name'] == params[:name]}.first
  unless target_device
    status 404
    return { message: 'device not found' }.to_json
  end

  ir_json = target_device['commands'][payload['command']]
  unless ir_json
    status 400
    return { message: "unknown command" }.to_json
  end

  ir_data = IRKit::Response.new(JSON.parse(ir_json))
  irkit = IRKit::Device.new(address: target_device['address'])
  response = irkit.post_messages(ir_data)
  unless response.response.code == "200"
    status 500
    return { message: 'failed to execute command' }.to_json
  end

  return { message: 'executed command' }.to_json
end
