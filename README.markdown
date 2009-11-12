musicnetwork is a set of scripts to visualize the social connections between
the bands you listen to and the bands they themselves associate with. It
connects to iTunes to get a list of every artist in your library, then visits
each artist's Myspace page to see who they count as a top friend.

Here's a bit of the graph I made from my library:
![sample musicnetwork graph](http://github.com/quadule/mucisnetwork/raw/master/sample-graph.png)

By default, an artist is shown in the graph if it has at least four incoming
connections. Artists in your library are drawn as folders while the other
artists are drawn as ovals. The colors don't mean anything, they just make it
easier to follow the line.

Usage:
ruby network.rb
ruby graph.rb

Requirements:
  - ruby-graphviz and Graphviz itself to draw the graph
  - rb-applescript to get the artists from iTunes 
  - nokogiri to scrape the Myspace pages