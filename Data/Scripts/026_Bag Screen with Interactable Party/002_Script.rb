#===============================================================================
# Creating specific Bag and Party functionalities
#===============================================================================
class Window_PokemonBag < Window_DrawableCommand
  attr_reader :pocket
  attr_accessor :sorting
  attr_accessor :partysel

  def initialize(bag, filterlist, pocket, x, y, width, height)
    @bag        = bag
    @filterlist = filterlist
    @pocket     = pocket
    @sorting  = false
    @partysel = false
    @adapter  = PokemonMartAdapter.new
    super(x, y, width, height)
    @selarrow   = AnimatedBitmap.new("Graphics/Pictures/Bag Party/cursor")
    @swaparrow  = AnimatedBitmap.new("Graphics/Pictures/Bag Party/cursor_swap")
    @partyarrow = AnimatedBitmap.new("Graphics/Pictures/Bag Party/cursor_party")
    self.windowskin = nil
  end

  def dispose
    @swaparrow.dispose
    @partyarrow.dispose
    super
  end

  def pocket=(value)
    @pocket = value
    @item_max = (@filterlist) ? @filterlist[@pocket].length + 1 : @bag.pockets[@pocket].length + 1
    self.index = @bag.last_viewed_index(@pocket)
  end

  def page_row_max; return PokemonBag_Scene::ITEMSVISIBLE; end
  def page_item_max; return PokemonBag_Scene::ITEMSVISIBLE; end

  def item
    return nil if @filterlist && !@filterlist[@pocket][self.index]
    thispocket = @bag.pockets[@pocket]
    item = (@filterlist) ? thispocket[@filterlist[@pocket][self.index]] : thispocket[self.index]
    return (item) ? item[0] : nil
  end

  def itemCount
    return (@filterlist) ? @filterlist[@pocket].length + 1 : @bag.pockets[@pocket].length + 1
  end

  def itemRect(item)
    if item < 0 || item >= @item_max || item < self.top_item - 1 ||
       item > self.top_item + self.page_item_max
      return Rect.new(0, 0, 0, 0)
    else
      cursor_width = (self.width - self.borderX - ((@column_max - 1) * @column_spacing)) / @column_max
      x = item % @column_max * (cursor_width + @column_spacing)
      y = (item / @column_max * @row_height) - @virtualOy
      return Rect.new(x, y, cursor_width, @row_height)
    end
  end

  def drawCursor(index, rect)
    if self.index == index
      if @partysel
        bmp = @partyarrow.bitmap
      elsif @sorting
        bmp = @swaparrow.bitmap
      else
        bmp = @selarrow.bitmap
      end
      pbCopyBitmap(self.contents, bmp, rect.x, rect.y + 2)
    end
  end

  def drawItem(index, _count, rect)
    textpos = []
    rect = Rect.new(rect.x + 16, rect.y + 16, rect.width - 16, rect.height)
    thispocket = @bag.pockets[@pocket]
    if index == self.itemCount - 1
      textpos.push([_INTL("CLOSE BAG"), rect.x, rect.y + 4, false, self.baseColor, self.shadowColor])
    else
      item = (@filterlist) ? thispocket[@filterlist[@pocket][index]][0] : thispocket[index][0]
      baseColor   = self.baseColor
      shadowColor = self.shadowColor
      if @sorting && index == self.index
        #baseColor   = Color.new(248, 144, 144)
        #shadowColor = Color.new(224, 0, 0)
        baseColor   = Color.new(224, 0, 0)
        shadowColor = Color.new(248, 144, 144)
        
      end
      textpos.push(
        [@adapter.getDisplayName(item), rect.x, rect.y + 4, false, baseColor, shadowColor]
      )
      if GameData::Item.get(item).is_important?
        if @bag.registered?(item)
          pbDrawImagePositions(
            self.contents,
            [["Graphics/Pictures/Bag Party/icon_register", rect.x + rect.width - 72, rect.y + 10, 0, 0, -1, 24]]
          )
        elsif pbCanRegisterItem?(item)
          pbDrawImagePositions(
            self.contents,
            [["Graphics/Pictures/Bag Party/icon_register", rect.x + rect.width - 72, rect.y + 10, 0, 24, -1, 24]]
          )
        end
      else
        qty = (@filterlist) ? thispocket[@filterlist[@pocket][index]][1] : thispocket[index][1]
        qtytext = _ISPRINTF("x{1: 3d}", qty)
        xQty    = rect.x + rect.width - self.contents.text_size(qtytext).width - 16
        textpos.push([qtytext, xQty, rect.y + 4, false, baseColor, shadowColor])
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end

  def refresh
    @item_max = itemCount
    self.update_cursor_rect
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    @item_max.times do |i|
      next if i < self.top_item - 1 || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index))
  end

  def update
    super
    @uparrow.visible   = false
    @downarrow.visible = false
  end
end

class PokemonBagPartyBlankPanel < SpriteWrapper
  attr_accessor :text

  def initialize(_pokemon,index,viewport=nil)
    super(viewport)
    self.x = (index % 2) * 112 + 4
    self.y = (index % 2) + 96 + 2
    @panelbgsprite = AnimatedBitmap.new("Graphics/Pictures/Bag Party/ptpanel_blank")
    self.bitmap = @panelbgsprite.bitmap
    @text = nil
  end

  def dispose
    @panelbgsprite.dispose
    super
  end

  def selected; return false; end
  def selected=(value); end
  def preselected; return false; end
  def preselected=(value); end
  def switching; return false; end
  def switching=(value); end
  def refresh; end
end

