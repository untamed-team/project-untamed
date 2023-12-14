#=========================================
#Credits
#https://reliccastle.com/resources/526/
#-TechSkylander1518
#-Fiona Summers (because I used her code to figure out how to make mine plug-and-play)
#-Luke S.J. for the method alias help in Fiona's original code
#-Astralneko for the adjective and man/woman/person additions
#=========================================
#Use calls:
#\he - he/she/they
#\him - him/her/them
#\his - his/her/their
#\hrs - his/hers/theirs
#\slf - himself/herself/theirself
#\hes - he's/she's/they're
#\heis - he is/she is/they are
#\man - man/woman/person - We will not be using this. Removed from the script. Use "person" instead when talking about the player.
#\oa - o or a, for gendered adjectives like in Spanish
#Add "u" after the slash for uppercase. (\uhe is "He" instead of "he")
#
#This script can be added to already-released games, but existing saves will encounter a problem with any messages, because of the lack of pronouns for them. I'd suggest having an event in a PMC that just ran pronounsThey, so you can run events with messages again, and then having the player change it for themselves at the PC.
#
#Since I couldn't possibly account for every verb, I added a little check for verb conjugation! Let's say someone's telling a story about the player, and the text should say something like
#"And then he walks over to her, and says..."
#
#But if your player's using they, that'd be grammatically incorrect.
#"And then they walks over to her, and says..."
#
#Enter the useIs function! Make a conditional branch based on that- the text if it's true is for singular conjugation (He walks, he says, etc.), and if it's false is for plural conjugation. (They walk, they say, etc.)
#=========================================
module Tech_Pronouns
  attr_accessor :they
  attr_accessor :them
  attr_accessor :their
  attr_accessor :theirs
  attr_accessor :themself
  attr_accessor :is
  attr_accessor :conjugation
  attr_accessor :person
 
    @they              = "they"
    @them              = "them"
    @their             = "their"
    @theirs            = "theirs"
    @themself          = "themself"
    @is                = false
    @conjugation       = ""
    @person            = "person"
  
end


class Player
  include Tech_Pronouns
end

def useIs
  return $Trainer.is
end


def pronounsHim
    $Trainer.they              = "he"
    $Trainer.them              = "him"
    $Trainer.their             = "his"
    $Trainer.theirs            = "his"
    $Trainer.themself          = "himself"
    $Trainer.is                = true
    $Trainer.conjugation       = "o"
end

def pronounsHer
    $Trainer.they              = "she"
    $Trainer.them              = "her"
    $Trainer.their             = "her"
    $Trainer.theirs            = "hers"
    $Trainer.themself          = "herself"
    $Trainer.is                = true
    $Trainer.conjugation       = "a"
end

def pronounsThey
    $Trainer.they              = "they"
    $Trainer.them              = "them"
    $Trainer.their             = "their"
    $Trainer.theirs            = "theirs"
    $Trainer.themself          = "themself"
    $Trainer.is                = false
    $Trainer.conjugation       = "o"
end


def pronounsIt
    $Trainer.they              = "it"
    $Trainer.them              = "it"
    $Trainer.their             = "its"
    $Trainer.theirs            = "its"
    $Trainer.themself          = "itself"
    $Trainer.is                = true
    $Trainer.conjugation       = "o"
end

def pronounsCustom
  pronoun = ""
  pronoun = pbMessageFreeText(_INTL("He/She/They"),"",false,8)
  $Trainer.they     = pronoun
  pronoun = pbMessageFreeText(_INTL("Him/Her/Them"),"",false,8)
  $Trainer.them     = pronoun
  pronoun = pbMessageFreeText(_INTL("His/Her/Their"),"",false,8)
  $Trainer.their    = pronoun
  pronoun = pbMessageFreeText(_INTL("His/Hers/Theirs"),"",false,8)
  $Trainer.theirs   = pronoun
  pronoun = pbMessageFreeText(_INTL("Himself/Herself/Theirself"),"",false,8)
  $Trainer.themself = pronoun
  $Trainer.conjugation = "o"
  #===============================##
  # Spanish translation needs proper adjective (and occasionally noun) endings too
  #===============================##
  if $PokemonSystem.language == 1 # Spanish
    pronoun = pbMessageFreeText(_INTL("¿Qué usa para terminar adjetivos, como el \"o\" en \"alto\"?"),
                                  "",false,2)
    $Trainer.conjugation = pronoun
  end
  #===============================##
  command = 0
  loop do
    command = pbMessage(_INTL("{1} is or {1} are?",$Trainer.they),[
       _INTL("{1} is",$Trainer.they),
       _INTL("{1} are",$Trainer.they)
       ],-1,nil,command)
    case command
    when 0;
      $Trainer.is = true
      break
    when 1;
      $Trainer.is = false
      break
    end
  end
end


def pronounsPerson(base)
  $Trainer.person = base
  ###I took out a chunk here... - Gardenette :)
end


