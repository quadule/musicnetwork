require 'rubygems'
require 'appscript'

module Itunes
  class Library
    def initialize
      @library = Appscript::app('iTunes').sources['Library']
    end
    
    def tracks
      @library.playlists['Music'].tracks
    end
    
    def artists
      tracks.artist.get.uniq
    end
  end
end