class PokemonBagPartyPanel < SpriteWrapper
  attr_reader :pokemon
  attr_reader :active
  attr_reader :selected
  attr_reader :preselected
  attr_reader :switching
  attr_reader :text

  def initialize(pokemon, index, viewport=nil)
    super(viewport)
    @pokemon = pokemon
    @active = (index == 0)   # true = rounded panel, false = rectangular panel
    @refreshing = true
    self.x = (index % 2) * 112 + 4
    self.y = 96 * (index / 2) + 2
    @panelbgsprite = ChangelingSprite.new(0, 0, viewport)
    @panelbgsprite.z = self.z
    if @active   # Rounded panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Bag Party/ptpanel_round_desel")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Bag Party/ptpanel_round_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Bag Party/ptpanel_round_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Bag Party/ptpanel_round_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Bag Party/ptpanel_round_move")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Bag Party/ptpanel_round_move_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Bag Party/ptpanel_round_move_sel")
    else   # Rectangular panel
      @panelbgsprite.addBitmap("able", "Graphics/Pictures/Bag Party/ptpanel_rect_desel")
      @panelbgsprite.addBitmap("ablesel", "Graphics/Pictures/Bag Party/ptpanel_rect_sel")
      @panelbgsprite.addBitmap("fainted", "Graphics/Pictures/Bag Party/ptpanel_rect_faint")
      @panelbgsprite.addBitmap("faintedsel", "Graphics/Pictures/Bag Party/ptpanel_rect_faint_sel")
      @panelbgsprite.addBitmap("swap", "Graphics/Pictures/Bag Party/ptpanel_rect_move")
      @panelbgsprite.addBitmap("swapsel", "Graphics/Pictures/Bag Party/ptpanel_rect_move_sel")
      @panelbgsprite.addBitmap("swapsel2", "Graphics/Pictures/Bag Party/ptpanel_rect_move_sel")
    end
    @pkmnsprite = PokemonIconSprite.new(pokemon, viewport)
    @pkmnsprite.setOffset(PictureOrigin::CENTER)
    @pkmnsprite.active = @active
    @pkmnsprite.z      = self.z + 1
    @hpbgsprite = ChangelingSprite.new(0, 0, viewport)
    @hpbgsprite.z = self.z + 2
    @hpbgsprite.addBitmap("able", "Graphics/Pictures/Bag Party/overlay_hp_back")
    @hpbgsprite.addBitmap("fainted", "Graphics/Pictures/Bag Party/overlay_hp_back")
    @hpbgsprite.addBitmap("swap", "Graphics/Pictures/Bag Party/overlay_hp_back")
    @helditemsprite = HeldItemIconSprite.new(0, 0, @pokemon, viewport)
    @helditemsprite.z = self.z + 3
    @overlaysprite = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    @overlaysprite.z = self.z + 4
    @hpbar    = AnimatedBitmap.new("Graphics/Pictures/Bag Party/overlay_hp")
    @statuses = AnimatedBitmap.new(_INTL("Graphics/Pictures/Bag Party/statuses"))
    @selected      = false
    @preselected   = false
    @switching     = false
    @text          = nil
    @refreshBitmap = true
    @refreshing    = false
    refresh
  end

  def dispose
    @panelbgsprite.dispose
    @hpbgsprite.dispose
    @pkmnsprite.dispose
    @helditemsprite.dispose
    @overlaysprite.bitmap.dispose
    @overlaysprite.dispose
    @hpbar.dispose
    @statuses.dispose
    super
  end

  def x=(value)
    super
    refresh
  end

  def y=(value)
    super
    refresh
  end

  def color=(value)
    super
    refresh
  end

  def text=(value)
    if @text != value
      @text = value
      @refreshBitmap = true
      refresh
    end
  end

  def pokemon=(value)
    @pokemon = value
    @pkmnsprite.pokemon = value if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.pokemon = value if @helditemsprite && !@helditemsprite.disposed?
    @refreshBitmap = true
    refresh
  end

  def selected=(value)
    if @selected != value
      @selected = value
      refresh
    end
  end

  def preselected=(value)
    if @preselected != value
      @preselected = value
      refresh
    end
  end

  def switching=(value)
    if @switching != value
      @switching = value
      refresh
    end
  end

  def hp; return @pokemon.hp; end

  def refresh
    return if disposed?
    return if @refreshing
    @refreshing = true
    if @panelbgsprite && !@panelbgsprite.disposed?
      if self.selected
        if self.preselected;     @panelbgsprite.changeBitmap("swapsel2")
        elsif @switching;        @panelbgsprite.changeBitmap("swapsel")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("faintedsel")
        else;                    @panelbgsprite.changeBitmap("ablesel")
        end
      else
        if self.preselected;     @panelbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?; @panelbgsprite.changeBitmap("fainted")
        else;                    @panelbgsprite.changeBitmap("able")
        end
      end
      @panelbgsprite.x     = self.x
      @panelbgsprite.y     = self.y
      @panelbgsprite.color = self.color
    end
    if @hpbgsprite && !@hpbgsprite.disposed?
      @hpbgsprite.visible = !@pokemon.egg?
      if @hpbgsprite.visible
        if self.preselected || (self.selected && @switching); @hpbgsprite.changeBitmap("swap")
        elsif @pokemon.fainted?;                              @hpbgsprite.changeBitmap("fainted")
        else;                                                 @hpbgsprite.changeBitmap("able")
        end
        @hpbgsprite.x     = self.x + 6
        @hpbgsprite.y     = self.y + 60
        @hpbgsprite.color = self.color
      end
    end
    if @pkmnsprite && !@pkmnsprite.disposed?
      @pkmnsprite.x        = self.x + 32
      @pkmnsprite.y        = self.y + 36
      @pkmnsprite.color    = self.color
      @pkmnsprite.selected = self.selected
    end
    if @helditemsprite&.visible && !@helditemsprite.disposed?
      @helditemsprite.x     = self.x + 46
      @helditemsprite.y     = self.y + 44
      @helditemsprite.color = self.color
    end
    if @overlaysprite && !@overlaysprite.disposed?
      @overlaysprite.x     = self.x
      @overlaysprite.y     = self.y
      @overlaysprite.color = self.color
    end
    if @refreshBitmap
      @refreshBitmap = false
      @overlaysprite.bitmap.clear if @overlaysprite.bitmap
      baseColor   = Color.new(248, 248, 248)
      outlineColor = Color.new(0, 0, 0)
      pbSetSystemFont(@overlaysprite.bitmap)
      pbSetSmallFont(@overlaysprite.bitmap)
      textpos = []
      if !@pokemon.egg?
        if !@text || @text.length == 0
          # Draw HP numbers
          textpos.push([sprintf("% 3d /% 3d", @pokemon.hp, @pokemon.totalhp), 52, 76, 2, baseColor, Color.new(40, 40, 40), true, Graphics.width]) if !@text || @text.length == 0
        end
          # Draw HP bar
          if @pokemon.hp > 0
            w = @pokemon.hp * 94 / @pokemon.totalhp.to_f
            w = 1 if w < 1
            w = ((w / 2).round) * 2
            hpzone = 0
            hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
            hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
            hprect = Rect.new(0, hpzone * 8, w, 8)
            @overlaysprite.bitmap.blt(8, 62, @hpbar.bitmap, hprect)
          end
          # Draw status
          status = -1
          if @pokemon.fainted?
            status = GameData::Status.count
          elsif @pokemon.status != :NONE
            status = GameData::Status.get(@pokemon.status).icon_position
          elsif @pokemon.pokerusStage == 1
            status = GameData::Status.count + 1
          end
          if status >= 0
            statusrect = Rect.new(0, 18 * status, 52, 18)
            @overlaysprite.bitmap.blt(52, 26, @statuses.bitmap, statusrect)
          end
        # Draw gender symbol
        if @pokemon.male?
          textpos.push([_INTL("♂"), 92, 8, 0, Color.new(116, 162, 237), outlineColor, true, Graphics.width])
        elsif @pokemon.female?
          textpos.push([_INTL("♀"), 92, 8, 0, Color.new(237, 116, 140), outlineColor, true, Graphics.width])
        end
        # Draw shiny icon
        if @pokemon.shiny?
          pbDrawImagePositions(@overlaysprite.bitmap,
                               [["Graphics/Pictures/shiny", 76, 44, 0, 0, 16, 16]])
        end
      end
      pbDrawTextPositions(@overlaysprite.bitmap, textpos)
      # Draw level text
      if !@pokemon.egg?
        pbDrawImagePositions(@overlaysprite.bitmap,
                             [["Graphics/Pictures/Bag Party/overlay_lv", 34, 10, 0, 0, 22, 14]])
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,
                            [[@pokemon.level.to_s, 58, 8, 0, baseColor, outlineColor, true, Graphics.width]])
      end
      # Draw annotation text
      if @text && @text.length > 0
        pbSetSystemFont(@overlaysprite.bitmap)
        pbSetSmallFont(@overlaysprite.bitmap)
        pbDrawTextPositions(@overlaysprite.bitmap,
                            [[@text,56,76,2,baseColor,Color.new(40, 40, 40), true, Graphics.width]])
      end
    end
    @refreshing = false
  end

  def update
    super
    @panelbgsprite.update if @panelbgsprite && !@panelbgsprite.disposed?
    @hpbgsprite.update if @hpbgsprite && !@hpbgsprite.disposed?
    @pkmnsprite.update if @pkmnsprite && !@pkmnsprite.disposed?
    @helditemsprite.update if @helditemsprite && !@helditemsprite.disposed?
  end
