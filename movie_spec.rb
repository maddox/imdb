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

  it "should have a release date" do
    @movie.release_date.should eql(Date.new(2007, 06, 29))
  end

  it "should have a company" do
    @movie.company.imdb_id.should eql('co0017902')
    @movie.company.name.should eql('Pixar Animation Studios')
  end

  it "should have two directors" do
    @movie.directors.length.should == 2
    @movie.directors[0].imdb_id.should eql('nm0083348');
    @movie.directors[0].name.should eql('Brad Bird');
    @movie.directors[0].role.should eql(nil);

    @movie.directors[1].imdb_id.should eql('nm0684342');
    @movie.directors[1].name.should eql('Jan Pinkava');
    @movie.directors[1].role.should eql('co-director');
  end

  it "should have two writers" do
    @movie.writers.length.should == 2
    @movie.writers[0].imdb_id.should eql('nm0083348');
    @movie.writers[0].name.should eql('Brad Bird');
    @movie.writers[0].role.should eql('screenplay');

    @movie.writers[1].imdb_id.should eql('nm0684342');
    @movie.writers[1].name.should eql('Jan Pinkava');
    @movie.writers[1].role.should eql('story');
  end

  it "should have five genres" do
    @movie.genres.length.should == 3
    @movie.genres[0].name.should eql('Animation');
    @movie.genres[1].name.should eql('Comedy');
    @movie.genres[2].name.should eql('Family');
  end

  it "should have a tagline" do
    @movie.tagline.should eql('Dinner is served... Summer 2007')
  end
  
  it "should have a rating" do
    @movie.rating.should =~ /\d.\d/
  end
  
  it "should have a poster_url" do
    @movie.poster_url.should =~ /http:\/\/.*\.jpg/
  end

  it "should have a runtime" do
    @movie.runtime.should =~ /\d+ min/
  end
  
  it "should have a plot" do
    @movie.plot.should eql(%{Remy is a young rat in the French countryside who arrives in Paris, only to find out that his cooking idol is dead. When he makes an unusual alliance with a restaurant's new garbage boy, the culinary and personal adventures begin despite Remy's family's skepticism and the rat-hating world of humans.})
  end

  it "should return an empty array if writers is nil" do
    @movie.writers = nil
    @movie.writers.should == []
  end

  it "should return an empty array if directors is nil" do
    @movie.directors = nil
    @movie.directors.should == []
  end

  it "should return an empty array if genres is nil" do
    @movie.genres = nil
    @movie.genres.should == []
  end

end

