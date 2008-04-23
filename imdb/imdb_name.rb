class ImdbName
  attr_accessor :imdb_id, :name, :role
  
  def initialize(imdb_id, name, role)
    self.imdb_id = imdb_id;
    self.name = name;
    self.role = role;
  end
end