end

#===============================================================================
# Bag visuals
#===============================================================================
class PokemonBag_Scene
  ITEMLISTBASECOLOR      = Color.new(80,80,88)
  ITEMLISTSHADOWCOLOR    = Color.new(160,160,168)
  #ITEMTEXTBASECOLOR      = Color.new(239,239,239)
  #ITEMTEXTSHADOWCOLOR    = ITEMLISTSHADOWCOLOR
  ITEMTEXTBASECOLOR      = Color.new(80,80,88)
  ITEMTEXTSHADOWCOLOR    = Color.new(160,160,168)
  POCKETNAMEBASECOLOR    = Color.new(255,255,255)
  POCKETNAMEOUTLINECOLOR = Color.new(78,83,100)
  ITEMSVISIBLE           = 6

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @sprites["panorama"].x  = 0 if @sprites["panorama"].x == - 56
    @sprites["panorama"].x -= 2 if BagScreenWiInParty::PANORAMA == true
  end

  def pbStartScene(bag, party, choosing = false, filterproc = nil, resetpocket = true)
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @bag        = bag
    @choosing   = choosing
    @filterproc = filterproc
    @party      = party
    
    pbRefreshFilter
    lastpocket = @bag.last_viewed_pocket
    numfilledpockets = @bag.pockets.length - 1
    if @choosing
      numfilledpockets = 0
      if @filterlist.nil?
        (1...@bag.pockets.length).each do |i|
          numfilledpockets += 1 if @bag.pockets[i].length > 0
        end
      else
        (1...@bag.pockets.length).each do |i|
          numfilledpockets += 1 if @filterlist[i].length > 0
        end
      end
      lastpocket = (resetpocket) ? 1 : @bag.last_viewed_pocket
      if (@filterlist && @filterlist[lastpocket].length == 0) ||
         (!@filterlist && @bag.pockets[lastpocket].length == 0)
        (1...@bag.pockets.length).each do |i|
          if @filterlist && @filterlist[i].length > 0
            lastpocket = i
            break
          elsif !@filterlist && @bag.pockets[i].length > 0
            lastpocket = i
            break
          end
        end
      end
    end
    @bag.last_viewed_pocket = lastpocket
    
    @sliderbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Bag Party/icon_slider"))
    @pocketbitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/Bag Party/icon_pocket"))
    
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Bag Party/bg")
    @sprites["gradient"] = IconSprite.new(0, 0, @viewport)
    @sprites["gradient"].setBitmap("Graphics/Pictures/Bag Party/grad")
    @sprites["panorama"] = IconSprite.new(0, 0, @viewport)
    @sprites["panorama"].setBitmap("Graphics/Pictures/Bag Party/panorama")
    
    if BagScreenWiInParty::BGSTYLE == 1 # BW Style
      if $player.female?
        @sprites["background"].color = Color.new(243, 140, 169)
        @sprites["gradient"].color = Color.new(255, 37, 97)
        @sprites["panorama"].color = Color.new(255, 37, 97)
      else
        @sprites["background"].color = Color.new(101, 230, 255)
        @sprites["gradient"].color = Color.new(37, 129, 255)
        @sprites["panorama"].color = Color.new(37, 136, 255)
      end
    elsif BagScreenWiInParty::BGSTYLE == 2 # HGSS Style
      pbPocketColor
    end
    @sprites["ui1"] = IconSprite.new(0, 0, @viewport)
    @sprites["ui1"].setBitmap("Graphics/Pictures/Bag Party/ui1")
    @sprites["ui2"] = IconSprite.new(0, 0, @viewport)
    @sprites["ui2"].setBitmap("Graphics/Pictures/Bag Party/ui2")
    
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonBagPartyPanel.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokemonBagPartyBlankPanel.new(@party[i], i, @viewport)
      end
    end
    
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    rbvar = 0
    
    @sprites["pocketicon"] = BitmapSprite.new(130, 52, @viewport)
    @sprites["pocketicon"].x = 372
    @sprites["pocketicon"].y = 0
    
    @sprites["itemlist"] = Window_PokemonBag.new(@bag, @filterlist, lastpocket, 204, 40, 314, 72 + ITEMSVISIBLE * 32)
    @sprites["itemlist"].viewport    = @viewport
    @sprites["itemlist"].pocket      = lastpocket
    @sprites["itemlist"].index       = @bag.last_viewed_index(lastpocket)
    @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemicon"] = ItemIconSprite.new(48, Graphics.height - 46, nil, @viewport)
    @sprites["itemtext"] = Window_UnformattedTextPokemon.newWithSize(
      "", 72, 274, Graphics.width - 72 - 24, 128, @viewport
    )
    @sprites["itemtext"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["itemtext"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["itemtext"].visible     = true
    @sprites["itemtext"].windowskin  = nil
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @viewport
    @sprites["msgwindow"].letterbyletter = true
    pbBottomLeftLines(@sprites["msgwindow"], 2)
    
    pbUpdateAnnotation
    
    pbDeactivateWindows(@sprites)
    pbRefresh
    pbFadeInAndShow(@sprites)
  end

  def pbPocketColor
    case @bag.last_viewed_pocket
    when 1
      @sprites["background"].color = Color.new(233, 152, 189)
      @sprites["gradient"].color = Color.new(255, 37, 187)
      @sprites["panorama"].color = Color.new(213, 89, 141)
    when 2
      @sprites["background"].color = Color.new(233, 161, 152)
      @sprites["gradient"].color = Color.new(255, 134, 37)
      @sprites["panorama"].color = Color.new(224, 112, 56)
    when 3
      @sprites["background"].color = Color.new(233, 197, 152)
      @sprites["gradient"].color = Color.new(255, 177, 37)
      @sprites["panorama"].color = Color.new(200, 136, 32)
    when 4
      @sprites["background"].color = Color.new(216, 233, 152)
      @sprites["gradient"].color = Color.new(194, 255, 37)
      @sprites["panorama"].color = Color.new(128, 168, 32)
    when 5
      @sprites["background"].color = Color.new(175, 233, 152)
      @sprites["gradient"].color = Color.new(78, 255, 37)
      @sprites["panorama"].color = Color.new(32, 160, 72)
    when 6
      @sprites["background"].color = Color.new(152, 220, 233)
      @sprites["gradient"].color = Color.new(37, 212, 255)
      @sprites["panorama"].color = Color.new(24, 144, 176)
    when 7
      @sprites["background"].color = Color.new(152, 187, 233)
      @sprites["gradient"].color = Color.new(37, 125, 255)
      @sprites["panorama"].color = Color.new(48, 112, 224)
    when 8
      @sprites["background"].color = Color.new(178, 152, 233)
      @sprites["gradient"].color = Color.new(145, 37, 255)
      @sprites["panorama"].color = Color.new(144, 72, 216)
    end
  end
  
  def pbFadeOutScene
    @oldsprites = pbFadeOutAndHide(@sprites)
    @oldtext = []
    for i in 0...Settings::MAX_PARTY_SIZE
      @oldtext.push(@sprites["pokemon#{i}"].text)
      @sprites["pokemon#{i}"].dispose
    end
  end
  
  def pbFadeInScene
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonBagPartyPanel.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokemonBagPartyBlankPanel.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = @oldtext[i]
    end
    @oldtext = nil
    pbFadeInAndShow(@sprites, @oldsprites)
    @oldsprites = nil
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) if !@oldsprites
    @oldsprites = nil
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @pocketbitmap.dispose
    @viewport.dispose
  end

  def pbDisplay(text, brief = false)
    @sprites["msgwindow"].text    = text
    @sprites["msgwindow"].visible = true
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @sprites["msgwindow"].busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @sprites["msgwindow"].pausing?
          @sprites["msgwindow"].resume
        end
      else
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          break
        end
      end
    end
    @sprites["msgwindow"].visible = false
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbConfirm(msg)
    UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
  end

  def pbShowCommands(helptext, commands, index = 0)
    return UIHelper.pbShowCommands(@sprites["helpwindow"], helptext, commands, index) { pbUpdate }
  end

  def pbRefresh
    # Draw the pocket icons
    pocketX = [0, 0, 2, 2, 4, 4, 6, 6]      # Each pocket's X coordinates (following a pattern of adding +2 every 2 values)
    pocketAcc = @sprites["itemlist"].pocket # Current pocket
    @sprites["pocketicon"].bitmap.clear
    if @choosing && @filterlist
      (1...@bag.pockets.length).each do |i|
        next if @filterlist[i].length > 0
        pocketValue = i - 1
        @sprites["pocketicon"].bitmap.blt(
          (i - 1) * 14 + pocketX[pocketValue], (i % 2) * 26, @pocketbitmap.bitmap,
          Rect.new((i - 1) * 28, 28, 28, 28)) #Blocked icons
      end
    end
    @sprites["pocketicon"].bitmap.blt((pocketAcc - 1) * 14 + pocketX[pocketAcc - 1], (pocketAcc % 2) * 26,
       @pocketbitmap.bitmap,Rect.new((pocketAcc - 1) * 28, 0, 28, 28)) #Unblocked icons
    # Refresh the item window
    @sprites["itemlist"].refresh
    # Refresh more things
    pbRefreshIndexChanged
    # Refresh party and pockets
    pbRefreshParty
    pbPocketColor if BagScreenWiInParty::BGSTYLE == 2
  end
  
  def pbRefreshParty
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"].pokemon = @party[i]
      else
      end
    end
  end
  
  def pbRefreshIndexChanged
    itemlist = @sprites["itemlist"]
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    # Draw the pocket name
    pbDrawTextPositions(
      overlay,
      [[PokemonBag.pocket_names[@bag.last_viewed_pocket - 1], 297, 18, 2, POCKETNAMEBASECOLOR, POCKETNAMEOUTLINECOLOR, true, Graphics.width]]
    )
    # Draw slider arrows
    showslider = false
    if itemlist.top_row > 0
      overlay.blt(356, 16, @sliderbitmap.bitmap, Rect.new(0, 0, 36, 38))
      showslider = true
    end
    if itemlist.top_item + itemlist.page_item_max < itemlist.itemCount
      overlay.blt(356, 228, @sliderbitmap.bitmap, Rect.new(0, 38, 36, 38))
      showslider = true
    end
    # Draw slider box
    if showslider
      sliderheight = 174
      boxheight = (sliderheight * itemlist.page_row_max / itemlist.row_max).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 38].max
      y = 80
      y += ((sliderheight - boxheight) * itemlist.top_row / (itemlist.row_max - itemlist.page_row_max)).floor
      overlay.blt(484, y, @sliderbitmap.bitmap, Rect.new(36, 0, 36, 4))
      i = 0
      while i * 16 < boxheight - 4 - 18
        height = [boxheight - 4 - 18 - i * 16, 16].min
        overlay.blt(484, y + 4 + i * 16, @sliderbitmap.bitmap, Rect.new(36, 4, 36, height))
        i += 1
      end
      overlay.blt(484, y + boxheight - 18, @sliderbitmap.bitmap, Rect.new(36, 20, 36, 18))
    end
    # Set the selected item's icon
    @sprites["itemicon"].item = itemlist.item
    # Set the selected item's description
    @sprites["itemtext"].text =
      (itemlist.item) ? GameData::Item.get(itemlist.item).description : _INTL("Close bag.")
  end

  def pbRefreshFilter
    @filterlist = nil
    return if !@choosing
    return if @filterproc.nil?
    @filterlist = []
    (1...@bag.pockets.length).each do |i|
      @filterlist[i] = []
      @bag.pockets[i].length.times do |j|
        @filterlist[i].push(j) if @filterproc.call(@bag.pockets[i][j][0])
      end
    end
  end

  def pbHardRefresh
    oldtext = []
    lastselected = -1
    for i in 0...Settings::MAX_PARTY_SIZE
      oldtext.push(@sprites["pokemon#{i}"].text)
      lastselected = i if @sprites["pokemon#{i}"].selected
      @sprites["pokemon#{i}"].dispose
    end
    lastselected = @party.length - 1 if lastselected >= @party.length
    lastselected = 0 if lastselected < 0
    for i in 0...Settings::MAX_PARTY_SIZE
      if @party[i]
        @sprites["pokemon#{i}"] = PokemonBagPartyPanel.new(@party[i], i, @viewport)
      else
        @sprites["pokemon#{i}"] = PokemonBagPartyBlankPanel.new(@party[i], i, @viewport)
      end
      @sprites["pokemon#{i}"].text = oldtext[i]
    end
    pbSelect(lastselected)
  end

  def pbRefreshSingle(i)
    sprite = @sprites["pokemon#{i}"]
    if sprite
      if sprite.is_a?(PokemonBagPartyPanel)
        sprite.pokemon = sprite.pokemon
      else
        sprite.refresh
      end
    end
  end
  
  def pbUpdateAnnotation
    itemwindow = @sprites["itemlist"]
    item = itemwindow.item
    itm = GameData::Item.get(item) if item
    if @bag.last_viewed_pocket == 1 && item #Items Pocket
      annotations = nil
      annotations = []
      if itm.is_evolution_stone?
        for i in $player.party
          elig = i.check_evolution_on_use_item(itm)
          annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
        end
      else
        for i in 0...Settings::MAX_PARTY_SIZE
          @sprites["pokemon#{i}"].text = annotations[i] if  annotations
        end
      end
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = annotations[i] if  annotations
      end
    elsif @bag.last_viewed_pocket == 4 && item #TMs Pocket
      annotations = nil
      annotations = []
      if itm.is_machine?
        machine = itm.move
        move = GameData::Move.get(machine).id
        movelist = nil
        if movelist!=nil && movelist.is_a?(Array)
          for i in 0...movelist.length
            movelist[i] = GameData::Move.get(movelist[i]).id
          end
        end
        $player.party.each_with_index do |pkmn, i|
          if pkmn.egg?
            annotations[i] = _INTL("UNABLE")
          elsif pkmn.hasMove?(move)
            annotations[i] = _INTL("LEARNED")
          else
            species = pkmn.species
            if movelist && movelist.any? { |j| j == species }
              # Checked data from movelist given in parameter
              annotations[i] = _INTL("ABLE")
            elsif pkmn.compatible_with_move?(move)
              # Checked data from Pokémon's tutor moves in pokemon.txt
              annotations[i] = _INTL("ABLE")
            else
              annotations[i] = _INTL("UNABLE")
            end
          end
        end
      else
        for i in @party
          annotations.push((elig) ? _INTL("ABLE") : _INTL("UNABLE"))
        end
      end
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = annotations[i] if  annotations
      end
    else #Others, only show HP
      for i in 0...Settings::MAX_PARTY_SIZE
        @sprites["pokemon#{i}"].text = nil if @sprites["pokemon#{i}"].text 
      end
    end
  end
      
  # Called when the item screen wants an item to be chosen from the screen
  def pbChooseItem
    @sprites["helpwindow"].visible = false
    itemwindow = @sprites["itemlist"]
    thispocket = @bag.pockets[itemwindow.pocket]
    swapinitialpos = -1
    pbActivateWindow(@sprites, "itemlist") {
      loop do
        oldindex = itemwindow.index
        Graphics.update
        Input.update
        pbUpdate
        pbUpdateAnnotation
        if itemwindow.sorting && itemwindow.index >= thispocket.length
          itemwindow.index = (oldindex == thispocket.length - 1) ? 0 : thispocket.length - 1
        end
        if itemwindow.index != oldindex
          # Move the item being switched
          if itemwindow.sorting
            thispocket.insert(itemwindow.index, thispocket.delete_at(oldindex))
          end
          # Update selected item for current pocket
          @bag.set_last_viewed_index(itemwindow.pocket, itemwindow.index)
          pbRefresh
        end
        if itemwindow.sorting
          if Input.trigger?(Input::ACTION) ||
             Input.trigger?(Input::USE)
            itemwindow.sorting = false
            pbPlayDecisionSE
            pbRefresh
          elsif Input.trigger?(Input::BACK)
            thispocket.insert(swapinitialpos, thispocket.delete_at(itemwindow.index))
            itemwindow.index = swapinitialpos
            itemwindow.sorting = false
            pbPlayCancelSE
            pbRefresh
          end
        else
          # Plays SE when scrolling the item list
          if Input.repeat?(Input::UP) && thispocket.length > 0 || 
             Input.repeat?(Input::DOWN) && thispocket.length>0
            pbSEPlay("GUI bag cursor") if itemwindow.index != 0 && itemwindow.index != thispocket.length
          end
          # Change pockets
          if Input.trigger?(Input::LEFT)
            newpocket = itemwindow.pocket
            loop do
              newpocket = (newpocket == 1) ? PokemonBag.pocket_count : newpocket - 1
              break if !@choosing || newpocket == itemwindow.pocket
              if @filterlist
                break if @filterlist[newpocket].length > 0
              elsif @bag.pockets[newpocket].length > 0
                break
              end
            end
            if itemwindow.pocket != newpocket
              itemwindow.pocket = newpocket
              @bag.last_viewed_pocket = itemwindow.pocket
              thispocket = @bag.pockets[itemwindow.pocket]
              pbSEPlay("GUI bag pocket")
              pbRefresh
            end
          elsif Input.trigger?(Input::RIGHT)
            newpocket = itemwindow.pocket
            loop do
              newpocket = (newpocket == PokemonBag.pocket_count) ? 1 : newpocket + 1
              break if !@choosing || newpocket == itemwindow.pocket
              if @filterlist
                break if @filterlist[newpocket].length > 0
              elsif @bag.pockets[newpocket].length > 0
                break
              end
            end
            if itemwindow.pocket != newpocket
              itemwindow.pocket = newpocket
              @bag.last_viewed_pocket = itemwindow.pocket
              thispocket = @bag.pockets[itemwindow.pocket]
              pbSEPlay("GUI bag pocket")
              pbRefresh
            end
          elsif Input.trigger?(Input::SPECIAL)   # Checking party
            if $player.pokemon_count == 0
              pbMessage(_INTL("There is no Pokémon."))
            else
              pbPlayDecisionSE
              itemwindow.partysel = true
              pbRefresh
              pbDeactivateWindows(@sprites){pbChoosePoke(3, false)}
              pbRefresh
            end
          elsif Input.trigger?(Input::ACTION)   # Start switching the selected item
            if !@choosing && thispocket.length > 1 && itemwindow.index < thispocket.length &&
               !Settings::BAG_POCKET_AUTO_SORT[itemwindow.pocket - 1]
              itemwindow.sorting = true
              swapinitialpos = itemwindow.index
              pbPlayDecisionSE
              pbRefresh
            end
          elsif Input.trigger?(Input::BACK)   # Cancel the item screen
            pbPlayCloseMenuSE
            return nil
          elsif Input.trigger?(Input::USE)   # Choose selected item
            (itemwindow.item) ? pbPlayDecisionSE : pbPlayCloseMenuSE
            return itemwindow.item
          end
        end
      end
    }
  end

  def pbSetHelpText(helptext)
    helpwindow = @sprites["helpwindow"]
    pbBottomLeftLines(helpwindow,1)
    helpwindow.text = helptext
    helpwindow.width = 398
    helpwindow.visible = true
  end

  def pbChangeSelection(key,currentsel)
    numsprites = @party.length - 1
    case key
    when Input::LEFT
      begin
        currentsel -= 1
      end while currentsel >= 0 && currentsel < @party.length && !@party[currentsel]
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = @party.length - 1
      end
      currentsel = numsprites if currentsel < 0 || currentsel > numsprites
    when Input::RIGHT
      begin
        currentsel += 1
      end while currentsel < @party.length && !@party[currentsel]
      currentsel = 0 if currentsel == @party.length
    when Input::UP
      if currentsel > numsprites
        currentsel -= 1
        while currentsel > 0 && currentsel < numsprites && !@party[currentsel]
          currentsel -= 1
        end 
      else
        begin
          currentsel -= 2
        end while currentsel > 0 && !@party[currentsel]
      end
      if currentsel > numsprites && currentsel < numsprites
        currentsel = numsprites
      end
      currentsel = numsprites if currentsel < 0
    when Input::DOWN
      if currentsel >= Settings::MAX_PARTY_SIZE - 1
        currentsel += 1
      else
        currentsel += 2
        currentsel = Settings::MAX_PARTY_SIZE if currentsel < Settings::MAX_PARTY_SIZE && !@party[currentsel]
      end
      if currentsel >= @party.length && currentsel < Settings::MAX_PARTY_SIZE
        currentsel = Settings::MAX_PARTY_SIZE
      elsif currentsel > numsprites
        currentsel = 0
      end
    end
    return currentsel
  end
  
  def pbChangeCursor(number)
    itemwindow = @sprites["itemlist"]
    if number == 1
      itemwindow.partysel = true
    elsif number == 2
      itemwindow.partysel = false
    end
    pbRefresh
  end
  
  def pbChoosePoke(option, switching = false)
    # 0 to choose a Pokémon; 1 to hold an item; 2 to use an item; 3 to interact; 4 to switch party items
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].preselected = (switching && i == @activecmd)
      @sprites["pokemon#{i}"].switching   = switching
    end
    @sprites["pokemon#{@activecmd}"].selected = false if switching
    @activecmd = 0
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].selected = (i == @activecmd)
    end
    itemwindow = @sprites["itemlist"]
    item = itemwindow.item
    pbChangeCursor(1)
    loop do
      Graphics.update
      Input.update
      pbUpdate
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN) && @party.length > 2
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP) && @party.length > 2
      if key >= 0 && @party.length > 1
        @activecmd = pbChangeSelection(key, @activecmd)
      end
      if @activecmd != oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = Settings::MAX_PARTY_SIZE
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i == @activecmd)
        end
      end
      if Input.trigger?(Input::C)
        pkmn = @party[@activecmd]
        if option == 0 # Choose
          return @activecmd
        elsif option == 1 # Hold
          if @activecmd >= 0
            ret = pbGiveItemToPokemon(item, @party[@activecmd], self, @activecmd)
            pbChangeCursor(2)
            @sprites["pokemon#{@activecmd}"].selected = false
            break
          end
        elsif option == 2 # Use
          ret = pbBagUseItem(@bag, item, PokemonBagScreen, self, @activecmd)
          pbRefresh; pbUpdateAnnotation
          if !$bag.has?(item)
            @sprites["pokemon#{@activecmd}"].selected = false
            pbChangeCursor(2)
            break
          end
        elsif option == 3 # Interaction
          pbPlayDecisionSE
          loop do
            cmdSummary     = -1
            cmdTake        = -1 
            cmdMove        = -1
            commands = []
            # Generate command list
            commands[cmdSummary = commands.length]       = _INTL("Summary")
            commands[cmdTake = commands.length]          = _INTL("Take Item") if pkmn.hasItem?
            commands[cmdMove = commands.length]          = _INTL("Move Item") if pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?
            commands[commands.length]                    = _INTL("Cancel")
            # Show commands generated above
            if pkmn.hasItem?
              item = pkmn.item
              itemname = item.name
              command = pbShowCommands(_INTL("{1} is holding {2}.", pkmn.name, itemname), commands)
            else
              command = pbShowCommands(_INTL("{1} is selected.", pkmn.name), commands)
            end
            if cmdSummary >= 0 && command == cmdSummary   # Summary
              pbSummary(@activecmd)
            elsif cmdTake >= 0 && command == cmdTake && pkmn.hasItem?  # Take item
              if pbTakeItemFromPokemon(pkmn, self)
                pbRefresh
              end
              break
            elsif cmdMove >= 0 && command == cmdMove && pkmn.hasItem? && !GameData::Item.get(pkmn.item).is_mail?  # Move item
              oldpkmn = pkmn
              loop do
                pbPreSelect(oldpkmn)
                newpkmn = pbChoosePoke(4, true)
                if newpkmn < 0
                  pbClearSwitching
                  break 
                end
                newpkmn = @party[newpkmn]
                if newpkmn == oldpkmn
                  pbClearSwitching
                  break 
                end
                if newpkmn.egg?
                  pbDisplay(_INTL("Eggs can't hold items."))
                elsif !newpkmn.hasItem?
                  newpkmn.item = item
                  oldpkmn.item = nil
                  pbClearSwitching; pbRefresh
                  pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                  break
                elsif GameData::Item.get(newpkmn.item).is_mail?
                  pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", newpkmn.name))
                else
                  newitem = newpkmn.item
                  newitemname = newitem.name
                  if newitem == :LEFTOVERS
                    pbDisplay(_INTL("{1} is already holding some {2}.\1", newpkmn.name, newitemname))
                  elsif newitemname.starts_with_vowel?
                    pbDisplay(_INTL("{1} is already holding an {2}.\1", newpkmn.name, newitemname))
                  else
                    pbDisplay(_INTL("{1} is already holding a {2}.\1", newpkmn.name, newitemname))
                  end
                  if pbConfirm(_INTL("Would you like to switch the two items?"))
                    newpkmn.item = item
                    oldpkmn.item = newitem
                    pbClearSwitching; pbRefresh
                    pbDisplay(_INTL("{1} was given the {2} to hold.", newpkmn.name, itemname))
                    pbDisplay(_INTL("{1} was given the {2} to hold.", oldpkmn.name, newitemname))
                  end
                  break
                end
              end
              break
            else
              break
            end
          end
        elsif option == 4 # Interaction for switching item
          return @activecmd
        end
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        itemwindow.partysel = false; pbRefresh
        if switching
          return -1
        elsif option == 0
          @sprites["pokemon#{@activecmd}"].selected = false
          return -1
        else
          @sprites["pokemon#{@activecmd}"].selected = false
          return
        end
      end
      break if ret == 2 && option == 2  # End screen
    end
  end
  
  def pbChoosePokemon(text = nil)
    # For fusing/unfusing Pokemon
    fusioncmd  = @activecmd
    @activecmd = 0
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].selected = (i == @activecmd)
    end
    @sprites["pokemon#{fusioncmd}"].selected = true
    loop do
      Graphics.update
      Input.update
      pbUpdate
      oldsel = @activecmd
      key = -1
      key = Input::DOWN if Input.repeat?(Input::DOWN) && @party.length > 2
      key = Input::RIGHT if Input.repeat?(Input::RIGHT)
      key = Input::LEFT if Input.repeat?(Input::LEFT)
      key = Input::UP if Input.repeat?(Input::UP) && @party.length > 2
      if key >= 0 && @party.length > 1
        @activecmd = pbChangeSelection(key,@activecmd)
      end
      if @activecmd != oldsel   # Changing selection
        pbPlayCursorSE
        numsprites = Settings::MAX_PARTY_SIZE
        for i in 0...numsprites
          @sprites["pokemon#{i}"].selected = (i == @activecmd)
        end
        @sprites["pokemon#{fusioncmd}"].selected = true
      end
      if Input.trigger?(Input::C)
        @sprites["pokemon#{fusioncmd}"].selected = false if fusioncmd != @activecmd
        return @activecmd
      elsif Input.trigger?(Input::B)
        pbPlayCancelSE
        @sprites["pokemon#{fusioncmd}"].selected = false if fusioncmd != @activecmd
        return -1
      end
    end
  end
  
  def pbSummary(pkmnid, inbattle=false)
    oldsprites = pbFadeOutAndHide(@sprites)
    scene = PokemonSummary_Scene.new
    screen = PokemonSummaryScreen.new(scene,inbattle)
    screen.pbStartScreen(@party,pkmnid)
    yield if block_given?
    pbFadeInAndShow(@sprites,oldsprites)
  end

  def pbSelect(item)
    @activecmd = item
    numsprites = Settings::MAX_PARTY_SIZE
    for i in 0...numsprites
      @sprites["pokemon#{i}"].selected = (i == @activecmd)
    end
  end
  
  def pbPreSelect(item)
    @othercmd = item
  end

  def pbClearSwitching
    for i in 0...Settings::MAX_PARTY_SIZE
      @sprites["pokemon#{i}"].preselected = false
      @sprites["pokemon#{i}"].switching   = false
    end
  end
  
  def pbChooseMove(pokemon, helptext, index = 0)
    movenames = []
    pokemon.moves.each do |i|
      next if !i || !i.id
      if i.total_pp <= 0
        movenames.push(_INTL("{1} (PP: ---)", i.name))
      else
        movenames.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
      end
    end
    return pbShowCommands(helptext,movenames,index)
  end
