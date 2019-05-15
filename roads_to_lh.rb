# Ruby script to extract GPX route from french cities to LH
# Powered by GraphHopper API : https://graphhopper.com/#directions-api

require 'csv'
require 'curb'
require 'time'

EXPORT_DIR = '/path/to/export/dir/'
CSV_FILE = '/path/to/communes.csv'

API_KEY = '[YOUR_KEY]'

LON_LH = '0.138937657676938'
LAT_LH = '49.495262935885'

URL = 'https://graphhopper.com/api/1/route?point='
COORDINATE = '&point=' + LAT_LH + ',' + LON_LH + '&vehicle=car&debug=true&key='
GPX_FORMAT = '&instructions=false&type=gpx&gpx.route=false'

CSV.foreach(CSV_FILE) do |row|
  filename = ''
  filename = EXPORT_DIR + row[0].to_s + '_' + row[1].to_s + '.gpx'

  if not File.exist?(filename)

    url = URL + row[3] + ',' + row[2] +  COORDINATE + API_KEY  + GPX_FORMAT

    tries = 3
    begin
      curl = Curl::Easy.perform(url)
      puts 'GET ' + url

      if !curl.nil?
        if curl.body_str.empty?
          File.open('gpx.log', 'a') { |log| log.puts Time.now.iso8601 + ' EMPTY FILE ' + filename + ' ' + url }
          puts 'EMPTY FILE ' + filename
        elsif curl.body_str.include? 'Bad'
          File.open('gpx.log','a') { |log| log.puts Time.now.iso8601 + ' BAD REQUEST ' + filename + ' ' + url }
          puts 'BAD REQUEST ' + url
        else
          puts 'WRITE FILE ' + filename
          File.open(filename , 'w') { |file|   file.write(curl.body_str) }
          File.open('gpx.log', 'a') { |log| log.puts Time.now.iso8601 + ' OK ' + filename + ' ' + url }
        end
        puts 'SLEEP'
        sleep 6 # number of request is limited by day
        puts 'WAKE UP'
      end

    rescue
      sleep 2
      retry unless (tries -= 1).zero?
    else
      File.open('gpx.exception.log', 'a') do |f|
        f.puts filename
        f.puts url
        f.puts '---'
      end
    end
  end
end


File.open('gpx.log', 'a') do |log|
  log.puts 'FINISH AT ' + Time.now.iso8601
end
