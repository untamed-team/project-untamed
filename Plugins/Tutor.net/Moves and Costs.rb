#Low, add to this whatever you want
#The format is as follows:
#pbTutorNetAddSilent(:MOVE,COST,CURRENCY)
#Example: pbTutorNetAddSilent(:FIREPUNCH,1000) #it is implied the cost is money
#since an item was not listed as the currently
#But items certainly can be used as the currency
#Example: pbTutorNetAddSilent(:FIREPUNCH,6,:REDSHARD)
##########################################################
def addPredefinedTutorMoves
  #start adding moves here
  pbTutorNetAddSilent(:METRONOME,cost=1000,currency="$")
  pbTutorNetAddSilent(:DRAININGKISS,cost=2000,currency="$")
  pbTutorNetAddSilent(:EXCITE,cost=1000,currency="$")
end
##########################################################
#added by Gardenette
def pbTutorNetAddSilent(move,cost=0,currency="$")
  if !($Trainer.tutorlist)
    $Trainer.tutorlist=[]
  end
  if !$Trainer.tutornet
    !$Trainer.tutornet=true
  end
  for i in 0...$Trainer.tutorlist.length  
    if !$Trainer.tutorlist[i].is_a?(Array)
    makeit=[$Trainer.tutorlist[i],0,"$"]
    $Trainer.tutorlist[i]=makeit
    end
  end
  found=false
  for i in 0...$Trainer.tutorlist.length
    if $Trainer.tutorlist[i][0]==move	
    found=true
    if ($Trainer.tutorlist[i][1]!=cost || $Trainer.tutorlist[i][2]!=currency) && $Trainer.tutorlist[i][1]>0 
      if cost ==0
        $Trainer.tutorlist[i][1]=cost
        $Trainer.tutorlist[i][2]=currency
      elsif $Trainer.tutorlist[i][1]>0
        current_cost = ""
        new_cost = ""
        if $Trainer.tutorlist[i][2]=="$"
          current_cost = _INTL("Current cost: ${1}",$Trainer.tutorlist[i][1])
        else
          current_cost = _INTL("Current cost: {1} {2}",$Trainer.tutorlist[i][1],GameData::Item.get($Trainer.tutorlist[i][2]).name_plural)
        end	
        if currency=="$"
          new_cost = _INTL("New cost: ${1}",cost)
        else
          new_cost = _INTL("New cost: {1} {2}",cost,GameData::Item.get(currency).name_plural)
        end
        cost_swap_msg = current_cost+"\n"+new_cost
      end	
    end	
    end
  end
  unlock_message = "Purchase"
  unlock_message = "Permanently unlock" if Settings::PERMANENT_TUTOR_MOVE_UNLOCK       
  if !found
    $Trainer.tutorlist.push([move,cost,currency])
    return true             
  end
  return false
end