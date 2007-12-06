require 'imdb'
include Imdb

describe Movie do
  it "should have an imdb base url" do
    Movie::IMDB_MOVIE_URL.should eql("http://www.imdb.com/title/")
  end
end

describe Movie, " when first created" do

  it "should not have an imdb_id" do
    movie = Movie.new
    movie.imdb_id.should be_nil
  end

end

describe Movie, " after a find_by_id" do 
  before(:each) do
    @movie = Movie.new
    @movie.find_by_id('tt0382932')
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
    @movie.rating.should eql('8.4')
  end
  
  it "should have a poster_url" do
    @movie.poster_url.should eql('http://ia.imdb.com/media/imdb/01/I/48/39/63/10m.jpg')
  end

  it "should have a runtime" do
    @movie.runtime.should eql('111 min')
  end
  
  it "should have a plot" do
    @movie.plot.should eql(%{Remy is a young rat in the French countryside who arrives in Paris, only to find out that his cooking idol is dead. When he makes an unusual alliance with a restaurant's new garbage boy, the culinary and personal adventures begin despite Remy's family's skepticism and the rat-hating world of humans.})
  end

end