end

#===============================================================================
# Bag mechanics
#===============================================================================
class PokemonBagScreen
  def initialize(scene, bag)
    @bag   = bag
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene(@bag, $player.party)
    item = nil
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      cmdRead     = -1
      cmdUse      = -1
      cmdRegister = -1
      cmdGive     = -1
      cmdToss     = -1
      cmdDebug    = -1
      commands = []
      # Generate command list
      commands[cmdRead = commands.length]       = _INTL("Read") if itm.is_mail?
      if ItemHandlers.hasOutHandler(item) || (itm.is_machine? && $player.party.length > 0)
        if ItemHandlers.hasUseText(item)
          commands[cmdUse = commands.length]    = ItemHandlers.getUseText(item)
        else
          commands[cmdUse = commands.length]    = _INTL("Use")
        end
      end
      commands[cmdGive = commands.length]       = _INTL("Give") if $player.pokemon_party.length > 0 && itm.can_hold?
      commands[cmdToss = commands.length]       = _INTL("Toss") if !itm.is_important? || $DEBUG
      if @bag.registered?(item)
        commands[cmdRegister = commands.length] = _INTL("Deselect")
      elsif pbCanRegisterItem?(item)
        commands[cmdRegister = commands.length] = _INTL("Register")
      end
      commands[cmdDebug = commands.length]      = _INTL("Debug") if $DEBUG
      commands[commands.length]                 = _INTL("Cancel")
      # Show commands generated above
      itemname = itm.name
      command = @scene.pbShowCommands(_INTL("{1} is selected.", itemname), commands)
      if cmdRead >= 0 && command == cmdRead   # Read mail
        pbFadeOutIn {
          pbDisplayMail(Mail.new(item, "", ""))
        }
      elsif cmdUse >= 0 && command == cmdUse   # Use item
        useType = itm.field_use
        # ret: 0 = Item wasn't used; 1 = Item used; 2 = Close Bag to use in field
        if useType == 1 # Consumables
          ret = @scene.pbChoosePoke(2, false)
        elsif useType == 3 || useType == 4 || useType == 5 # TM, HM and TR
          machine = itm.move
          movename = GameData::Move.get(machine).name
          pbMessage(_INTL("\\se[PC access]You booted up {1}.\1", itm.name)) {@scene.pbUpdate}
          if pbConfirmMessage(_INTL("Do you want to teach {1} to a Pokémon?", movename)) {@scene.pbUpdate}
            ret = @scene.pbChoosePoke(2, false)
          end
        else
          ret = pbUseItem(@bag, item, @scene)
        end
        break if ret == 2   # End screen
        @scene.pbRefresh
        next
      elsif cmdGive >= 0 && command == cmdGive   # Give item to Pokémon
        if $player.pokemon_count == 0
          @scene.pbDisplay(_INTL("There is no Pokémon."))
        elsif itm.is_important?
          @scene.pbDisplay(_INTL("The {1} can't be held.",itemname))
        else
          @scene.pbChoosePoke(1, false)
        end
      elsif cmdToss >= 0 && command == cmdToss   # Toss item
        qty = @bag.quantity(item)
        if qty > 1
          helptext = _INTL("Toss out how many {1}?", itm.name_plural)
          qty = @scene.pbChooseNumber(helptext, qty)
        end
        if qty > 0
          itemname = itm.name_plural if qty > 1
          if pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
            pbDisplay(_INTL("Threw away {1} {2}.",qty,itemname))
            @bag.remove(item, qty)
            @scene.pbRefresh
          end
        end
      elsif cmdRegister >= 0 && command == cmdRegister   # Register item
        if @bag.registered?(item)
          @bag.unregister(item)
        else
          @bag.register(item)
        end
        @scene.pbRefresh
      elsif cmdDebug >= 0 && command == cmdDebug   # Debug
        command = 0
        loop do
          command = @scene.pbShowCommands(_INTL("Do what with {1}?", itemname),
                                          [_INTL("Change quantity"),
                                           _INTL("Make Mystery Gift"),
                                           _INTL("Cancel")], command)
          case command
          ### Cancel ###
          when -1, 2
            break
          ### Change quantity ###
          when 0
            qty = @bag.quantity(item)
            itemplural = itm.name_plural
            params = ChooseNumberParams.new
            params.setRange(0, Settings::BAG_MAX_PER_SLOT)
            params.setDefaultValue(qty)
            newqty = pbMessageChooseNumber(
              _INTL("Choose new quantity of {1} (max. #{Settings::BAG_MAX_PER_SLOT}).",itemplural),params
              ) { @scene.pbUpdate }
            if newqty > qty
              @bag.add(item, newqty - qty)
            elsif newqty < qty
              @bag.remove(item, qty - newqty)
            end
            @scene.pbRefresh
            break if newqty == 0
          ### Make Mystery Gift ###
          when 1
            pbCreateMysteryGift(1, item)
          end
        end
      end
    end
    ($game_temp.fly_destination) ? @scene.dispose : @scene.pbEndScene
    return item
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  # UI logic for the item screen for choosing an item.
  def pbChooseItemScreen(proc = nil)
    oldlastpocket = @bag.last_viewed_pocket
    oldchoices = @bag.last_pocket_selections.clone
    @scene.pbStartScene(@bag, $player.party, true, proc)
    item = @scene.pbChooseItem
    @scene.pbEndScene
    @bag.last_viewed_pocket = oldlastpocket
    @bag.last_pocket_selections = oldchoices
    return item
  end

  # UI logic for withdrawing an item in the item storage screen.
  def pbWithdrawItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage,$player.party)
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      qty = storage.quantity(item)
      if qty > 1 && !itm.is_important?
        qty = @scene.pbChooseNumber(_INTL("How many do you want to withdraw?"), qty)
      end
      next if qty <= 0
      if @bag.can_add?(item, qty)
        if !storage.remove(item, qty)
          raise "Can't delete items from storage"
        end
        if !@bag.add(item, qty)
          raise "Can't withdraw items from storage"
        end
        @scene.pbRefresh
        dispqty = (itm.is_important?) ? 1 : qty
        itemname = (dispqty > 1) ? itm.name_plural : itm.name
        pbDisplay(_INTL("Withdrew {1} {2}.", dispqty, itemname))
      else
        pbDisplay(_INTL("There's no more room in the Bag."))
      end
    end
    @scene.pbEndScene
  end

  # UI logic for depositing an item in the item storage screen.
  def pbDepositItemScreen
    @scene.pbStartScene(@bag,$player.party)
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      qty = @bag.quantity(item)
      if qty > 1 && !itm.is_important?
        qty = @scene.pbChooseNumber(_INTL("How many do you want to deposit?"), qty)
      end
      if qty > 0
        if storage.can_add?(item, qty)
          if !@bag.remove(item, qty)
            raise "Can't delete items from Bag"
          end
          if !storage.add(item, qty)
            raise "Can't deposit items to storage"
          end
          @scene.pbRefresh
          dispqty  = (itm.is_important?) ? 1 : qty
          itemname = (dispqty > 1) ? itm.name_plural : itm.name
          pbDisplay(_INTL("Deposited {1} {2}.", dispqty, itemname))
        else
          pbDisplay(_INTL("There's no room to store items."))
        end
      end
    end
    @scene.pbEndScene
  end

  # UI logic for tossing an item in the item storage screen.
  def pbTossItemScreen
    if !$PokemonGlobal.pcItemStorage
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
    end
    storage = $PokemonGlobal.pcItemStorage
    @scene.pbStartScene(storage,$player.party)
    loop do
      item = @scene.pbChooseItem
      break if !item
      itm = GameData::Item.get(item)
      if itm.is_important?
        @scene.pbDisplay(_INTL("That's too important to toss out!"))
        next
      end
      qty = storage.quantity(item)
      itemname       = itm.name
      itemnameplural = itm.name_plural
      if qty > 1
        qty = @scene.pbChooseNumber(_INTL("Toss out how many {1}?", itemnameplural), qty)
      end
      next if qty <= 0
      itemname = itemnameplural if qty > 1
      next if !pbConfirm(_INTL("Is it OK to throw away {1} {2}?", qty, itemname))
      if !storage.remove(item, qty)
        raise "Can't delete items from storage"
      end
      @scene.pbRefresh
      pbDisplay(_INTL("Threw away {1} {2}.", qty, itemname))
    end
    @scene.pbEndScene
  end
