class Imdb
  require 'net/http'
  require 'open-uri'
  
  IMDB_SEARCH_PATH = "/find?q="
  
  
  attr_accessor :imdb_id, :title, :description, :rating, :runtime, :image_url, :imdb_contents
  
  def initialize(title)
    @title = title
    
    @imdb_contents = connect
    

    #get imdb id
    @imdb_id = @imdb_contents.match(/tt\d\d\d\d\d\d\d/).to_s

    #get cover
    @image_url = @imdb_contents.match(/name="poster.*height/).to_s.match(/http.*\.jpg/).to_s
    
    ##get plot
    @description = @imdb_contents.match(/Plot (Outline|Summary).*?href/m).to_s[18..-9].strip
    
    ##get runtime
    @runtime = @imdb_contents.match(/\d\d\d min/).to_s[0..-5]

    ##get rating
    @rating = @imdb_contents.match(/USA:(G|PG|PG-13|R|NR)/).to_s

  end
  
  def connect()
    
    h = Net::HTTP.new('www.imdb.com', 80)
    response = h.get(IMDB_SEARCH_PATH + @title.gsub(' ', '%20'))

    case response
    when Net::HTTPSuccess       then h.get("/title/#{response.body.scan(/<ol>.*<\/li>/).first.scan(/tt\d\d\d\d\d\d\d/).first}/").body
    when Net::HTTPRedirection   then h.get(URI.parse(response['location']).path).body
    else
      response.error!
    end

  end


  # this is here specifically for my flicks web app

  def to_h
    {:imdb_id => @imdb_id, :title => @title, :description => @description, :rating => @rating, :runtime => @runtime}
  end

  
  
end