class Imdb

  IMDB_MOVIE_BASE_URL = "http://www.imdb.com/title/"


  def self.find_movie_by_id(id)
    
    data = Hpricot(open(IMDB_MOVIE_BASE_URL + id))
    
    movie = ImdbMovie.new
    
    movie.imdb_id = id
    movie.title = data.at("meta[@name='title']")['content'].gsub(/\(\d\d\d\d\)/,'').strip

    rating_text = (data/"div.rating/b").inner_text
    if rating_text =~ /([\d\.]+)\/10/
      movie.rating = $1
    end

    begin
      movie.poster_url = data.at("div.photo/a[@name='poster']/img")['src']
    rescue
      movie.poster_url = nil
    end

    (data/"div.info").each do |info|
      case (info/"h5").inner_text
      when /Directors?:/
        movie.director = parse_info(info).strip
      when "Runtime:"
        movie.runtime = parse_info(info).strip
      when "Plot Outline:"
        movie.plot = parse_info(info).gsub(/more$/, '').strip
      end
    end 

    movie # return movie

  end


  protected
  
  def self.parse_info(info)
    body = info.inner_text.gsub(/\n/,'') 
    if body =~ /\:(.+)/ 
      value = $1
    end
    value
  end


  
end


