class Imdb
  require 'net/http'
  require 'open-uri'
  
  IMDB_SEARCH_PATH = "/find?q="
  
  
  attr_accessor :imdb_id, :title, :description, :rated, :runtime, :image_url, :imdb_contents
  
  def initialize(title)
    @title = title
    
    @imdb_contents = connect
    

    #get imdb id
    begin
      @imdb_id = @imdb_contents.match(/tt\d\d\d\d\d\d\d/).to_s
    rescue
      @imdb_id = ""
    end
    
    #get cover
    begin
      @image_url = @imdb_contents.match(/name="poster.*height/).to_s.match(/http.*\.jpg/).to_s
    rescue
      @image_url = ""
    end
    
    ##get plot
    begin
      @description = @imdb_contents.match(/Plot (Outline|Summary).*?href/m).to_s[18..-9].strip
    rescue
      @description = ""
    end
    
    ##get runtime
    begin
      @runtime = @imdb_contents.match(/\d\d\d min|\d\d min/).to_s[0..-5]
    rescue
      @runtime = 0
    end
    
    ##get rating
    begin
      @rated = @imdb_contents.match(/USA:(G|PG-13|PG|R|NR)/).to_s.gsub('USA:', '')
    rescue
      @rated = "NR"
    end

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