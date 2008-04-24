class ImdbMovie
  attr_accessor :imdb_id, :title, :directors, :writers, :tagline, :company, :plot, :runtime, :rating, :poster_url, :release_date, :genres

  def writers
     self.instance_variable_get(:@writers) || []
  end

  def directors
    self.instance_variable_get(:@directors) || []
  end
  
  def genres
    self.instance_variable_get(:@genres) || []
  end

end
