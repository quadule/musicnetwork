require 'yaml'
require 'rubygems'
require 'graphviz'

class Graph
  # threshold is how many links an artist must have to be shown
  def initialize(artists, threshold)
    @artists = artists
    @threshold = threshold
    @counts = Hash.new { 0 }
    
    #calculate link counts
    @artists.each do |url, properties|
      properties[:friends].each do |friend|
        @counts[friend[0]] += 1
      end
    end
    
    @g = GraphViz.new(:G, :type => :digraph, :use => "dot")
    @g[:ratio] = 0.33
    
    @nodes = {}
  end
  
  def node(url, name)
    @g.add_node(url,
      :label => name,
      :shape => @artists[url] ? 'folder' : 'oval',
      :penwidth => @artists[url] ? 1 : 3
    )
  end
  
  def show_artist?(url)
    @counts[url] >= @threshold || (
      @artists[url] &&
      @artists[url][:friends].any? { |f| @counts[f[0]] >= @threshold }
    )
  end
  
  def render
    @artists.each do |url, properties|
      next unless show_artist?(url)
      @nodes[url] ||= node(url, properties[:name])
    end

    @artists.each do |url, properties|
      properties[:friends].each do |friend|
        if show_artist?(friend[0])
          @nodes[friend[0]] ||= node(friend[0], friend[1])
          @nodes[friend[0]][:fontsize] = 14.0 + 2*(@counts[friend[0]] || 0) unless @artists[friend[0]]
          @g.add_edge(@nodes[url], @nodes[friend[0]],
            :penwidth => @artists[friend[0]] ? 1 : @counts[friend[0]],
            :color => '#' + rand(256*256*256).to_s(16).rjust(6, '0'))
        end
      end if show_artist?(url)
    end
    
    @g.output(:png => 'graph.png')
  end
end

Graph.new(YAML.load(open('network.yml')), 4).render