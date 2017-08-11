require 'sinatra'
require 'sinatra/config_file'

environment = ENV['RACK_ENV'] || 'development'
config_file "config/#{environment}.yml"

get '/devices' do
  devices = []
  settings.devices.each do |device|
    devices << device['name']
  end
  return devices.to_json
end
end
