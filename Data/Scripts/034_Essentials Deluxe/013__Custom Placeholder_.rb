#===============================================================================
# Placeholder code for customized battle mechanics to be used by other plugins.
#===============================================================================


#-------------------------------------------------------------------------------
# Placeholder file path for custom battle button.
#-------------------------------------------------------------------------------
module Settings
  CUSTOM_MECH_BUTTON_PATH = ""
end

#-------------------------------------------------------------------------------
# Placeholder Battle code.
#-------------------------------------------------------------------------------
class Battle
  attr_accessor :custom
  
  alias custom_dx_initialize initialize
  def initialize(*args)
    custom_dx_initialize(*args)
    @custom = [
      [-1] * (@player ? @player.length : 1),
      [-1] * (@opponent ? @opponent.length : 1)
    ]
  end
  
  def pbCanCustom?(idxBattler); return false; end
  def pbCustomMechanic(idxBattler); end
  def pbRegisterCustom(idxBattler); end
  def pbUnregisterCustom(idxBattler); end
  def pbToggleRegisteredCustom(idxBattler); end
  def pbRegisteredCustom?(idxBattler); return false; end
  def pbAttackPhaseCustom; end
end

#-------------------------------------------------------------------------------
# Placeholder Battle AI code.
#-------------------------------------------------------------------------------
class Battle::AI
  def pbEnemyShouldCustom?(idxBattler); return false; end
end