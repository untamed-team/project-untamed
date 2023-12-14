#==============================================================================
# * Scene_Credits
#------------------------------------------------------------------------------
# Scrolls the credits you make below. Original Author unknown.
#
## Edited by MiDas Mike so it doesn't play over the Title, but runs by calling
# the following:
#    $scene = Scene_Credits.new
#
## New Edit 3/6/2007 11:14 PM by AvatarMonkeyKirby.
# Ok, what I've done is changed the part of the script that was supposed to make
# the credits automatically end so that way they actually end! Yes, they will
# actually end when the credits are finished! So, that will make the people you
# should give credit to now is: Unknown, MiDas Mike, and AvatarMonkeyKirby.
#                                             -sincerly yours,
#                                               Your Beloved
# Oh yea, and I also added a line of code that fades out the BGM so it fades
# sooner and smoother.
#
## New Edit 24/1/2012 by Maruno.
# Added the ability to split a line into two halves with <s>, with each half
# aligned towards the centre. Please also credit me if used.
#
## New Edit 22/2/2012 by Maruno.
# Credits now scroll properly when played with a zoom factor of 0.5. Music can
# now be defined. Credits can't be skipped during their first play.
#
## New Edit 25/3/2020 by Maruno.
# Scroll speed is now independent of frame rate. Now supports non-integer values
# for SCROLL_SPEED.
#
## New Edit 21/8/2020 by Marin.
# Now automatically inserts the credits from the plugins that have been
# registered through the PluginManager module.
#
## New Edit 9/10/2022 by Gardenette.
#Now if you want to display a graphic next to someone's name in the credits,
#just have a file named after the person's name in Graphics/Pictures/Credits
#Example: If I want a graphic to display next to "Gardenette" in the credits, I
#would have a file named "Gardenette.png" in Graphics/Pictures/Credits
#==============================================================================
class Scene_Credits
  # Backgrounds to show in credits. Found in Graphics/Titles/ folder
  BACKGROUNDS_LIST       = ["credits1", "credits2", "credits3", "credits4", "credits5"]
  BGM                    = "Credits - Kiseki Knot"
  SCROLL_SPEED           = 60   # Pixels per second, was 40
  SECONDS_PER_BACKGROUND = 11
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR      = Color.new(0, 0, 0, 100)
  
  #timer before you can skip credits
  @@timer = 0

  # This next piece of code is the credits.
  # Start Editing
  CREDIT = <<_END_
Main Development Team:
BlueLightning
Chespin_Craft
Gardenette
Kaloja
Kutas Kitti
Lovely Werewolf
Low
Merry
mhm
SpaceWestern
Spork
stygma










Battle Animations
----
ardicoozer
BellBlitzKing
DarryBD99
Reborn team
riddlemeree
StCooler
WolfPP










Graphics
--------
Tilesets:
aball
Aveon Trainer
Banana 'Eduardo' Toast
BE_Infinity
Cristata
Derlo
Donlawride
Gearjuice
GreenJellybean
Griffin L.
Jackeroni216
Kaloja
King Tapia
Kutas Kitti
Magiscarf
Pint Sized Kiwi
PokemonEclipse
PrincessPhoenix
Rider Dragon
Saltilton
Seiyouh
ShadySheep
stygma
the.sizzlepanda
Tinytrashing
Tyler Jones
VentesTheFloof

Pokémon & Pokédex:
8xviktor
A Slime Psycho
aball
Akikaze
Applesaucior
Banana 'Eduardo' Toast
Bean Soup
Chespin_Craft
Chromatech01
Claire
Cristata
Dan Bacon
Eshan
Evelyn315
farbol234
Fikolyte
Firedude
Floriak
GamerCroc11
Griffin L.
Grimrose
HingisDingus
Hub-Bub
The Picky Pixel Artist
Igor!
I'm Para
Jack
Jeremy K
KameOtaku
Loretze
Lorka_Grey
LuckyBenjamin
MadMillerMiller
MasterMachi
painT
Pelican
Regal-Turtwig
RockTomb
Saltilton
ShadySheep
SietseML
Sodacat
Solvaa
SomeAllay
SoundJack426
Spork
Venom_
VentesTheFloof
Waterleaf
WillTheWall

Trainers/NPCs:
aball
Akikaze
BamBoshBubb
Chespin_Craft
Claire
Cristata
Gardenette
Gearjuice
HingisDingus
HwiteHwale
Jack
KameOtaku
Loretze
MadMillerMiller
MILKMAN
Omegabroski2
Owoodfin
RockTomb
Saltilton
Spork
TheFallenRoyal
VentesTheFloof

