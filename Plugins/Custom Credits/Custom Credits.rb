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
  BGM                    = "Credits"
  SCROLL_SPEED           = Graphics.frame_rate   # Pixels per second
  SECONDS_PER_BACKGROUND = 11
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(255, 255, 255, 255)
  TEXT_SHADOW_COLOR      = Color.new(0, 0, 0, 100)

  # This next piece of code is the credits.
  # Start Editing
  CREDIT = <<END
Main Development Team:
BlueLightning
Chespin_Craft
FIE.F
Gardenette
Kaloja
Kutas Kitti
LotusLich/Spork
Lovely Werewolf
Low
Merry
Miiryx
Nifdoowo
SpaceWestern
stygma
the.SizzlePanda










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
Allay
Aveon Trainer
Banana 'Eduardo' Toast
BE_Infinity
Cristata
Derlo
dipaolo
Donlawride
Gearjuice
GreenJellybean
Griffin L.
Guill
Jackeroni216
k1-energy
Kaloja
King Tapia
Kutas Kitti
Lightbulb15
Magiscarf
Merry
Moses
ormr_kin
Phrog 
Phyromatical
Pint Sized Kiwi
PokemonEclipse
PrincessPhoenix
Rider Dragon
Saltilton
Seiyouh
ShadySheep
StarDream
stygma
Sunfish
the.sizzlepanda
Tinytrashing
Tyler Jones
VentesTheFloof

Pokémon & Pokédex:
8xviktor
A Slime Psycho
aball
Akikaze
Allay
Applesaucior
Banana 'Eduardo' Toast
Bean Soup
been
CeleryGuy
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
godopolis
Griffin L.
Grimrose
HingisDingus
Hub-Bub
I'm Para
Igor!
Inks
Jack
Jeremy K
Jhams
k1-energy
KameOtaku
Locrian
Loretze
Lorka_Grey
LotusLich/Spork
LuckyBenjamin
MadMillerMiller
MasterMachi
Merry
painT
Pelican
Pint Sized Kiwi
Phrog
Regal-Turtwig
RockTomb
Sadistic Ivory Rosé
Saltilton
ShadySheep
SietseML
Sodacat
Solvaa
SoundJack426
Sunfish
The Picky Pixel Artist
Venom_
VentesTheFloof
Waterleaf
WillTheWall
yeehaugh
Yeem
Yokaiju
Yoli

Trainers/NPCs:
aball
Akikaze
AtomicReactor
BamBoshBubb
BSXD
CeleryGuy
Chespin_Craft
Claire
Cristata
cubeofstone
D3DKAT
De_Liller
DiegoWT
Froot
Gardenette
Gearjuice
Guill
HingisDingus
Hugo L.
HwiteHwale
Jack
k1-energy
KameOtaku
Locomotivo
Loretze
LotusLich/Spork
MadMillerMiller
Maicerochico
MILKMAN
Neo-Spriteman
Nifdoowo
Omegabroski2
PHxNX
Porywagon
PurpleZaffre
RockTomb
Saltilton
TheFallenRoyal
VanillaSunshine
VentesTheFloof

UI & Misc.:
aball
Adam B.
Basalte
Chespin_Craft
Cristata
Dan Bacon
dipaolo
DomTom
Fikolyte
Gardenette
Hugo L.
HwiteHwale
Jackster
Jeremy K
MadMillerMiller
MasterMachi
Moses
Nifdoowo
Pint Sized Kiwi
Random Talking Bush
Riot
Sal_Aliz
Saltilton
Tyler (MANGO) Jackson
Virus
WolfPP










Music
-----
Soundtrack:
ENLS's Pre-Looped Music Library
EntityUnknown
FIE.F
FNaF 6
Jumpluff
Laminnanne
Locrian
Lovely Werewolf
Materia Music Publishing
Merry
Pint Sized Kiwi
Pokémon Clover
Purple Hat of Awesome
ReMX
Rhythm Break
rocker
TheDopeyElephant
Toby Fox



Pokémon Cries:
CeleryGuy
FIE.F
Gardenette
Hummus
Merry
Pint Sized Kiwi
Text 206










Mapping
-------
dipaolo
Elm
Gardenette
GreenJellybean
Guill
ImaDeadMan
Jallensart
Kaloja
Kameleron
Kami
Kutas Kitti
MadMillerMiller
Merry
Pint Sized Kiwi
RISH
Shadows
stygma
Sushi Rollo
Tyler (MANGO) Jackson
Virus










Eventing
--------
Gardenette
Geoswag
Kaloja
Kutas Kitti
Low
Pint Sized Kiwi
SpaceWestern
stygma










Story & Quests
--------------
Angel
Bean Soup
BlueLightning
BSXD
CitrusCustard
Deino
FIE.F
Firedude
Gardenette
Guill
Hawkeyetri
Hex mono
HwiteHwale
JayBeeMe
Kameleron
Kami
Kyl-E
Inks
Locomotivo
Luc_
LuckyBenjamin
MasterMachi
Merloc8
Merry
Miiryx
Mudkip
PaperTowelDealer
PHxNX
Raiz
Reahn
Sal_Aliz
Scandal
Shilo
sneakysnek
SP0RE
stygma
The_Virus
ThisGrainCharacter
TK SamuraiSasori
Tyler Bland
Virus
Yadriel J. Vento (HypnosEmblem)










