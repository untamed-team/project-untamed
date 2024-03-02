SaveData.register(:fashion_case) do
  save_value { $fashion_case }
  load_value { |value|  $fashion_case = value }
  new_game_value { FashionCase.new }
end

class FashionCase
  attr_accessor :unlocked_accessories
  attr_accessor :unlocked_backdrops
  
  #put in a quantity argument
  def accessory_unlock(accessory, silent=false)
    for i in 0...ContestSettings::ACCESSORIES.length
      ContestSettings::ACCESSORIES[i].each do |key, value|
        if key.to_s == accessory
          #add the accessory to the array if it exists in ContestSettings::ACCESSORIES
          ##and if the accessory is not already in the array
          #if silent is false or not specified
          if silent != true
            pbMEStop(0.0)
            meName = "Contests_Get Accessory"
            #play the jingle for getting an accessory and make a popup that says the
            #player got the accessory and added it to the fashion case
            pbMessage(_INTL("\\me[{1}]Obtained the \\c[1]{2}\\c[0]!\\wtnp[30]", meName, accessory))
            pbMessage(_INTL("\\PN put away the {1} in the Fashion Case.", accessory))
          end #if silent != true
          @unlocked_accessories.push(accessory)
        end #if key == accessory
      end #ContestSettings::ACCESSORIES[i].each do |key, value|
    end #for i in 0...ContestSettings::ACCESSORIES[i]
  end #def accessory_unlock(accessory, silent=false)
  
  def backdrop_unlock(backdrop, silent=false)
    if ContestSettings::BACKDROPS.include?(backdrop) && !@unlocked_backdrops.include?(backdrop)
      #add the backdrop to the array if it exists in ContestSettings::BACKDROPS
      #and if the backdrop is not already in the array
      
      #if silent is false or not specified
      if silent != true
        pbMEStop(0.0)
        meName = "Contests_Get Accessory"
        #play the jingle for getting an accessory and make a popup that says the
        #player got the accessory and added it to the fashion case
        pbMessage(_INTL("\\me[{1}]Obtained the \\c[1]{2}\\c[0]!\\wtnp[30]", meName, backdrop))
        pbMessage(_INTL("\\PN put away the {1} in the Fashion Case.", backdrop))
      end
      @unlocked_backdrops.push(backdrop)
    end
  end
  
  def emptyFashionCase
    @unlocked_accessories = []
    @unlocked_backdrops = []
  end
  
  def giveStarterPack
    #silently give the player the following accessories/backdrops to get them\
    #started with contests
    #contests will crash if no accessories are in the fashion case
    accessory_unlock("Black Fluff", silent=true)
    accessory_unlock("Black Fluff", silent=true)
    accessory_unlock("Orange Fluff", silent=true)
    accessory_unlock("Big Leaf", silent=true)
    accessory_unlock("Small Leaf", silent=true)
    accessory_unlock("Glitter Powder", silent=true)
    backdrop_unlock("Dress up", silent=true)
  end
  
  #syntax:
  #$fashion_case.accessory_unlock("accessory")
  #$fashion_case.backdrop_unlock("backdrop")
end