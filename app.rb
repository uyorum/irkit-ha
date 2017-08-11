require 'sinatra'
require 'sinatra/config_file'

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
    return {}.to_json
  end
end
