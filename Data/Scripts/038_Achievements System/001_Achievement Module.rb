class PokemonGlobalMetadata
  attr_accessor :achievements
  
  def achievements
    @achievements={} if !@achievements
    return @achievements
  end
end

module Achievements
  # IDs determine the order that achievements appear in the menu.
  @achievementList={
    "STEPS"=>{
      "id"=>1,
      "name"=>"Tired Feet",
      "description"=>"Walk around the world.",
      "goals"=>[10000,50000,100000]
    },
    "POKEMON_CAUGHT"=>{
      "id"=>2,
      "name"=>"Gotta Catch 'Em All",
      "description"=>"Catch Pokémon.",
      "goals"=>[100,250,500]
    },
    "WILD_ENCOUNTERS"=>{
      "id"=>3,
      "name"=>"Running in the Tall Grass",
      "description"=>"Encounter Pokémon.",
      "goals"=>[250,500,1000]
    },
    "TRAINER_BATTLES"=>{
      "id"=>4,
      "name"=>"Battlin' Every Day",
      "description"=>"Go into Trainer battles.",
      "goals"=>[100,250,500]
    },
    "ITEMS_USED"=>{
      "id"=>5,
      "name"=>"Items Are Handy",
      "description"=>"Use items.",
      "goals"=>[250,500,1000]
    },
    "ITEMS_BOUGHT"=>{
      "id"=>6,
      "name"=>"Buying Supplies",
      "description"=>"Buy items.",
      "goals"=>[250,500,1000]
    },
    "ITEMS_SOLD"=>{
      "id"=>7,
      "name"=>"Seller",
      "description"=>"Sell items.",
      "goals"=>[100,250,500]
    },
    "MEGA_EVOLUTIONS"=>{
      "id"=>8,
      "name"=>"Mega Evolution Expert",
      "description"=>"Mega Evolve Pokémon.",
      "goals"=>[250,500,1000]
    },
    "PRIMAL_REVERSIONS"=>{
      "id"=>9,
      "name"=>"Primal Power",
      "description"=>"Primal Revert Pokémon.",
      "goals"=>[250,500,1000]
    },
    "ITEM_BALL_ITEMS"=>{
      "id"=>10,
      "name"=>"Finding Treasure",
      "description"=>"Find items in item balls.",
      "goals"=>[50,100,250]
    },
    "MOVES_USED"=>{
      "id"=>11,
      "name"=>"Ferocious Fighting",
      "description"=>"Use moves in battle.",
      "goals"=>[500,1000,2500]
    },
    "ITEMS_USED_IN_BATTLE"=>{
      "id"=>12,
      "name"=>"Mid-Battle Maintenance",
      "description"=>"Use items in battle.",
      "goals"=>[100,250,500]
    },
    "FAINTED_POKEMON"=>{
      "id"=>13,
      "name"=>"I Hope You're Not Doing a Nuzlocke",
      "description"=>"Have your Pokémon faint.",
      "goals"=>[100,250,500]
    }
  }
  
  def self.showAchievement(text)
    #make a temporary viewport
    @achviewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @achviewport.z = 1 #as low as you can set it
    #Don't want this appearing on top of menus and such
    @sprites = {}
    @sprites["achievement"]=Window_AdvancedTextPokemon.new(text)
    @sprites["achievement"].viewport=@achviewport
    @sprites["achievement"].width=228 if @sprites["achievement"].width<228
    @sprites["achievement"].x = 0-@sprites["achievement"].width
    @sprites["achievement"].y = 0
    pbSEPlay("Mining found all",70)
    @timer = 0
  end
  
  def self.slideAchIn
  #increase the x of the window until its x is 0, meaning it is fully on-screen
    if @sprites["achievement"].x <= 0 - 15
      @sprites["achievement"].x += 15
    else
      #Slow down. We don't want the x to be more than 0
      @sprites["achievement"].x += 1 if @sprites["achievement"].x <0
    end
  end
  
  def self.slideAchOut
    if @sprites["achievement"].x >= 0 - @sprites["achievement"].width
      @sprites["achievement"].x -= 15
    else
      #dispose viewport when the achievement gets off-screen
      @achviewport.dispose
    end
  end
  
  #fade out the achievemet that pops up
  EventHandlers.add(:on_frame_update, :achpopup, proc {
    if @sprites
      #make a timer so the opacity does not start decreasing until timer is up
      @timer += (1 * Graphics.frame_rate / 60) #increase by 1 per second
      if @timer <= 5 * 60
        #if timer is less than or equal to 5, start sliding the box onto the screen
        self.slideAchIn
      else
        self.slideAchOut
      end
    end
  })
  
  def self.list
    Achievements.fixAchievements
    return @achievementList
  end
  def self.fixAchievements
    @achievementList.keys.each{|a|
      if $PokemonGlobal.achievements[a].nil?
        $PokemonGlobal.achievements[a]={}
      end
      if $PokemonGlobal.achievements[a]["progress"].nil?
        $PokemonGlobal.achievements[a]["progress"]=0
      end
      if $PokemonGlobal.achievements[a]["level"].nil?
        $PokemonGlobal.achievements[a]["level"]=0
      end
    }
    $PokemonGlobal.achievements.keys.each{|k|
      if !@achievementList.keys.include? k
        $PokemonGlobal.achievements.delete(k)
      end
    }
  end
  def self.incrementProgress(name, amount)
    Achievements.fixAchievements
    if @achievementList.keys.include? name
      if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
        $PokemonGlobal.achievements[name]["progress"]+=amount
        self.checkIfLevelUp(name)
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  def self.decrementProgress(name, amount)
    Achievements.fixAchievements
    if @achievementList.keys.include? name
      if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
        $PokemonGlobal.achievements[name]["progress"]-=amount
        if $PokemonGlobal.achievements[name]["progress"]<0
          $PokemonGlobal.achievements[name]["progress"]=0
        end
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  def self.setProgress(name, amount)
    Achievements.fixAchievements
    if @achievementList.keys.include? name
      if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
        $PokemonGlobal.achievements[name]["progress"]=amount
        if $PokemonGlobal.achievements[name]["progress"]<0
          $PokemonGlobal.achievements[name]["progress"]=0
        end
        self.checkIfLevelUp(name)
        return true
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  def self.checkIfLevelUp(name)
    Achievements.fixAchievements
    if @achievementList.keys.include? name
      if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
        level=@achievementList[name]["goals"].length
        @achievementList[name]["goals"].each_with_index{|g,i|
          if $PokemonGlobal.achievements[name]["progress"] < g
            level=i
            break
          end
        }
        if level>$PokemonGlobal.achievements[name]["level"]
          $PokemonGlobal.achievements[name]["level"]=level
          self.queueMessage(_INTL("Achievement Reached!\n{1} Level {2}",@achievementList[name]["name"],level.to_s))
          return true
        else
          return false
        end
      else
        return false
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  def self.getCurrentGoal(name)
    Achievements.fixAchievements
    if @achievementList.keys.include? name
      if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
        @achievementList[name]["goals"].each_with_index{|g,i|
          if $PokemonGlobal.achievements[name]["progress"] < g
            return g
          end
        }
        return nil
      else
        return 0
      end
    else
      raise "Undefined achievement: "+name.to_s
    end
  end
  def self.queueMessage(msg)
    if $achievementmessagequeue.nil?
      $achievementmessagequeue=[]
    end
    $achievementmessagequeue.push(msg)
  end
end