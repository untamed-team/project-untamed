#Added by Gardenette
#Just testing some stuff
class My_Window < SpriteWindow_Base
 

  def initialize

    super(0, 0, 200, 200)

    self.contents = Bitmap.new(width-32, height-32)

    self.contents.font.name = "Arial"  

    self.contents.font.size = 24
    
    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(0, 0, 200, 32, "Yay, some text !")

  end

 

end