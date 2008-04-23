class ImdbGenre
  attr_accessor :imdb_id, :name
  
  def initialize(imdb_id, name)
    self.imdb_id = imdb_id;
    self.name = name;
  end
end
