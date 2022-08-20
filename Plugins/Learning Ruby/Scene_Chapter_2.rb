class Scene_Chapter_2

#BLOCK 1
def main
   @window_1=Window_1.new

   @window_2=Window_2.new
   @window_2.y=100

   @window_3=Window_3.new
   @window_3.x=200
   @window_3.y=100

#BLOCK 2
   Graphics.transition
   loop do
    Graphics.update
    Input.update
    update
    if $scene != self
     break
    end
   end

#BLOCK 3
  Graphics.freeze
   @window_1.dispose
   @window_2.dispose
   @window_3.dispose
  end

#BLOCK 4
def update
   @window_1.update
   if Input.trigger?(Input::B)
     pbPlayCancelSE
     $scene = Scene_Map.new
   end
  end

end