#===============================================================================
#
#===============================================================================
class Battle::ActiveField
  attr_accessor :effects
  attr_accessor :defaultWeather
  attr_accessor :weather
  attr_accessor :weatherDuration
  attr_accessor :defaultTerrain
  attr_accessor :terrain
  attr_accessor :terrainDuration
  attr_accessor :typezone #mastersex type zones #by low
  attr_accessor :presageBackup # presage stuff  #by low
  attr_accessor :abilityWeather # was the weather set by an ability? #by low
  attr_accessor :abilityTerrain # was the terrain set by an ability? #by low

  def initialize
    @effects = []
    @effects[PBEffects::AmuletCoin]      = false
    @effects[PBEffects::FairyLock]       = 0
    @effects[PBEffects::FusionBolt]      = false
    @effects[PBEffects::FusionFlare]     = false
    @effects[PBEffects::Gravity]         = 0
    @effects[PBEffects::HappyHour]       = false
    @effects[PBEffects::IonDeluge]       = false
    @effects[PBEffects::MagicRoom]       = 0
    @effects[PBEffects::MudSportField]   = 0
    @effects[PBEffects::PayDay]          = 0
    @effects[PBEffects::TrickRoom]       = 0
    @effects[PBEffects::WaterSportField] = 0
    @effects[PBEffects::WonderRoom]      = 0
    @defaultWeather  = :None
    @weather         = :None
    @weatherDuration = 0
    @defaultTerrain  = :None
    @terrain         = :None
    @terrainDuration = 0
    @typezone				 = :None #mastersex type zones #by low
    @presageBackup	 = [:None, 0] # presage stuff  #by low
		@abilityWeather  = false
		@abilityTerrain  = false
  end
end

#===============================================================================
#
#===============================================================================
class Battle::ActiveSide
  attr_accessor :effects

  def initialize
    @effects = []
    @effects[PBEffects::AuroraVeil]         = 0
    @effects[PBEffects::CraftyShield]       = false
    @effects[PBEffects::EchoedVoiceCounter] = 0
    @effects[PBEffects::EchoedVoiceUsed]    = false
    @effects[PBEffects::LastRoundFainted]   = -1
    @effects[PBEffects::LastRoundFaintedPokemon] = [-1, -1] # AI stuff #by low
    @effects[PBEffects::LightScreen]        = 0
    @effects[PBEffects::LuckyChant]         = 0
    @effects[PBEffects::MatBlock]           = false
    @effects[PBEffects::Mist]               = 0
    @effects[PBEffects::QuickGuard]         = false
    @effects[PBEffects::Rainbow]            = 0
    @effects[PBEffects::Reflect]            = 0
    @effects[PBEffects::Round]              = false
    @effects[PBEffects::Safeguard]          = 0
    @effects[PBEffects::SeaOfFire]          = 0
    @effects[PBEffects::Spikes]             = 0
    @effects[PBEffects::StealthRock]        = false
    @effects[PBEffects::StickyWeb]          = 0
    @effects[PBEffects::Swamp]              = 0
    @effects[PBEffects::Tailwind]           = 0
    @effects[PBEffects::ToxicSpikes]        = 0
    @effects[PBEffects::WideGuard]          = false
    @effects[PBEffects::PartyPopper]        = false #by low
    @effects[PBEffects::StatDropImmunity]   = false #by low
    @effects[PBEffects::SwitchAbuse]   			= 0 #by low
  end
end

#===============================================================================
#
#===============================================================================
class Battle::ActivePosition
  attr_accessor :effects

  def initialize
    @effects = []
    @effects[PBEffects::FutureSightCounter]        = 0
    @effects[PBEffects::FutureSightMove]           = nil
    @effects[PBEffects::FutureSightUserIndex]      = -1
    @effects[PBEffects::FutureSightUserPartyIndex] = -1
    @effects[PBEffects::HealingWish]               = false
    @effects[PBEffects::LunarDance]                = false
    @effects[PBEffects::Wish]                      = 0
    @effects[PBEffects::WishAmount]                = 0
    @effects[PBEffects::WishMaker]                 = -1
  end
end
