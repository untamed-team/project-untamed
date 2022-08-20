class Window_3 < SpriteWindow_Base

  #BLOCK 1
  def initialize
    super(0, 0, 440,380)
    self.contents = Bitmap.new(width-32, height-32)
    self.contents.font.name = "Arial"  
    self.contents.font.size = 24
    
    #BLOCK 2
     for i in 0...$Trainer.pokemon_count
      x = 0
      y = i * 150
      if i >= 2
        x=250
        y -= 300
      end      
      pkmn = $Trainer.pokemon_party[i]
      self.contents.font.color = Color.new(0,0,0)
      self.contents.draw_text(x, y, 200, 32, pkmn.name)
      offset_x=contents.text_size(pkmn.name).width+10
      self.contents.font.color = Color.new(0,0,0)
      self.contents.draw_text(x+offset_x, y, 200, 32, "Lv: " + pkmn.level.to_s)
      self.contents.draw_text(x, y+32, 200, 32, "HP: " + pkmn.hp.to_s)
      self.contents.draw_text(x, y+64, 200, 32, "EXP: " + pkmn.exp.to_s)
    end
  end
  
end