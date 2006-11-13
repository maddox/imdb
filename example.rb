#!/usr/bin/env ruby
#
#  Created by Jon Maddox on 2006-11-12.
#  Copyright (c) 2006. All rights reserved.

require 'imdb'

movie = Imdb.new('die hard 2')

p "IMDB ID: #{movie.imdb_id}"
p "Title: #{movie.title}"
p "Plot: #{movie.description}"
p "Runtime: #{movie.runtime}"
p "Rating: #{movie.rating}"
p "Image URL: #{movie.image_url}"