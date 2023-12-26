class SpeciesTypeMatch_Scene

  # Filename for base graphic
  WINDOWSKIN = "base_species.png"
  
  # Choose whether you want the background to animate
  MOVINGBACKGROUND = true
  
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
  end
 
  def pbStartScene
    addBackgroundPlane(@sprites,"bg","TypeMatch/bg",@viewport)
    @sprites["base"] = IconSprite.new(0,0,@viewport)
    @sprites["base"].setBitmap("Graphics/Pictures/TypeMatch/"+WINDOWSKIN)
    @sprites["base"].ox = @sprites["base"].bitmap.width/2
    @sprites["base"].oy = @sprites["base"].bitmap.height/2
    @sprites["base"].x = Graphics.width/2; @sprites["base"].y = Graphics.height/2 - 16
    @h = @sprites["base"].y - @sprites["base"].oy
    @w = @sprites["base"].x - @sprites["base"].ox
    @typebitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    2.times do |i|
      @sprites["icon_#{i}"] = PokemonSpeciesIconSprite.new(nil,@viewport)
      @sprites["icon_#{i}"].setOffset(PictureOrigin::CENTER)
      @sprites["icon_#{i}"].x = Graphics.width/2 - 112 + 224*i
      @sprites["icon_#{i}"].y = @h+40
      @sprites["icon_#{i}"].mirror = true if i==0
    end
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow",8,40,28,2,@viewport)
    @sprites["rightarrow"].x = Graphics.width - @sprites["rightarrow"].bitmap.width
    @sprites["rightarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["rightarrow"].visible = false
    @sprites["rightarrow"].play
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow",8,40,28,2,@viewport)
    @sprites["leftarrow"].x = 0
    @sprites["leftarrow"].y = Graphics.height/2 - @sprites["rightarrow"].bitmap.height/16
    @sprites["leftarrow"].visible = false
    @sprites["leftarrow"].play
    @sprites["bottombar"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["bottombar"].bitmap.fill_rect(0,Graphics.height-32,Graphics.width,32,Color.new(48,192,216))
    @sprites["bottombar"].visible = true
    @sprites["text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay_text = @sprites["text"].bitmap
    pbSetSystemFont(@overlay_text)
    @sprites["type"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay_type = @sprites["type"].bitmap
    pbSetSystemFont(@overlay_type)
    region = pbGetCurrentRegion
    @species = pbAllRegionalSpecies(region)
    # If no Regional Dex defined for the given region, use the National Pokédex
    if !@species || @species.length == 0
      @species = []
      GameData::Species.each { |s| @species.push(s.id) if s.form == 0 && $player.seen?(s.id)}
    end
    @types = []
    GameData::Type.each { |t| @types.push(t.id) if !t.pseudo_type }
  end
    
  def pbTypeMatchUp
    @index = 0
    species = @species[@index]
    @init = true
    drawSpeciesTypes(species)
    pbFadeInAndShow(@sprites) { pbUpdate }
    loop do
      Graphics.update
      Input.update
      pbUpdate
      refresh = false
      if Input.trigger?(Input::RIGHT) && @index< @species.length-1
        pbPlayCursorSE
        @index +=1
        newSpecies = @species[@index]
        refresh = true
      elsif Input.trigger?(Input::LEFT) && @index> 0
        pbPlayCursorSE
        @index -=1
        newSpecies = @species[@index]
        refresh = true
      elsif Input.trigger?(Input::USE) # Option to choose specific type
        oldSpecies = @species[@index]
        newSpecies = pbChooseSpeciesFromList(oldSpecies, oldSpecies)
        if oldSpecies != newSpecies
          @index = @species.index(newSpecies)
          refresh = true
        end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
      drawSpeciesTypes(newSpecies) if refresh
    end
  end
  
  def drawSpeciesTypes(species)
    @sprites["rightarrow"].visible = (@index < @species.length-1) ? true : false
    @sprites["leftarrow"].visible = (@index > 0) ? true : false
    @overlay_type.clear
    s = GameData::Species.get(species)
    2.times do |i|
      @sprites["icon_#{i}"].pbSetParams(s.id,0,s.form,false)
    end
    # Types of selected Pokémon
	s.types.each_with_index do |type, i|
      type_number = GameData::Type.get(type).icon_position
      type_rect = Rect.new(0, type_number * 28, 64, 28)
      type_x = (s.types.length == 1) ? Graphics.width/2-32 : Graphics.width/2 - (64 * ((i + 1)%2))
      @overlay_type.blt(type_x,@h+36,@typebitmap.bitmap,type_rect)
    end
    arr = []
    weak = []
    resist = []
    immune = []
    GameData::Type.each { |t| arr.push(Effectiveness.calculate(t.id,s.types[0],s.types[1])) if !t.pseudo_type }
    arr.each_with_index do |z, i|
      currType = @types[i]
      weak.push(currType) if Effectiveness.super_effective?(z)
      resist.push(currType) if Effectiveness.not_very_effective?(z)
      immune.push(currType) if Effectiveness.ineffective?(z)
    end
    # Weaknesses
    xPos1 = (weak.length >6) ? [@w+40, @w+104] : @w+72
    weaktype_rect = []
    weak.each_with_index do |s, i|
      t = GameData::Type.get(s).icon_position
      weaktype_rect.push(Rect.new(0, t * 28, 64, 28))
      x1 = (xPos1.is_a?(Array)) ? xPos1[i/6] : xPos1
      @overlay_type.blt(x1,@h+108+28*(i%6),@typebitmap.bitmap,weaktype_rect[i])
    end
    # Resistances
    # Because Steel typing has an annoying number of resistances
    xPos2 = (resist.length >6) ? [Graphics.width/2-64,Graphics.width/2] : Graphics.width/2-32
    resisttype_rect = []
    resist.each_with_index do |s, i|
      t = GameData::Type.get(s).icon_position
      resisttype_rect.push(Rect.new(0, t * 28, 64, 28))
      x2 = (xPos2.is_a?(Array)) ? xPos2[i/6] : xPos2
      @overlay_type.blt(x2,@h+108+28*(i%6),@typebitmap.bitmap,
          resisttype_rect[i])
    end
    # Immunities
    immunetype_rect = []
    immune.each_with_index do |s, i|
      t = GameData::Type.get(s).icon_position
      immunetype_rect.push(Rect.new(0, t * 28, 64, 28))
      @overlay_type.blt(@w+312,@h+108+28*i,@typebitmap.bitmap,immunetype_rect[i])
    end
    base   = Color.new(80,80,88)
    shadow = Color.new(160,160,168)
    textpos = [
    ["Weak",@w+104,@h+80,2,base,shadow],
    ["Resist",Graphics.width/2,@h+80,2,base,shadow],
    ["Immune",@w+344,@h+80,2,base,shadow],
    ["USE: Jump",4,Graphics.height-26,0,Color.new(248,248,248),Color.new(72,80,88)],
    ["ARROWS: Navigate",Graphics.width/2,Graphics.height-26,2,Color.new(248,248,248),Color.new(72,80,88)],
    ["BACK: Exit",Graphics.width-4,Graphics.height-26,1,Color.new(248,248,248),Color.new(72,80,88)]
    ]
    pbDrawTextPositions(@overlay_text,textpos) if @init
    # Draw species name
    pbDrawTextPositions(@overlay_type,[
           [s.real_name,Graphics.width/2,@h+10,2,base,shadow]
        ])
    @init = false
  end
  
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    if @sprites["bg"] && MOVINGBACKGROUND
      @sprites["bg"].ox-=1
      @sprites["bg"].oy-=1
    end
  end
  
  # Dipose stuff at the end
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @typebitmap.dispose
    @viewport.dispose
  end
  
  # Borrowed from the editor scripts
  # Renamed so as to not break anything anywhere else
  def pbChooseSpeciesFromList(default = nil, currSpecies)
    commands = []
    @species.each do |s|
      t = GameData::Species.get(s)
      commands.push([commands.length + 1, t.real_name, t.id]) if t.form == 0
    end
    return pbChooseList(commands, default, currSpecies, 0)
  end

end

class SpeciesTypeMatch_Screen
  
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTypeMatchUp
    @scene.pbEndScene
  end
  
end

def pbSpeciesTypeMatchUI
  pbFadeOutIn {
    scene = SpeciesTypeMatch_Scene.new
    screen = SpeciesTypeMatch_Screen.new(scene)
    screen.pbStartScreen
  }
end
