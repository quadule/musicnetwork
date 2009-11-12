require 'rubygems'
require 'nokogiri'
require 'cgi'

# load these before openuri does
require 'net/http'
require 'tempfile'

require 'open-uri'

module Myspace
  URLS = {}
  
  class User
    attr_reader :url
    
    def initialize(url, username=nil)
      @url = url
      @name = username || self.name
      URLS[@url] = @name
    end
    
    def self.find_artist(name)
      doc = Nokogiri::HTML(open("http://searchservice.myspace.com/index.cfm?fuseaction=sitesearch.results&qry=#{CGI.escape(name)}&type=Music&musictype=2").read)
      artist = doc.css('.artistSearchResult .artistInfo a')[0]
      return self.new(artist[:href], name) if artist
      nil
    end
    
    def doc
      @doc ||= Nokogiri::HTML(open(@url).read)
    end
    
    def name
      @name ||= doc.css('title').text[/\s+(.*) on MySpace/, 1]
    end
    
    def artist?
      doc.css('#musicJVNav').size > 0
    end
    
    def friends
      @friends ||= doc.css('table.friendSpace table table table tr:eq(1) a').map do |link|
        self.class.new(link[:href], link.text)
      end
    end
    
    def artist_friends
      @artist_friends ||= friends.reject { |user| !user.artist? }
    end
  end
end