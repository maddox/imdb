class Imdb

  IMDB_MOVIE_BASE_URL = "http://www.imdb.com/title/"
  IMDB_NAME_BASE_URL = "http://www.imdb.com/name/"
  IMDB_COMPANY_BASE_URL = "http://www.imdb.com/company/"
  IMDB_GENRE_BASE_URL = "http://www.imdb.com/Sections/Genres/"
  IMDB_SEARCH_BASE_URL = "http://imdb.com/find?s=all&q="

  def self.find_movie_by_id(id)
    
    data = Hpricot(open(IMDB_MOVIE_BASE_URL + id))
    
    movie = ImdbMovie.new
    
    movie.imdb_id = id
    movie.title = data.at("meta[@name='title']")['content'].gsub(/\(\d\d\d\d\)/,'').strip

    rating_text = (data/"div.rating/div.meta/b").inner_text
    if rating_text =~ /([\d\.]+)\/10/
      movie.rating = $1
    end

    begin
      movie.poster_url = data.at("div.photo/a[@name='poster']/img")['src']
    rescue
      movie.poster_url = nil
    end

    infos = (data/"div.info")
    infos.each do |info|
      info_title = (info/"h5").inner_text
      case info_title
      when /Directors?:/
        movie.directors = parse_names(info)
      when /Writers?[^:]+:/
        movie.writers = parse_names(info)
      when /Company:/
        movie.company = parse_company(info)
      when "Tagline:"
        movie.tagline = parse_info(info).strip
      when "Runtime:"
        movie.runtime = parse_info(info).strip
      when "Plot:"
        movie.plot = parse_info(info).strip
        movie.plot = movie.plot.gsub(/\s*\|\s*add synopsis$/, '')
        movie.plot = movie.plot.gsub(/\s*\|\s*full synopsis$/, '')
        movie.plot = movie.plot.gsub(/full summary$/, '')
        movie.plot = movie.plot.strip
      when "Genre:"
        movie.genres = parse_genres(info)
      when "Release Date:"
        begin
          if (parse_info(info).strip =~ /(\d{1,2}) ([a-zA-Z]+) (\d{4})/)
            movie.release_date = Date.parse("#{$2} #{$1}, #{$3}");
          end
        rescue
          movie.release_date = nil;
        end
      end
    end 

    movie # return movie

  end


  protected
  
  def self.parse_info(info)
    value = info.inner_text.gsub(/\n/,'') 
    if value =~ /\:(.+)/ 
      value = $1
    end
    value.gsub(/ more$/, '')
  end
  
  def self.parse_names(info)
    # <a href="/name/nm0083348/">Brad Bird</a><br/><a href="/name/nm0684342/">Jan Pinkava</a> (co-director)<br/>N
    info.inner_html.scan(/<a href="\/name\/([^"]+)\/">([^<]+)<\/a>( \(([^)]+)\))?/).map do |match|
      ImdbName.new(match[0], match[1], match[3])
    end
  end
  
  def self.parse_company(info)
    # <a href="/company/co0017902/">Pixar Animation Studios</a>
    match = info.inner_html =~ /<a href="\/company\/([^"]+)\/">([^<]+)<\/a>/;
    ImdbCompany.new($1, $2)
  end

  def self.parse_genres(info)
    # <a href="/Sections/Genres/Animation/">Animation</a> / <a href="/Sections/Genres/Adventure/">Adventure</a>
    genre_links = (info/"a").find_all do |link|
      link['href'] =~ /^\/Sections\/Genres/
    end 
    genre_links.map do |link|
      genre = link['href'] =~ /([^\/]+)\/$/
      ImdbGenre.new($1, $1)
    end
  end

  
end