UI & Misc.:
aball
Adam B.
Basalte
Chespin_Craft
Cristata
Dan Bacon
DomTom
Fikolyte
Gardenette
HwiteHwale
Jackster
Jeremy K
MadMillerMiller
MasterMachi
Owoodfin
Random Talking Bush
Riot
Saltilton
Tyler (MANGO) Jackson
WolfPP










Music
-----
Soundtrack:
EntityUnknown
FNaF 6
Jumpluff
Laminnanne
Lovely Werewolf
mhm
Pokémon Clover
Purple Hat of Awesome
ReMX
Rhythm Break



Pokémon Cries:
Gardenette
Hummus
mhm
Text 206










Mapping
-------
Gardenette
GreenJellybean
ImaDeadMan
Kaloja
Kameleron
Kutas Kitti
MadMillerMiller
Merry
RISH
Shadows
stygma
Tyler (MANGO) Jackson










Eventing
--------
Gardenette
Kaloja
Kutas Kitti
Low
SpaceWestern
stygma










Story & Quests
--------------
Angel
Bean Soup
BlueLightning
Deino
Firedude
Gardenette
HwiteHwale
Kameleron
Kyl-E
Luc_
LuckyBenjamin
MasterMachi
Merry
PaperTowelDealer
Scandal
Shilo
sneakysnek
stygma
ThisGrainCharacter
Tyler Bland
Yadriel J. Vento (HypnosEmblem)










Game Data & Balancing
---------------------
Adam B.
Amber W
caesar
DomTom
Elm
Empyrean
FIE.F
Gardenette
Garreon
Hare64
HwiteHwale
Kyl-E
Low
LuckyBenjamin
MacheteMcGoo
Malarkey
Merry
Midbus
mSilk
noahthenumbat
PaperTowelDealer
ParaBellum
Robochef9000
Scandal
Señor Gallo de Caballo
Shadows
SpaceWestern
stygma
Waffler
Zyuran










Translating
-----------
Abstractpuppet
Aelvric
Basalte
Cawa/Sasha
Deli
Elm
Fitch
Floriak
Hey
Myztic
Slepoy
stygma
Truegear
Wowo
Zylber7










Playtesting
-----------
B_Creative
BlueLightning
Cawa/Sasha
Chespin_Craft
das5198
j
Jamadxx
Merry
Saltilton
stygma
Tom Buenbarril
VentesTheFloof










Team Organization
-----------------
Firedude
Gardenette
HingisDingus
Kutas Kitti
Luc_
MasterMachi
stygma










Wiki
----
B_Creative
Chespin_Craft
Chroma
Low










Mazah Region Created by
-----------------------
Claire
Jack
Subjectively Group










Scripts & Coding
----------------
Advanced Map Transfers:
Luka S.J.

Advanced Pathfinder
Blizzard
khkramer

Advanced Pokédex:
FL

Always in Bushes:
KleinStudio
Kotaro

Ambient Pokémon Cries:
SpaceWestern
Vendily

Arcky's Region Map:
Arcky

Astralneko's Scripting Utilities:
Astralneko

Auto Healing
Dracarys

Auto Multi Save
http404error

Automatic Level Scaling:
Benitex

Bag Screen with Interactable Party:
DiegoWT
Rose
Vendily

Berry Pots:
Caruban
DerxwnaKapsyla

Better Item Finder:
Kotaro

Better Region Map:
Boonzeet
Marin

DiegoWT's Starter Selection:
DiegoWT

DPPT Gender Selector Scene:
A.Somersault

Easy Text Skip:
Amethyst
ENLS
Kurotsune

Easy Mouse System:
Luka S.J.

Enhanced UI:
BlueEye007
Lucidious89
Poq

Evolve from Party:
eriedaberrie
IndianAnimator

EVs and IVs in Summary:
Deoxysprime

Extra Fogs & Panorama Lock:
Game_Guy
Gardenette
Jaiden

Following Pokémon EX:
Akizakura16
Armin
Gardenette
Golisopod User
Help-14
Maruno
mej71
PurpleZaffre
Rayd12smitty
Thundaga
Vendily
Venom12
zingzags

Item Find:
Boonzeet

Location Signposts:
carmaniac
Golisopod User
LostSoulsDev
PurpleZaffre

