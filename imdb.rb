module Imdb

  class Movie
  
    require 'rubygems'
    require 'hpricot'
    require 'open-uri'
  
    attr_accessor :imdb_id, :title, :director, :plot, :runtime, :rating, :poster_url
  
    IMDB_MOVIE_URL = "http://www.imdb.com/title/"
  

    def find_by_id(id)
      self.imdb_id = id
      data = Hpricot(open(IMDB_MOVIE_URL + id))
      self.title = data.at("meta[@name='title']")['content'].gsub(/\(\d\d\d\d\)/,'').strip

      rating_text = (data/"div.rating/b").inner_text
      if rating_text =~ /([\d\.]+)\/10/
        self.rating = $1
      end

      self.poster_url = data.at("div.photo/a[@name='poster']/img")['src']

      (data/"div.info").each do |info|
        case (info/"h5").inner_text
        when /Directors?:/
          self.director = parse_info(info).strip
        when "Runtime:"
          self.runtime = parse_info(info).strip
        when "Plot Outline:"
          self.plot = parse_info(info).gsub(/more$/, '').strip
        end
      end 
      
    end




  protected
  
    def parse_info(info)
      body = info.inner_text
      body = body.gsub(/\n/,'') 
      if body =~ /\:(.+)/ 
        body = $1
      end
      body
    end
  
  
  
  end
  
end