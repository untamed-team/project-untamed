class Window_1 < SpriteWindow_Base
 

  def initialize

    super(0, 0, 640,100)

    self.contents = Bitmap.new(width-32, height-32)

    self.contents.font.name = "Arial"  

    self.contents.font.size = 24

    refresh

  end

 

  def refresh

    self.contents.clear

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(0, 0, 100, 32, "PlayTime:")

 

    #CODE TO SHOW PLAYTIME (Copied from Window_PlayTime)

    @total_sec = Graphics.frame_count / Graphics.frame_rate

    hour = @total_sec / 60 / 60

    min = @total_sec / 60 % 60

    sec = @total_sec % 60

    text = sprintf("%02d:%02d:%02d", hour, min, sec)

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(100, 0, 120, 32, text)

    #END OF CODE TO SHOW PLAYTIME

 

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(250, 0, 50, 32, "Gold:")

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(305, 0, 100, 32, $Trainer.money.to_s)

 

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(400, 0, 100, 32, "Map ID:")

    self.contents.font.color = Color.new(0,0,0)

    self.contents.draw_text(480, 0, 100, 32, $game_map.map_id.to_s)

  end

 

  def update

    if Graphics.frame_count / Graphics.frame_rate != @total_sec

	  refresh

    end

  end

 
end