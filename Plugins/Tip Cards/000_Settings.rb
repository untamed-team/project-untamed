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
        #  If set to true, when the player uses the SPECIAL control, a list of all
        #  groups available to view will appear for the player to jump to one.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_GROUP_LIST = false

        #--------------------------------------------------------------------------------
        #  Set the default text colors
        #--------------------------------------------------------------------------------	
        TIP_CARDS_TEXT_MAIN_COLOR       = Color.new(80, 80, 88)
        TIP_CARDS_TEXT_SHADOW_COLOR     = Color.new(160, 160, 168)

        #--------------------------------------------------------------------------------
        #  Set the sound effect to play when showing, dismissing, and switching tip cards.
        #  For TIP_CARDS_SWITCH_SE, set to nil to use the default cursor sound effect.
        #--------------------------------------------------------------------------------	
        TIP_CARDS_SHOW_SE               = "GUI menu open"
        TIP_CARDS_DISMISS_SE            = "GUI menu close"
        TIP_CARDS_SWITCH_SE             = nil

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
				:ImageAdvGuide => "auto heal1",
                :YAdjustment => 64,
                :YAdjustmentAdvGuide => -20,
                :ImagePosition => :Bottom,
            },
            :AUTOHEAL2 => {
                :Title => _INTL("Auto Heal"),
                :Text => _INTL("Highlight the Pokémon you want to heal from the party menu and press the button next to <c2=0999367C><b>Auto Heal</b></c2>."),
                :Image => "auto heal2",
                :ImageAdvGuide => "auto heal2",
            },
            :MULTISAVE1 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("When saving for the first time, you will select a save slot."),
                :ImagePosition => :Left,
                :Image => "multi save1",
                :ImageAdvGuide => "multi save1",
            },
            :MULTISAVE2 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("If you have multiple save files, you can press the <c2=0999367C><b>Left</b></c2> or <c2=0999367C><b>Right</b></c2> key on the continue screen to change save files."),
                :Image => "multi save2",
                :ImageAdvGuide => "multi save2",
            },
            :MULTISAVE3 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("To create another save file, you must save through the menu instead of using Quicksave. You must select a new slot."),
                :Image => "multi save3",
                :ImageAdvGuide => "multi save3",
            },
            :ADVDEX1 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("Your Pokédex has an 'Advanced' page."),
                :Image => "advanced dex1",
                :ImageAdvGuide => "advanced dex1",
            },
            :ADVDEX2 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("On this page, you will see advanced information about the selected Pokémon if you have caught it."),
                :Image => "advanced dex2",
                :ImageAdvGuide => "advanced dex2",
            },
            :ADVDEX3 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("You can press <c2=0999367C><b>Action</b></c2> to go to the next page."),
                :Image => "advanced dex3",
                :ImageAdvGuide => "advanced dex3",
            },
            :ADVDEX4 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("This information is also on the Untamed Wiki; This provides an alternative to view the information in-game."),
            },
            :ADVDEX5 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("You can press <c2=0999367C><b>BUTTON</b></c2> from the main Pokédex page to access the search function."),
                :Image => "advanced dex5",
                :ImageAdvGuide => "advanced dex5",
            },
            :BATTLEINFO1 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can view information about a battle by pressing the <c2=0999367C><b>Battle Info</b></c2> key."),
                :Image => "stats battle1",
                :ImageAdvGuide => "stats battle1",
            },
            :BATTLEINFO2 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see information such as stat changes, used moves, abilities, etc."),
                :Image => "stats battle2",
                :ImageAdvGuide => "stats battle2",
            },
            :BATTLEINFO3 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see similar information about your opponent(s) too."),
                :Image => "stats battle3",
                :ImageAdvGuide => "stats battle3",
            },
            :BATTLEINFO4 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can view information about the currently selected move by pressing the <c2=0999367C><b>Move Info</b></c2> key."),
                :Image => "stats battle4",
                :ImageAdvGuide => "stats battle4",
            },
            :BATTLEINFO5 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("For more information, view this tip again from the <c2=0999367C><b>Adventure Guide</b></c2> app on your phone."),
            },
            :BATTLEINFO6 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("From left to right, the icons you'll see on moves are: Contact, Tramples Minimize, High Crit Rate, Sound, Punching..."),
                :Image => "move_icons1",
                :ImageAdvGuide => "move_icons1",
            },
            :BATTLEINFO7 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("Biting, Bomb, Pulse, Powder, Dance."),
                :Image => "move_icons2",
                :ImageAdvGuide => "move_icons2",
            },
            :CAMP1 => {
                :Title => _INTL("Camp"),
                :Text => _INTL("With the <c2=0999367C><b>Camping Gear</b></c2>, you can access Camp from the pause menu. You can access Camp from many different places like on the grass, in a cave, etc."),
            },
            :CAMP2 => {
                :Title => _INTL("Camp"),
                :Text => _INTL("Inside Camp, you can interact with your Pokémon in several ways."),
                :Image => "camp interact",
                :ImageAdvGuide => "camp interact",
            },
            :COOKING1 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Inside Camp, you can create your own candy over the camp fire if you have candy bases and berries!"),
                :Image => "cooking1",
                :ImageAdvGuide => "cooking1",
            },
            :COOKING2 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("To make candy, hold the left mouse button with the spoon in the pot and drag the spoon around like the arrows indicate. Don't let your candy burn from not being stirred!"),
                :Image => "cooking2",
                :ImageAdvGuide => "cooking2",
            },
            :COOKING3 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Cool off the mixture."),
                :Image => _INTL("cooking3"),
                :ImageAdvGuide => _INTL("cooking3"),
            },
            :COOKING4 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Feeding this candy to your Pokémon will increase its stats for Pokémon Contests! You can feed your Pokémon from your candy case."),
                :Image => _INTL("cooking4"),
                :ImageAdvGuide => _INTL("cooking4"),
            },
        }

        TIP_CARDS_GROUPS = {
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
                :Tips => [:ADVDEX1, :ADVDEX2, :ADVDEX3, :ADVDEX4, :ADVDEX5]
            },
            :BATTLEINFO => {
                :Title => _INTL("Battle Info"),
                :Tips => [:BATTLEINFO1, :BATTLEINFO2, :BATTLEINFO3, :BATTLEINFO4, :BATTLEINFO6, :BATTLEINFO7]
            },
            :CAMP => {
                :Title => _INTL("Camp"),
                :Tips => [:CAMP1, :CAMP2]
            },
            :COOKING => {
                :Title => _INTL("Cooking Candy"),
                :Tips => [:COOKING1, :COOKING2, :COOKING3]
            },
        }
end