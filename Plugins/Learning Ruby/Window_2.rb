class Window_2 < SpriteWindow_Base
  
  #BLOCK 1
  def initialize
    super(0, 0, 200,380)
    self.contents = Bitmap.new(width-32, height-32)
    self.contents.font.name = "Arial"  
    self.contents.font.size = 24
    
    #BLOCK 2
    for i in 0...$Trainer.pokemon_count
      x = 0
      y = i * 90
      pkmn = $Trainer.pokemon_party[i]
      species = pkmn.species
      name = pkmn.name
      self.contents.font.color = Color.new(0,0,0)
      self.contents.draw_text(x, y, 200, 32, species.to_s)
      self.contents.font.color = Color.new(0,0,0)
      self.contents.draw_text(x, y+32, 200, 32, name.to_s)
    end
  end

end