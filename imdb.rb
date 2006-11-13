class Imdb
  require 'net/http'
  require 'open-uri'
  
  IMDB_SEARCH_PATH = "/find?q="
  
  
  attr_accessor :imdb_id, :title, :plot, :rating, :runtime, :image_url, :imdb_contents
  
  def initialize(title)
    @title = title
    
    @imdb_contents = connect
    

    #get imdb id
    @imdb_id = @imdb_contents.scan(/tt\d\d\d\d\d\d\d/).first

    #get cover
    @image_url = @imdb_contents.scan(/name="poster.*height/).first.scan(/http.*\.jpg/).first
    
    ##get plot
    @plot = @imdb_contents.scan(/Plot Outline:.*?href/).first[18..-9]

    ##get runtime
    @runtime = @imdb_contents.scan(/\d\d\d min/).first[0..-5]

    ##get rating
    @rating = @imdb_contents.scan(/USA:(G|PG|PG-13|R|NR)/).first.to_s

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

  def to_h
    {:imdb_id => @imdb_id, :title => @title, :plot => @plot, :rating => @rating, :runtime => @runtime, :image_url => @image_url}
  end

  
  
end