def pbPronouns
  command = 0
  loop do
    $prounounsChosen = 0
    #if story progression is less than 1, we haven't started the game, and Ceiba
    #is asking about pronouns
    if $game_variables[27] < 1
    command = pbMessage(_INTL("What are your pronouns?"),[
       _INTL("He/Him"),
       _INTL("She/Her"),
       _INTL("They/Them"),
       _INTL("It/It")
       ],-1,nil,command)
     else
       #otherwise, we are changing pronouns from the PC
       command = pbMessage(_INTL("What are your pronouns?"),[
       _INTL("He/Him"),
       _INTL("She/Her"),
       _INTL("They/Them"),
       _INTL("It/It")
       ],-1,nil,command)
     end
    case command
    when 0;
      if Kernel.pbConfirmMessage(_INTL("Your pronouns are He/Him?"))
        pronounsHim
        pronounsPerson("man")
        pbSEPlay("GUI naming confirm")
        pbMessage(_INTL("Updated to {1} / {2}.",$Trainer.they,$Trainer.them))
        $prounounsChosen = 1
        break
      end
    
    when 1;
      if Kernel.pbConfirmMessage(_INTL("Your pronouns are She/Her?"))
        pronounsHer
        pronounsPerson("woman")
        pbSEPlay("GUI naming confirm")
        pbMessage(_INTL("Updated to {1} / {2}.",$Trainer.they,$Trainer.them))
        $prounounsChosen = 1
        break
      end
    
    when 2;
      if Kernel.pbConfirmMessage(_INTL("Your pronouns are They/Them?"))
        pronounsThey
        pronounsPerson("trainer")
        pbSEPlay("GUI naming confirm")
        pbMessage(_INTL("Updated to {1} / {2}.",$Trainer.they,$Trainer.them))
        $prounounsChosen = 1
        break
      end
    
    when 3;
      if Kernel.pbConfirmMessage(_INTL("Your pronouns are It/It?"))
        pronounsIt
        pronounsPerson("trainer")
        pbSEPlay("GUI naming confirm")
        pbMessage(_INTL("Updated to {1} / {2}.",$Trainer.they,$Trainer.them))
        $prounounsChosen = 1
        break
      end
      
    else; 
    #  $prounounsChosen = 0
    #if variable 27 < 1 then we are in the intro, where cancelling this
    #selection is not allowed
    if $game_variables[27] < 1
      command = 0
    else
      #changing from PC; you can cancel (break loop)
      break
      end
    end
  end
end


def pbTrainerPCMenu
  command = 0
  loop do
    command = pbMessage(_INTL("What do you want to do?"),[
       _INTL("Item Storage"),
       _INTL("Mailbox"),
       _INTL("Pronouns"),
       _INTL("Turn Off")
       ],-1,nil,command)
    case command
    when 0; pbPCItemStorage
    when 1; pbPCMailbox
    when 2; pbPronouns
    else; break
    end
  end
end

   unless Kernel.respond_to?(:pbMessageDisplay_Old)
      alias pbMessageDisplay_Old pbMessageDisplay
      def pbMessageDisplay(*args)
        if $Trainer
          if $Trainer.themself
            if $Trainer.is==true
              args[1].gsub!(/\\hes/i,_INTL("{1}'s",$Trainer.they.downcase))
              args[1].gsub!(/\\uheis/i,_INTL("{1} is",$Trainer.they.capitalize))
              args[1].gsub!(/\\heis/i,_INTL("{1} is",$Trainer.they.downcase))
              args[1].gsub!(/\\uhes/i,_INTL("{1}'s",$Trainer.they.capitalize))
            end
            if $Trainer.is==false
              args[1].gsub!(/\\hes/i,_INTL("{1}'re",$Trainer.they.downcase))
              args[1].gsub!(/\\heis/i,_INTL("{1} are",$Trainer.they.downcase))
              args[1].gsub!(/\\uhes/i,_INTL("{1}'re",$Trainer.they.capitalize))
              args[1].gsub!(/\\uheis/i,_INTL("{1} are",$Trainer.they.capitalize))
            end
          args[1].gsub!(/\\he/i,$Trainer.they.downcase)
          args[1].gsub!(/\\uhe/i,$Trainer.they.capitalize)
          args[1].gsub!(/\\him/i,$Trainer.them.downcase)
          args[1].gsub!(/\\uhim/i,$Trainer.them.capitalize)
          args[1].gsub!(/\\his/i,$Trainer.their.downcase)
          args[1].gsub!(/\\uhis/i,$Trainer.their.capitalize)
          args[1].gsub!(/\\hrs/i,$Trainer.theirs.downcase)
          args[1].gsub!(/\\uhrs/i,$Trainer.theirs.capitalize)
          args[1].gsub!(/\\slf/i,$Trainer.themself.downcase)
          args[1].gsub!(/\\uslf/i,$Trainer.themself.capitalize)
          args[1].gsub!(/\\oa/o,$Trainer.conjugation.downcase)
          args[1].gsub!(/\\man/i,$Trainer.person.downcase)
          args[1].gsub!(/\\uman/i,$Trainer.person.capitalize)
        end
      end
        return pbMessageDisplay_Old(*args)
      end
end

#waiting for the day the tumblr rejects ask for xey/xem support in the game