Luka's Scripting Utilities:

Marin's Enhanced Staircases
Marin

Marin's Map Exporter:
Marin

Marin's Scripting Utilities:
Marin

Modern Quest System + UI:
Black Mage
derFischae
drago2308
Gardenette
Marin
mej71
SpaceWestern
ThatWelshOne_
Vendily

Monitor Icons:
bo4p5687
Gardenette
Marin
Maruno
Nuri Yuri
PurpleZaffre
raZ
Savordez
SpaceWestern
ThatWelshOne_
Ulithium_Dragon
Vendily

Name-box:
Gardenette
Golisopod User
mej71
Mr.Gela (theo#7722)
Vendily

New DexNav:
Low
Marin
NuriYuri
Phantombass
raZ
Savordez
suzerain
ThatWelshOne_
Vendily
Zaffre

No Auto Evolve:
Gardenette
TimeAxis

Overworld Shadows EX:
Golisopod User
Marin
Wolf PP

Poké Ball Swap:
TechSkylander1518

Pokémon Amie:
BhagyaJyoti
bo4p5687
Luka S.J
PizzaSun
rigbycwts

PokéVial
Voltseon
qin2500

Quicksave:
Low

Relearner from Party:
Marin

Save File Calls:
TechSkylander1518

Set the Controls Screen:
FL

Speed Up 2.0:
Marin
Phantombass

Step on Spot OW Animation:
Boonzeet

Tileset Rearranger:
Maruno

Tutor.net
DemICE

Tweaks to Essentials:
Derxwna Kapsyla

Video with Using Gif:
bo4p5687

Voltseon's A-Star Pathfinding:
ENLS
Golisopod User
Voltseon

Voltseon's Pause Menu:
ENLS
Golisopod User
Voltseon










Special Thanks
--------------

Chroma and all the other devs from the Kaskade Region

Pokémon Essentials was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby
Marin
Boushy
MiDas Mike
Brother1440
Near Fantastica
FL.
PinkMan
Genzai Kawakami
Popper
Golisopod User
Rataime
help-14
Savordez
IceGod64
SoundSpawn
Jacob O. Wobbrock
the__end
KitsuneKouta
Venom12
Lisa Anthony
Wachunga
Luka S.J.
Derxwna Kapsyla
and everyone else who helped out

mkxp-z by:
Roza
Based on MKXP by Ancurio et al.

RPG Maker XP by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak



This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}
_END_
# Stop Editing

  def main
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    @counter = 0.0   # Counts time elapsed since the background image changed
    @bg_index = 0
    @bitmap_height = Graphics.height   # For a single credits text bitmap
    @trim = Graphics.height / 10
    # Number of game frames per background frame
    @realOY = -(Graphics.height - @trim)
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
      @credit_lines = CREDIT.split(/\n/)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << pcred[0] + "\n"
        i = 1
        until i >= pcred.size
          plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << name + "\n" }
      end
      plugin_credits << "\n"
    end
  

    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    @text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    @text_viewport.z = 99999
    
    @background_sprite = IconSprite.new(0, 0)
    @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[0])
    @credit_sprites = []
    @contributor_sprites = {}
    @total_height = @credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (@credit_lines.size.to_f / lines_per_bitmap).ceil
    #@line_height = -18
    @line_height = -18
    @name_iteration = 0
    #the graphic will display to the left of the name initially, then go to the
    #right, then left, and so on
    @graphic_side = 0
    
    @sprites = {}
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    #number of seconds required to pass before the skip button is available
    @skip_seconds = 15
    @sprites["skip"] = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    #Sets a bitmap's font to the system font.
    pbSetSystemFont(@sprites["skip"].bitmap)
    text = _INTL("{1}: Skip",$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name)
    pbDrawTextPositions(@sprites["skip"].bitmap,[[text,20,Graphics.height-36,0,TEXT_BASE_COLOR,TEXT_SHADOW_COLOR]])
    @sprites["skip"].opacity = 0
    
    for i in 0...num_bitmaps
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height)
      #Sets a bitmap's font to the system font.
      pbSetSystemFont(credit_bitmap)
      for j in 0...lines_per_bitmap
        line = @credit_lines[i * lines_per_bitmap + j]
        #added by Gardenette
        @line_height += 16
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1   # Centre align
        linewidth = Graphics.width
        for k in 0...line.length
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + Graphics.width / 2
            align = (k == 0) ? 2 : 0   # Right align : left align
            linewidth = Graphics.width / 2 - 20
          end

          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos,     j * 32 + 8, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_OUTLINE_COLOR
          credit_bitmap.draw_text(xpos + 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 - 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32,     linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos + 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos,     j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos - 2, j * 32 + 2, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_BASE_COLOR  
          credit_bitmap.draw_text(xpos,     j * 32,     linewidth, 32, line[k], align)

          #added by Gardenette
          @name_iteration += 1
          @iteration_string = @name_iteration.to_s
          name = line[k].to_s
          
          if FileTest.image_exist?("Graphics/Pictures/Credits/" + name)
            @contributor_sprites[name+@iteration_string] = Sprite.new(@text_viewport)
            @contributor_sprites[name+@iteration_string].bitmap = Bitmap.new("Graphics/Pictures/Credits/" + name)
            @contributor_sprites[name+@iteration_string].visible = false
            if @graphic_side == 0
              #display on the left side of the name
              @contributor_sprites[name+@iteration_string].x = (Graphics.width / 2) - (line[k].length * 10) - 32
              @graphic_side = 1
            else
              #display on the right side of the name
              @contributor_sprites[name+@iteration_string].x = (Graphics.width / 2) + (line[k].length * 10)
              @graphic_side = 0
            end
          #display bottom of sprite next to name
          @contributor_sprites[name+@iteration_string].y = @line_height - ((@contributor_sprites[name+@iteration_string].height / 2) - 16)
          end
        end
      end
      credit_sprite = Sprite.new(@text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z      = 9998
      credit_sprite.oy            = @realOY - @bitmap_height * i
      @credit_sprites[i] = credit_sprite
    end

    #-------------------------------
    # Setup
    #-------------------------------
    #fade in
    pbToneChangeAll(Tone.new(0,0,0,0),20)
    
    #tell the game that credits are rolling
    $game_switches[75] = true
    
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition(20)
    loop do
      Graphics.update
      Input.update
      update
      @@timer += (1 * Graphics.frame_rate / 60)
      if @@timer >= @skip_seconds * 60
        @sprites["skip"].opacity += 5 if @sprites["skip"].opacity <= 255
      end
      break if $scene != self
    end
    pbBGMFade(2.0)
    Graphics.freeze
    Graphics.transition(20, "fadetoblack")
    @background_sprite.dispose
    @credit_sprites.each { |s| s.dispose if s }
    @text_viewport.dispose
    viewport.dispose
    $PokemonGlobal.creditsPlayed = true
    pbBGMPlay(previousBGM)
  end

  # Check if the credits should be cancelled
  def cancel?
    if Input.trigger?(Input::USE) && @@timer >= @skip_seconds * 60
      if $game_switches[72]
        #transfer player home
        pbTransferWithTransition(map_id=33, x=22, y=7, transition = nil, dir = $game_player.direction)
        
      end
      pbBGMFade(1.0)
      $scene = Scene_Map.new
      return true
    end
    return false
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      if $game_switches[72]
        #transfer player home
        pbTransferWithTransition(map_id=33, x=22, y=7, transition = nil, dir = $game_player.direction)
        pbToneChangeAll(Tone.new(-255,-255,-255,0),20)
        $scene = ($game_map) ? Scene_Map.new : nil
      end
      #transfer player to intro map
      pbTransferWithTransition(map_id=1, x=9, y=7, transition = nil, dir = $game_player.direction)
      pbToneChangeAll(Tone.new(-255,-255,-255,0),20)
      $scene = ($game_map) ? Scene_Map.new : nil
      pbBGMFade(2.0)
      return true
    end
    return false
  end

  def update
    delta = Graphics.delta_s
    @counter += delta
    # Go to next slide
    if @counter >= SECONDS_PER_BACKGROUND
      @counter -= SECONDS_PER_BACKGROUND
      @bg_index += 1
      @bg_index = 0 if @bg_index >= BACKGROUNDS_LIST.length
      @background_sprite.setBitmap("Graphics/Titles/" + BACKGROUNDS_LIST[@bg_index])
    end
    return if cancel?
    return if last?
    @realOY += SCROLL_SPEED * delta
    # s is the sprite, i is the index
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - @bitmap_height * i }
    @contributor_sprites.each_with_index { |a, i|
    if a[1].visible == false then a[1].visible = true end
    a[1].oy = @realOY - a[1].y
    }
  end

  #end of class
end