end

#=============================================================================
# New function for using an item
#=============================================================================
# @return [Integer] 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbBagUseItem(bag, item, scene, screen, chosen, bagscene=nil)
  found   = false
  pkmn    = $player.party[chosen]
  itm     = GameData::Item.get(item)
  useType = itm.field_use
  qty     = 1
  if itm.is_machine?    # TM, HM or TR
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon.")) { screen.pbUpdate }
      return 0
    end
    machine = itm.move
    return 0 if !machine
    movename = GameData::Move.get(machine).name
    move     = GameData::Move.get(machine).id
    movelist = nil; bymachine = false; oneusemachine = false
    if movelist != nil && movelist.is_a?(Array)
      for i in 0...movelist.length
        movelist[i] = GameData::Move.get(movelist[i]).id
      end
    end
    if pkmn.egg?
      pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
    elsif pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
    elsif movelist && !movelist.any? { |j| j == pkmn.species }
      pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { screen.pbUpdate }
    elsif !pkmn.compatible_with_move?(move)
      pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { screen.pbUpdate }
    else
      if pbLearnMove(pkmn, move, false, bymachine) { screen.pbUpdate }
        pkmn.add_first_move(move) if oneusemachine
        bag.remove(itm) if itm.consumed_after_use?
      end
    end
    screen.pbRefresh; screen.pbUpdate
    return 1
  elsif useType == 1 # Item is usable on a Pokémon
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon.")) { screen.pbUpdate }
      return 0
    end
    ret = false
    screen.pbRefresh
    if pbCheckUseOnPokemon(item, pkmn, screen)
      ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
      if ret && useType == 1 # Usable on Pokémon, consumed
        $bag.remove(item, qty)  if itm.consumed_after_use? { screen.pbRefresh }
      end
      if !$bag.has?(item)
        screen.pbDisplay(_INTL("You used your last {1}.", itm.name)) { screen.pbUpdate }
        screen.pbChangeCursor(2)
      end
      screen.pbRefresh
    end
    bagscene.pbRefresh if bagscene
    return 1
  else
    pbMessage(_INTL("Can't use that here.")) { screen.pbUpdate }
    return 0
  end
