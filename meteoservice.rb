require 'net/http'
require 'rexml/document'
require 'json'
include REXML

require_relative 'lib/forecast'

file = File.read(File.join(__dir__, 'data', 'cities.json'))

data_hash = JSON.parse(file).invert

city_names = data_hash.keys

puts 'Погоду для какого города Вы хотите узнать?'
city_names.each_with_index { |name, index| puts "#{index + 1}: #{name}" }
city_index = gets.to_i
until city_index.between?(1, city_names.size)
  city_index = gets.to_i
  puts "Введите число от 1 до #{city_names.size}"
end

city_id = data_hash[city_names[city_index - 1]]

URL = "https://www.meteoservice.ru/en/export/gismeteo?point=#{city_id}".freeze

response = Net::HTTP.get_response(URI.parse(URL))
doc = REXML::Document.new(response.body)

city_name = URI.decode_www_form_component(doc.root.elements['REPORT/TOWN'].attributes['sname'])

forecast_nodes = XPath.match(doc, '//FORECAST')

puts city_name
puts

forecast_nodes.each do |node|
  puts MeteoServiceForecast.from_xml(node)
  puts
end
