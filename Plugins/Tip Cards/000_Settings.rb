module Settings
    #====================================================================================
    #=============================== Tip Cards Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        #  Set the default background for tip cards.
        #  The files are located in Graphics/Pictures/Tip Cards
        #--------------------------------------------------------------------------------	
        TIP_CARDS_DEFAULT_BG            = "bg"

        #--------------------------------------------------------------------------------
        #  If set to true, if only one group is shown when calling pbRevisitTipCardsGrouped,
        #  the group header will still appear. Otherwise, the header won't appear.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SINGLE_GROUP_SHOW_HEADER = false

        #--------------------------------------------------------------------------------
        #  Set the default text colors
        #--------------------------------------------------------------------------------	
        TIP_CARDS_TEXT_MAIN_COLOR       = Color.new(80, 80, 88)
        TIP_CARDS_TEXT_SHADOW_COLOR     = Color.new(160, 160, 168)

        #--------------------------------------------------------------------------------
        #  Set the sound effect to play when showing and dismissing tip cards.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SHOW_SE               = "GUI menu open"
        TIP_CARDS_DISMISS_SE            = "GUI menu close"

        #--------------------------------------------------------------------------------
        #  Define your tips in this hash. The :EXAMPLE describes what some of the 
        #  parameters do.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_CONFIGURATION = {
            :EXAMPLE => { # ID of the tip
                    # Required Settings
                    :Title => _INTL("Example Tip"),
                    :Text => _INTL("This is the text of the tip. You can include formatting."),
                    # Optional Settings
                    :Image => "example", # An image located in Graphics/Pictures/Tip Cards/Images
                    :ImagePosition => :Top, # Set to :Top, :Bottom, :Left, or :Right.
                        # If not defined, it will place wider images to :Top, and taller images to :Left.
                    :Background => "bg2", # A replacement background image located in Graphics/Pictures/Tip Cards
                    :YAdjustment => 0, # Adjust the vertical spacing of the tip's text (in pixels)
                    :HideRevisit => true # Set to true if you don't want the player to see the tip again when revisiting seen tips.
            },
            :CATCH => {
                :Title => _INTL("Catching Pokémon"),
                :Text => _INTL("This is the text of the tip. You catch Pokémon by throwing a <c2=0999367C><b>Poké Ball</b></c2> at them."),
                :Image => "catch",
                :Background => "bg2"
            },
            :CATCH2 => {
                :Title => _INTL("Catching Pokémon"),
                :Text => _INTL("This is the text of the tip with a bottom picture. You catch Pokémon by throwing a <c2=0999367C><b>Poké Ball</b></c2> at them."),
                :Image => "catch",
                :ImagePosition => :Bottom,
                :Background => "bg2"
            },
            :ITEMS => {
                :Title => _INTL("Items"),
                :Text => _INTL("This is the text of the other tip. You may find items lying around."),
                :Image => "items",
                :YAdjustment => 64
            },
            :ITEMS2 => {
                :Title => _INTL("Items"),
                :Text => _INTL("This is the text of the other tip with a right picture. You may find items lying around."),
                :Image => "items",
                :ImagePosition => :Right,
                :YAdjustment => 64
            },
            :BOOK1PAGE1 => {
                :Title => _INTL("Page 1"),
                :Text => _INTL("<al>This is the first page. <br>Introducing: all the characters!</al>"),
                :Background => "bg_book"
            },
            :BOOK1PAGE2 => {
                :Title => _INTL("Page 2"),
                :Text => _INTL("<al>This is the second page. <br>Introducing: the vilain!</al>"),
                :Background => "bg_book"
            },
            :BOOK1PAGE3 => {
                :Title => _INTL("Page 3"),
                :Text => _INTL("<al>This is the third page. <br>It's conflict time!</al>"),
                :Background => "bg_book"
            },
            :BOOK1PAGE4 => {
                :Title => _INTL("Page 4"),
                :Text => _INTL("<al>This is the final page. <br>It's resolution time!</al>"),
                :Background => "bg_book"
            },
            :AUTOHEAL1 => {
                :Title => _INTL("Auto Heal"),
                :Text => _INTL("The Auto Heal feature will automatically select items from your bag and use them to heal your Pokémon."),
                :Image => "auto heal1",
                :YAdjustment => 64
            },
            :AUTOHEAL2 => {
                :Title => _INTL("Auto Heal"),
                :Text => _INTL("Highlight the Pokémon you want to heal from the party menu and press the button next to <c2=0999367C><b>Auto Heal</b></c2>."),
                :Image => "auto heal2",
            },
            :MULTISAVE1 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("When saving for the first time, you will select a save slot."),
                :ImagePosition => :Left,
                :Image => "multi save1",
            },
            :MULTISAVE2 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("If you have multiple save files, you can press <c2=0999367C><b>{1}</b></c2> or <c2=0999367C><b>{2}</b></c2> on the continue screen to change save files.",$PokemonSystem.game_controls.find{|c| c.control_action=="Left"}.key_name,$PokemonSystem.game_controls.find{|c| c.control_action=="Right"}.key_name),
                :Image => "multi save2",
            },
            :MULTISAVE3 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("To create another save file, you must save through the menu instead of using Quicksave. You must select a new slot."),
                :Image => "multi save3",
            },
            :ADVDEX1 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("Your Pokédex has an 'Advanced' page."),
                :Image => "advanced dex1",
            },
            :ADVDEX2 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("On this page, you will see advanced information about the selected Pokémon if you have caught it."),
                :Image => "advanced dex2",
            },
            :ADVDEX3 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("You can press <c2=0999367C><b>{1}</b></c2> to go to the next page.",$PokemonSystem.game_controls.find{|c| c.control_action=="Action"}.key_name),
                :Image => "advanced dex3",
            },
            :ADVDEX4 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("This information is also on the Untamed Wiki; This provides an alternative to view the information in-game."),
            },
            :BATTLEINFO1 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can view information about a battle by pressing <c2=0999367C><b>{1}</b></c2>.",$PokemonSystem.game_controls.find{|c| c.control_action=="Battle Info"}.key_name),
                :Image => "stats battle1",
            },
            :BATTLEINFO2 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see information such as stat changes, used moves, abilities, etc."),
                :Image => "stats battle2",
            },
            :BATTLEINFO3 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see similar information about your opponent(s) too."),
                :Image => "stats battle3",
            },
            :BATTLEINFO4 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can view information about the currently selected move by pressing <c2=0999367C><b>{1}</b></c2>.",$PokemonSystem.game_controls.find{|c| c.control_action=="Move Info"}.key_name),
                :Image => "stats battle4",
            },
            :BATTLEINFO5 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("For more information, view this tip again from the <c2=0999367C><b>Adventure Guide</b></c2> app on your phone."),
            },
            :BATTLEINFO6 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("About icons and stuff, more in depth"),
            },
        }

        TIP_CARDS_GROUPS = {
            :BEGINNER => {
                :Title => _INTL("Beginner Tips"),
                :Tips => [:CATCH, :CATCH2, :ITEMS, :ITEMS2]
            },
            :CATCHING => {
                :Title => _INTL("Catching Tips"),
                :Tips => [:CATCH, :CATCH2]
            },
            :ITEMS => {
                :Title => _INTL("Item Tips"),
                :Tips => [:ITEMS, :ITEMS2]
            },
            :BOOK1 => {
                :Title => _INTL("Book Alpha"),
                :Tips => [:BOOK1PAGE1, :BOOK1PAGE2, :BOOK1PAGE3, :BOOK1PAGE4]
            },
            :AUTOHEAL => {
                :Title => _INTL("Auto Heal"),
                :Tips => [:AUTOHEAL1, :AUTOHEAL2]
            },
            :MULTISAVE => {
                :Title => _INTL("Multi-save"),
                :Tips => [:MULTISAVE1, :MULTISAVE2, :MULTISAVE3]
            },
            :ADVDEX => {
                :Title => _INTL("Advanced Dex"),
                :Tips => [:ADVDEX1, :ADVDEX2, :ADVDEX3, :ADVDEX4]
            },
            :BATTLEINFO => {
                :Title => _INTL("Battle Info"),
                :Tips => [:BATTLEINFO1, :BATTLEINFO2, :BATTLEINFO3, :BATTLEINFO4, :BATTLEINFO6]
            },
        }

end