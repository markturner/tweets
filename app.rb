require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'json'

configure do
  # set user id (you can get yours here: http://www.idfromuser.com/)
  user = '552273'
  
  # feed url
  url = "https://twitter.com/statuses/user_timeline/#{user}.rss/"
  
  # get the feed
  @@feed = open(url)
end

get '/' do
  content_type 'application/json', :charset => 'utf-8'
  headers['Cache-Control'] = 'public, max-age=21600' # Cache for six hours
  
  array = []
  
  # use Nokogiri to parse the feed
  doc = Nokogiri::XML(@@feed)
  
  doc.search("item").each do |item|
    
    text = item.search("title").inner_html.sub("markturner: ", "")
    
    # filter out replies and RTs
    unless text[0] == '@'
      
      # push items to array
      array << {
        :title => text,
        :url => item.search("link").inner_html
      }
    end
  end
  
  # return first 5 items of array as json object
  array[0..4].to_json

end