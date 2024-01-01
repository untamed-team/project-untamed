#Script de lootboxes creado por Nyaruko
#Si metes micropagos no me hago responsable

#edited, heavily(?) #by low
COMMON 		 = [:POTION,:POKEBALL,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL] # 50%
UNCOMMON 	 = [:AWAKENING,:GREATBALL,:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS] # 25%
RARE 			 = [:FULLHEAL,:ULTRABALL,:EVRESET,:STICKYBARB] # 14%
SUPER_RARE = [:REVIVE,:QUICKBALL,:SHINYBERRY] # 7%
ULTRA_RARE = [:SACREDASH,:MASTERBALL,:LUCKYEGG] # 3%
PENIS_RARE = [[:PACUNA, 0, :LEFTOVERS],[:PACUNA, 1, :STICKYBARB]] # 1% (pokeman, ability_index, item, form)

class LootBox
  def pbStartMainScene
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    random1 = rand(100)
    random2 = rand(100)
    random3 = rand(100)
    common 		= COMMON
    uncommon 	= UNCOMMON
    rare 			= RARE
    s_rare 		= SUPER_RARE
    u_rare 		= ULTRA_RARE
    p_rare 		= PENIS_RARE
    
    sprites={}
    sprites["bg"]=Sprite.new
    sprites["bg"].z=99998
    sprites["bg"].bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Lootboxes/","background")
    
    sprites["bolsa"]=IconSprite.new(0,0,viewport)
    sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_closed")
    sprites["bolsa"].x =157
    sprites["bolsa"].y =256
    
    sprites["item1"]=IconSprite.new(0,0,viewport)    
    sprites["item1"].x = 227
    sprites["item1"].y = 135
    
    sprites["item2"]=IconSprite.new(0,0,viewport)    
    sprites["item2"].x = 99
    sprites["item2"].y = 135
    
    sprites["item3"]=IconSprite.new(0,0,viewport)   
    sprites["item3"].x = 355
    sprites["item3"].y = 135

    sprites["icon1"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon1"].x = 260
    sprites["icon1"].y = 195
    
    sprites["icon2"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon2"].x = 134
    sprites["icon2"].y = 195
    
    sprites["icon3"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon3"].x = 389
    sprites["icon3"].y = 195
    
    sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    
    loop do
      Graphics.update
      Input.update
      #if Input.trigger?(Input::C)
        pbSEPlay("select")
        pbWait(20)
        sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_open")
        
				#~ print "#{random1}, #{random2}, #{random3}"
				# item n1
				if random1 == 1
					sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_p_rare")
          pbWait(20)
          pokeman1 = rand(p_rare.length)
					pkmn = Pokemon.new(p_rare[pokeman1][0], (pbBalancedLevel($Trainer.party) - 1))
					pkmn.ability_index = p_rare[pokeman1][1] if !p_rare[pokeman1][1].nil?
					pkmn.item = p_rare[pokeman1][2] if !p_rare[pokeman1][2].nil?
					pkmn.form = p_rare[pokeman1][3] if !p_rare[pokeman1][3].nil?
          sprites["item1"].setBitmap(GameData::Species.front_sprite_filename(pkmn.species, pkmn.form))
          pbAddPokemon(pkmn)
				elsif random1 >= 1 && random1 < 3
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_u_rare")
          pbWait(20)
          item1=rand(u_rare.length)
					sprites["icon1"].item = GameData::Item.get(u_rare[item1]).id
          pbReceiveItem(u_rare[item1])
				elsif random1 >= 3 && random1 < 7
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_s_rare")
          pbWait(20)
          item1=rand(s_rare.length)
					sprites["icon1"].item = GameData::Item.get(s_rare[item1]).id
          pbReceiveItem(s_rare[item1])
				elsif random1 >= 14  && random1 < 25
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_rare")
          pbWait(20)
          item1=rand(rare.length)
					sprites["icon1"].item = GameData::Item.get(rare[item1]).id
          pbReceiveItem(rare[item1])
				elsif random1 >= 25  && random1 < 50
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_uncommon")
          pbWait(20)
          item1=rand(uncommon.length)
					sprites["icon1"].item = GameData::Item.get(uncommon[item1]).id
          pbReceiveItem(uncommon[item1])
				else
          sprites["item1"].setBitmap("Graphics/Pictures/Lootboxes/item_common")
          pbWait(20)
          item1=rand(common.length)
					sprites["icon1"].item = GameData::Item.get(common[item1]).id
          pbReceiveItem(common[item1])
				end
				
				# item n2
				if random2 == 1
					sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_p_rare")
          pbWait(20)
          pokeman2 = rand(p_rare.length)
					pkmn = Pokemon.new(p_rare[pokeman2][0], (pbBalancedLevel($Trainer.party) - 1))
					pkmn.ability_index = p_rare[pokeman2][1] if !p_rare[pokeman2][1].nil?
					pkmn.item = p_rare[pokeman2][2] if !p_rare[pokeman2][2].nil?
					pkmn.form = p_rare[pokeman2][3] if !p_rare[pokeman2][3].nil?
          sprites["item2"].setBitmap(GameData::Species.front_sprite_filename(pkmn.species, pkmn.form))
          pbAddPokemon(pkmn)
				elsif random2 >= 1 && random2 < 3
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_u_rare")
          pbWait(20)
          item2=rand(u_rare.length)
					sprites["icon2"].item = GameData::Item.get(u_rare[item2]).id
          pbReceiveItem(u_rare[item2])
				elsif random2 >= 3 && random2 < 7
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_s_rare")
          pbWait(20)
          item2=rand(s_rare.length)
					sprites["icon2"].item = GameData::Item.get(s_rare[item2]).id
          pbReceiveItem(s_rare[item2])
				elsif random2 >= 14  && random2 < 25
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_rare")
          pbWait(20)
          item2=rand(rare.length)
					sprites["icon2"].item = GameData::Item.get(rare[item2]).id
          pbReceiveItem(rare[item2])
				elsif random2 >= 25  && random2 < 50
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_uncommon")
          pbWait(20)
          item2=rand(uncommon.length)
					sprites["icon2"].item = GameData::Item.get(uncommon[item2]).id
          pbReceiveItem(uncommon[item2])
				else
          sprites["item2"].setBitmap("Graphics/Pictures/Lootboxes/item_common")
          pbWait(20)
          item2=rand(common.length)
					sprites["icon2"].item = GameData::Item.get(common[item2]).id
          pbReceiveItem(common[item2])
				end
				
				# item n3
				if random3 == 1
					sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_p_rare")
          pbWait(20)
          pokeman3 = rand(p_rare.length)
					pkmn = Pokemon.new(p_rare[pokeman3][0], (pbBalancedLevel($Trainer.party) - 1))
					pkmn.ability_index = p_rare[pokeman3][1] if !p_rare[pokeman3][1].nil?
					pkmn.item = p_rare[pokeman3][2] if !p_rare[pokeman3][2].nil?
					pkmn.form = p_rare[pokeman3][3] if !p_rare[pokeman3][3].nil?
          sprites["item3"].setBitmap(GameData::Species.front_sprite_filename(pkmn.species, pkmn.form))
          pbAddPokemon(pkmn)
				elsif random3 >= 1 && random3 < 3
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_u_rare")
          pbWait(20)
          item3=rand(u_rare.length)
					sprites["icon3"].item = GameData::Item.get(u_rare[item3]).id
          pbReceiveItem(u_rare[item3])
				elsif random3 >= 3 && random3 < 7
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_s_rare")
          pbWait(20)
          item3=rand(s_rare.length)
					sprites["icon3"].item = GameData::Item.get(s_rare[item3]).id
          pbReceiveItem(s_rare[item3])
				elsif random3 >= 14  && random3 < 25
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_rare")
          pbWait(20)
          item3=rand(rare.length)
					sprites["icon3"].item = GameData::Item.get(rare[item3]).id
          pbReceiveItem(rare[item3])
				elsif random3 >= 25  && random3 < 50
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_uncommon")
          pbWait(20)
          item3=rand(uncommon.length)
					sprites["icon3"].item = GameData::Item.get(uncommon[item3]).id
          pbReceiveItem(uncommon[item3])
				else
          sprites["item3"].setBitmap("Graphics/Pictures/Lootboxes/item_common")
          pbWait(20)
          item3=rand(common.length)
					sprites["icon3"].item = GameData::Item.get(common[item3]).id
          pbReceiveItem(common[item3])
				end
				pbWait(10)
				pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
				pbDisposeSpriteHash(sprites)
				viewport.dispose if viewport
				break
     # end  
    end  
  end
end  