end

#=============================================================================
# Reprogamming Sacred Ash to work with the party from the bag
#=============================================================================
ItemHandlers::UseInField.add(:SACREDASH, proc { |item|
  if $player.pokemon_count == 0
    pbMessage(_INTL("There is no Pokémon."))
    next false
  end
  canrevive = false
  $player.pokemon_party.each do |i|
    next if !i.fainted?
    canrevive = true
    break
  end
  if !canrevive
    pbMessage(_INTL("It won't have any effect."))
    next false
  end
  revived = 0
  $player.party.each_with_index do |pkmn, i|
    next if !pkmn.fainted?
    revived += 1
    pkmn.heal
  end
  if revived > 1
    pbMessage(_INTL("Your fainted Pokémon's HP were restored."))
  elsif revived == 1
    pbMessage(_INTL("Your fainted Pokémon's HP was restored."))
  end
  next (revived > 0)
})

#=============================================================================
# Battle scene for openning the Bag screen and choosing an item to use
#=============================================================================
class Battle::Scene
  def pbItemMenu(idxBattler, _firstAction)
    # Fade out and hide all sprites
    visibleSprites = pbFadeOutAndHide(@sprites)
    # Set Bag starting positions
    oldLastPocket = $bag.last_viewed_pocket
    oldChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = @bagLastPocket if @bagLastPocket
    $bag.last_pocket_selections = @bagChoices if @bagChoices
    # Setting up the party and starting the Bag screen
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($bag, modParty, true,
                           proc { |item|
                             useType = GameData::Item.get(item).battle_use
                             next useType && useType > 0
                           }, false)
    # Loop while in Bag screen
    wasTargeting = false
    loop do
      # Select an item
      item = itemScene.pbChooseItem
      break if !item
      # Choose a command for the selected item
      item = GameData::Item.get(item)
      itemName = item.name
      useType = item.battle_use
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
      commands[commands.length]          = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.", itemName), commands)
      next unless cmdUse >= 0 && command == cmdUse   # Use
      # Use types:
      # 0 = not usable in battle
      # 1 = use on Pokémon (lots of items, Blue Flute)
      # 2 = use on Pokémon's move (Ethers)
      # 3 = use on battler (X items, Persim Berry, Red/Yellow Flutes)
      # 4 = use on opposing battler (Poké Balls)
      # 5 = use no target (Poké Doll, Guard Spec., Poké Flute, Launcher items)
      case useType
      when 1, 2, 3   # Use on Pokémon/Pokémon's move/battler
        # Auto-choose the Pokémon/battler whose action is being decided if they
        # are the only available Pokémon/battler to use the item on
        case useType
        when 1   # Use on Pokémon
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3   # Use on battler
          if @battle.pbPlayerBattlerCount == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        # Get player's party
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        # Start Pokémon selection
        idxParty = -1
        # Loop while in party screen
        loop do
          # Select a Pokémon
          pbPlayDecisionSE; idxParty = itemScene.pbChoosePoke(0,false)
          break if idxParty < 0
          idxPartyRet = -1
          partyPos.each_with_index do |pos, i|
            next if pos != idxParty + partyStart
            idxPartyRet = i
            break
          end
          next if idxPartyRet < 0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType == 2   # Use on Pokémon's move
            idxMove = itemScene.pbChooseMove(pkmn,_INTL("Restore which move?"))
            next if idxMove < 0
          end
          break if yield item.id, useType, idxPartyRet, idxMove, itemScene
        end
        # Cancelled choosing a Pokémon; show the Bag screen again
        break if idxParty >= 0
      when 4   # Use on opposing battler (Poké Balls)
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler) == 1
          @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
          break if yield item.id, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          # Fade out and hide Bag screen
          itemScene.pbFadeOutScene
          # Fade in and show the battle screen, choosing a target
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), tempVisibleSprites)
          if idxTarget >= 0
            break if yield item.id, useType, idxTarget, -1, self
          end
          # Target invalid/cancelled choosing a target; show the Bag screen again
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          itemScene.pbFadeInScene
        end
      when 5   # Use with no target
        break if yield item.id, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $bag.last_viewed_pocket
    @bagChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = oldLastPocket
    $bag.last_pocket_selections = oldChoices
    # Close Bag screen
    itemScene.pbEndScene
    # Fade back into battle screen (if not already showing it)
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end
end