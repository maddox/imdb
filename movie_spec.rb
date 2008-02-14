require 'imdb'

describe Imdb do
  it "should have an imdb movie base url" do
    Imdb::IMDB_MOVIE_BASE_URL.should eql("http://www.imdb.com/title/")
  end
  it "should have an imdb search base url" do
    Imdb::IMDB_SEARCH_BASE_URL.should eql("http://imdb.com/find?s=all&q=")
  end
end

describe ImdbMovie, " when first created" do

  it "should not have an imdb_id" do
    movie = ImdbMovie.new
    movie.imdb_id.should be_nil
  end

end

describe ImdbMovie, " after a Imdb.find_by_id returns it" do 
  before(:each) do
    @movie = Imdb.find_movie_by_id('tt0382932')
  end
  
  
  it "should have an imdb_id" do
    @movie.imdb_id.should eql('tt0382932')
  end

  it "should have a title" do
    @movie.title.should eql('Ratatouille')
  end

  it "should have a director" do
    @movie.director.should eql('Brad BirdJan Pinkava (co-director)')
  end

  it "should have a rating" do
    @movie.rating.should =~ /\d.\d/
  end
  
  it "should have a poster_url" do
    @movie.poster_url.should eql('http://ia.imdb.com/media/imdb/01/M/==/QM/1I/DM/xM/zN/wc/TZ/tF/kX/nB/na/B5/lM/B5/FO/wk/DM/0Y/zN/wg/zM/B5/VM._SX100_SY140_.jpg')
  end

  it "should have a runtime" do
    @movie.runtime.should =~ /\d+ min/
  end
  
  it "should have a plot" do
    @movie.plot.should eql(%{Remy is a young rat in the French countryside who arrives in Paris, only to find out that his cooking idol is dead. When he makes an unusual alliance with a restaurant's new garbage boy, the culinary and personal adventures begin despite Remy's family's skepticism and the rat-hating world of humans.})
  end

end

