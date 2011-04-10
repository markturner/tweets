require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
require 'hpricot'
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
  headers['Cache-Control'] = 'public, max-age=21600' # Cache for six hours
  
  array = []
  
  # use Hpricot to parse the feed
  doc = Hpricot.parse(@@feed)
  
  (doc/:item).each do |item|
    
    text = item.search("/title").inner_html
    
    # filter out replies and RTs
    unless text.include?("@")
      
      # push items to array
      array << {
        :title => text.sub("markturner: ", ""),
        :url => item.search("/guid").inner_html
      }
    end
  end
  
  # return first 5 items of array as json object
  array[0..4].to_json

end