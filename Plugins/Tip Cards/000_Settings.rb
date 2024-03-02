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
        }

end