Game Data & Balancing
---------------------
Adam B.
Amber W
Box
caesar
CitrusCustard
dipaolo
DomTom
Elm
Empyrean
FIE.F
Gardenette
Garreon
Hare64
Hawkeyetri
HwiteHwale
Kyl-E
Low
LuckyBenjamin
MacheteMcGoo
Malarkey
Merry
Midbus
Miiryx
mSilk
Nightmareone
noahthenumbat
PaperTowelDealer
ParaBellum
Pint Sized Kiwi
Robochef9000
Scandal
Señor Gallo de Caballo
Shadows
SpaceWestern
stygma
TK SamuraiSasori
Virus
Waffler
Zyuran










Translating
-----------
Abstractpuppet
Adoudidou
Aelvric
Basalte
Cawa/Sasha
Deli
Elm
Fitch
Floriak
Hey
Korr
Motis
Myztic
SaraLaGusana
Slepoy
stygma
Truegear
vakozay
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
Moses
Saltilton
stygma
TK SamuraiSasori
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
SP0RE
stygma










Wiki
----
B_Creative
Chespin_Craft
Chroma
CitrusCustard
Low
Miiryx
R. P. Genocraft










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

Autoscroll:
Gardenette
Wachunga

Bag Screen with Interactable Party:
DiegoWT
Rose
Vendily

Berry Pots:
Caruban
DerxwnaKapsyla

BetterBitmaps:
Marin

Better Battle Animation Editor:
KRLW890

Better Item Finder:
Kotaro

Blukberry Phone:
Gardenette
Low
Saltilton

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

Multi Exp Panel:
Swdfm

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

Pokeblocks v20.1:
bo4p5687
Richard PT
wrigty12

Pokémon Amie:
BhagyaJyoti
bo4p5687
Gardenette
Luka S.J
PizzaSun
rigbycwts
Victorcarvalhosp

Pokémon Camp:
Gardenette
Micah

Pokémon Contests:
bo4p5687
FL
Gardenette
JV
Luka S.J.
Maruno
mej71
Saving Raven
TastyRedTomato
Umbreon/Hansiec
wrigty12

PokéVial
Voltseon
qin2500

Polished Floors:
TechSkylander1518

Quicksave:
Low

Save File Calls:
TechSkylander1518

Set the Controls Screen:
FL

Speed Up 2.0:
Marin
Phantombass

Step on Spot OW Animation:
Boonzeet

Storage System Utilities:
Swdfm

TDW Berry Core and Dex:
wrigty12

TDW Berry Planting Improvements:
Arcky
Ulithium_Dragon
wrigty12

Temporal Chains' Wardrobe:
DarrylBD99
StarWolff

Tileset Rearranger:
Maruno

Time and Weather HUD Addon:
Gardenette
Locomotivo

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


And lastly, our thanks to



YOU
{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}
END
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
	
	#logic for skip button
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
		  if NAMES_HASH.has_key?(name)
		    filename = NAMES_HASH.fetch(name)
			if FileTest.image_exist?("Graphics/Pictures/Credits/" + filename)
              @contributor_sprites[filename+@iteration_string] = Sprite.new(@text_viewport)
              @contributor_sprites[filename+@iteration_string].bitmap = Bitmap.new("Graphics/Pictures/Credits/" + filename)
              @contributor_sprites[filename+@iteration_string].visible = false
              if @graphic_side == 0
                #display on the left side of the name
                @contributor_sprites[filename+@iteration_string].x = (Graphics.width / 2) - (line[k].length * 10) - 32
                @graphic_side = 1
              else
                #display on the right side of the name
                @contributor_sprites[filename+@iteration_string].x = (Graphics.width / 2) + (line[k].length * 10)
                @graphic_side = 0
              end
            #display bottom of sprite next to name
            @contributor_sprites[filename+@iteration_string].y = @line_height - ((@contributor_sprites[filename+@iteration_string].height / 2) - 16)
            end
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
    
    # Stops all audio but background music
    previousBGM = $game_system.getPlayingBGM
    pbMEStop
    pbBGSStop
    pbSEStop
    pbBGMFade(2.0)
    pbBGMPlay(BGM)
    Graphics.transition(20)
	@timer = 0
    loop do
      Graphics.update
      Input.update
      update
	  @timer += 1
	  @sprites["skip"].opacity += 1 if @timer >= @skip_seconds * Graphics.frame_rate && @sprites["skip"].opacity < 255
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
    if Input.trigger?(Input::USE) && @timer >= @skip_seconds * Graphics.frame_rate #&& $PokemonGlobal.creditsPlayed
      $scene = Scene_Map.new
      pbBGMFade(1.0)
      return true
    end
    return false
  end

  # Checks if credits bitmap has reached its ending point
  def last?
    if @realOY > @total_height + @trim
      $scene = ($game_map) ? Scene_Map.new : nil
      #@creditsEnd = 1
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