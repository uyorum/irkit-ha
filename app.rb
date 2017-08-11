require 'sinatra'
require 'yaml'

devices = YAML.load_file('config/ir.yml')

get '/devices' do
  list = []
  devices.each do |device|
    list << device['name']
  end
  return list.to_json
end
