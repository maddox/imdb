class Imdb

  IMDB_MOVIE_BASE_URL = "http://www.imdb.com/title/"
  IMDB_NAME_BASE_URL = "http://www.imdb.com/name/"
  IMDB_COMPANY_BASE_URL = "http://www.imdb.com/company/"
  IMDB_GENRE_BASE_URL = "http://www.imdb.com/Sections/Genres/"
  IMDB_SEARCH_BASE_URL = "http://imdb.com/find?s=all&q="


  def self.search_movies_by_title(title)
    coder = HTMLEntities.new
    document = Hpricot(open("#{IMDB_SEARCH_BASE_URL}#{CGI::escape(title)};s=tt").read)
    # we got search results
    if document.search('title').inner_text == "IMDb Title Search"
      results = document.search('a[@href^="/title/tt"]').reject do |element|
        element.innerHTML.strip_tags.empty?
      end.map do |element|
        {:imdb_id => element['href'][/tt\d+/], :title => coder.decode(element.innerHTML.strip_tags.unescape_html)}
      end
      results.uniq
    else
      {:imdb_id => document.search('link[@href^="http://www.imdb.com/title/tt"]').first['href'].match(/tt\d+/).to_s, :title => coder.decode(document.search('meta[@name="title"]').first["content"].gsub(/\(\d\d\d\d\)$/, '').strip)}
    end
  end

  def self.find_movie_by_id(id)
    coder = HTMLEntities.new

    data = Hpricot(open(IMDB_MOVIE_BASE_URL + id))
    
    movie = ImdbMovie.new
    
    movie.imdb_id = id
    movie.title = coder.decode(data.at("title").inner_text.gsub(/\((\d{4}(\/[^)]*)?|[A-Z]+)\)/,'').strip)

    rating_text = (data/"div.starbar-meta/b").inner_text
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
        movie.tagline = coder.decode(parse_info(info).strip)
      when "Runtime:"
        movie.runtime = parse_info(info).strip
        if (movie.runtime)
          movie.runtime.gsub!(/^[^:]+:\s*/, '')
          movie.runtime.gsub!(/min .*/, 'min')
        end
      when "Plot:"
        movie.plot = parse_info(info).strip
        movie.plot = movie.plot.gsub(/\s*\|\s*add synopsis$/, '')
        movie.plot = movie.plot.gsub(/\s*\|\s*full synopsis$/, '')
        movie.plot = movie.plot.gsub(/\s*\|\s*add summary$/, '')
        movie.plot = movie.plot.gsub(/full summary$/, '')
        movie.plot = movie.plot.gsub(/more$/, '')
        movie.plot = coder.decode(movie.plot.strip)
      when "Genre:"
        movie.genres = parse_genres(info)
      when "Release Date:"
        begin
          if (parse_info(info).strip =~ /(\d{1,2}) ([a-zA-Z]+) (\d{4})/)
            movie.release_date = Date.parse("#{$2} #{$1}, #{$3}")
          end
        rescue
          movie.release_date = nil
        end
      when "Certification:"
        begin
          movie.certification = (info/"a").map { |v| v.inner_html }.select { |v| v =~ /^USA:/ && v !~ /Unrated/ }.map { |v| v[/^USA:/]=''; v.strip }.first
        end
      end
    end 

    cast = (data/"table.cast"/"tr")
    cast.each do |cast_member|
        actor_a = (cast_member/"td.nm").inner_html
        actor_a =~ /name\/([^"]+)\//
        actor_id = $1
        actor_name = coder.decode((cast_member/"td.nm"/"a").inner_text)
        actor_role = coder.decode((cast_member/"td.char").inner_text)
        movie.actors = movie.actors << ImdbName.new(actor_id, actor_name, actor_role)
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
    coder = HTMLEntities.new

    # <a href="/name/nm0083348/">Brad Bird</a><br/><a href="/name/nm0684342/">Jan Pinkava</a> (co-director)<br/>N
    info.inner_html.scan(/<a href="\/name\/([^"]+)\/"[^>]*>([^<]+)<\/a>( \(([^)]+)\))?/).map do |match|
      ImdbName.new(coder.decode(match[0]), coder.decode(match[1]), coder.decode(match[3]))
    end
  end
  
  def self.parse_company(info)
    coder = HTMLEntities.new
    # <a href="/company/co0017902/">Pixar Animation Studios</a>
    match = info.inner_html =~ /<a href="\/company\/([^"]+)\/">([^<]+)<\/a>/
    ImdbCompany.new(coder.decode($1), coder.decode($2))
  end

  def self.parse_genres(info)
    coder = HTMLEntities.new
    # <a href="/Sections/Genres/Animation/">Animation</a> / <a href="/Sections/Genres/Adventure/">Adventure</a>
    genre_links = (info/"a").find_all do |link|
      link['href'] =~ /^\/Sections\/Genres/
    end 
    genre_links.map do |link|
      genre = link['href'] =~ /([^\/]+)\/$/
      ImdbGenre.new(coder.decode($1), coder.decode($1))
    end
  end

  
end
