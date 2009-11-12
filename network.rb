require File.join(File.dirname(__FILE__), 'itunes')
require File.join(File.dirname(__FILE__), 'myspace')
require File.join(File.dirname(__FILE__), 'threadpool')
require 'yaml'

pool = ThreadPool.new(10)
artists = []
counts = Hash.new { 0 }

Itunes::Library.new.artists[0..2].each do |name|
  pool.execute do
    if artist = Myspace::User.find_artist(name)
      $stderr.puts "Found artist #{name} with #{artist.friends.size} friends"
      artists << artist
    else
      $stderr.puts "Artist #{name} not found"
    end
  end
end

pool.join

ignore_urls = ['http://www.myspace.com/aplaceformusic', 'http://www.myspace.com/tom'] +
              artists.map { |artist| artist.url }

url_graph = {}

artists.each do |artist|
  url_graph[artist.url] = {
    :name => artist.name,
    :friends => artist.friends.map { |friend| [friend.url, friend.name] }
  }
end

File.open('network.yml', 'w') do |io|
  YAML.dump(url_graph, io)
end