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
        TIP_CARDS_GROUP_LIST = true

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
			#--------------------------------------------------------------------------------
			#  Tutorial
			#--------------------------------------------------------------------------------
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
            #--------------------------------------------------------------------------------
			#  Autoheal
			#--------------------------------------------------------------------------------
            :AUTOHEAL1 => {
                :Title => _INTL("Auto Heal"),
                :Text => _INTL("The Auto Heal feature will automatically select items from your bag and use them to heal your Pokémon."),
                :Image => "auto heal1",
				:ImageAdvGuide => "auto heal1",
                :YAdjustment => 64,
                :YAdjustmentAdvGuide => -20,
            },
            :AUTOHEAL2 => {
                :Title => _INTL("Auto Heal"),
                :Text => _INTL("Highlight the Pokémon you want to heal from the party menu and press the button next to <c2=0999367C><b>Auto Heal</b></c2>."),
                :Image => "auto heal2",
                :ImageAdvGuide => "auto heal2 - guide",
                :YAdjustmentAdvGuide => -20,
            },
            #--------------------------------------------------------------------------------
			#  Multisave
			#--------------------------------------------------------------------------------
            :MULTISAVE1 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("When saving for the first time, you will select a save slot."),
                :Image => "multi save1",
                :ImageAdvGuide => "multi save1 - guide",
                :YAdjustmentAdvGuide => -16,
            },
            :MULTISAVE2 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("Press the <c2=0999367C><b>Left</b></c2> or <c2=0999367C><b>Right</b></c2> key on the continue screen to change save files."),
                :Image => "multi save2",
                :ImageAdvGuide => "multi save2 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :MULTISAVE3 => {
                :Title => _INTL("Multi-save"),
                :Text => _INTL("To create another save file, you must save through the menu instead of using Quicksave. You must select a new slot."),
                :Image => "multi save3",
                :ImageAdvGuide => "multi save3 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            #--------------------------------------------------------------------------------
			#  Advanced Dex
			#--------------------------------------------------------------------------------
            :ADVDEX1 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("Your Pokédex has an 'Advanced' page."),
                :Image => "advanced dex1",
                :ImageAdvGuide => "advanced dex1 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :ADVDEX2 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("It shows advanced information about the selected Pokémon."),
                :Image => "advanced dex2",
                :ImageAdvGuide => "advanced dex2 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :ADVDEX3 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("Press <c2=0999367C><b>Action</b></c2> to go to the next page."),
                :Image => "advanced dex3",
                :ImageAdvGuide => "advanced dex3 - guide",
                :YAdjustmentAdvGuide => -26,
            },
            :ADVDEX4 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("This information is also on the Untamed Wiki."),
                :YAdjustmentAdvGuide => 60,
            },
            :ADVDEX5 => {
                :Title => _INTL("Advanced Dex"),
                :Text => _INTL("Press <c2=0999367C><b>BUTTON</b></c2> from the main Pokédex page to use the search function."),
                :Image => "advanced dex5",
                :ImageAdvGuide => "advanced dex5 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            #--------------------------------------------------------------------------------
			#  Battle Info
			#--------------------------------------------------------------------------------
            :BATTLEINFO1 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("View information about the battle by pressing the <c2=0999367C><b>Battle Info</b></c2> key."),
                :Image => "stats battle1",
                :ImageAdvGuide => "stats battle1 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :BATTLEINFO2 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see information such as stat changes, used moves, abilities, etc."),
                :Image => "stats battle2",
                :ImageAdvGuide => "stats battle2 - guide",
                :YAdjustmentAdvGuide => -42,
            },
            :BATTLEINFO3 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("You can see similar information about your opponent(s) too."),
                :Image => "stats battle3",
                :ImageAdvGuide => "stats battle3 - guide",
                :YAdjustmentAdvGuide => -42,
            },
            :BATTLEINFO4 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("View information about the selected move by pressing the <c2=0999367C><b>Move Info</b></c2> key."),
                :Image => "stats battle4",
                :ImageAdvGuide => "stats battle4 - guide",
                :YAdjustmentAdvGuide => -42,
            },
            :BATTLEINFO5 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("For more information, view this tip again from the <c2=0999367C><b>Adventure Guide</b></c2> app on your phone."),
            },
            :BATTLEINFO6 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("From left to right, these icons are: Contact, Tramples Minimize, High Crit Rate, Sound, Punching..."),
                :Image => "move_icons1",
                :ImageAdvGuide => "move_icons1 - guide",
                :YAdjustmentAdvGuide => -12,
            },
            :BATTLEINFO7 => {
                :Title => _INTL("Battle Info"),
                :Text => _INTL("Biting, Bomb, Pulse, Powder, Dance."),
                :Image => "move_icons2",
                :ImageAdvGuide => "move_icons2 - guide",
            },
            #--------------------------------------------------------------------------------
			#  Camp
			#--------------------------------------------------------------------------------
            :CAMP1 => {
                :Title => _INTL("Camp"),
                :Text => _INTL("With the <c2=0999367C><b>Camping Gear</b></c2>, you can access Camp from the pause menu. You can access Camp from many different places like on the grass, in a cave, etc."),
                :YAdjustmentAdvGuide => 60,
            },
            :CAMP2 => {
                :Title => _INTL("Camp"),
                :Text => _INTL("Inside Camp, you can interact with your Pokémon in several ways."),
                :Image => "camp interact",
                :ImageAdvGuide => "camp interact - guide",
                :YAdjustmentAdvGuide => -36,
            },
            #--------------------------------------------------------------------------------
			#  Cooking
			#--------------------------------------------------------------------------------
            :COOKING1 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Inside Camp, you can create your own candy over the camp fire if you have candy bases and berries!"),
                :Image => "cooking1",
                :ImageAdvGuide => "cooking1 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :COOKING2 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Hold the left mouse button with the spoon in the pot. Drag the spoon around like the arrows indicate."),
                :Image => "cooking2",
                :ImageAdvGuide => "cooking2 - guide",
                :YAdjustmentAdvGuide => -36,
            },
            :COOKING3 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Cool off the mixture."),
                :Image => _INTL("cooking3"),
                :ImageAdvGuide => _INTL("cooking3 - guide"),
                :YAdjustmentAdvGuide => -36,
            },
            :COOKING4 => {
                :Title => _INTL("Cooking Candy"),
                :Text => _INTL("Feeding this candy to your Pokémon will increase its stats for Pokémon Contests! You can feed your Pokémon from your candy case."),
                :Image => _INTL("cooking4"),
                :ImageAdvGuide => _INTL("cooking4 - guide"),
            },
            #--------------------------------------------------------------------------------
			#  Trading
			#--------------------------------------------------------------------------------
            :TRADING1 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Choose a Pokémon, then select 'Offer as Trade'."),
                :Image => "trading1",
                :ImageAdvGuide => "trading1",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING2 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("An 'Offer' file will be created. Choose 'Open Trading Folder' to find it."),
                :Image => "trading2",
                :ImageAdvGuide => "trading2",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING3 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Send the other player your offer file. They should do the same."),
                :Image => "trading3",
                :ImageAdvGuide => "trading3",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING4 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Download the 'Offer' file the other player sends you..."),
                :Image => "trading4",
                :ImageAdvGuide => "trading4",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING5 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("and put that offer file into your Trading folder."),
                :Image => "trading5",
                :ImageAdvGuide => "trading5",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING6 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("In the game, select the option 'Check Offer'."),
                :Image => "trading6",
                :ImageAdvGuide => "trading6",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING7 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Check the Pokémons' summaries here or select 'Accept Trade' if you agree."),
                :Image => "trading7",
                :ImageAdvGuide => "trading7",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING8 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("If you accept, an 'Agreement' file will be created in your Trading folder."),
                :Image => "trading8",
                :ImageAdvGuide => "trading8",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING9 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Send the other player your agreement file. They should do the same."),
                :Image => "trading9",
                :ImageAdvGuide => "trading9",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING10 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("Download the 'Agreement' file the other player sends you..."),
                :Image => "trading10",
                :ImageAdvGuide => "trading10",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING11 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("and put that agreement file into your Trading folder."),
                :Image => "trading11",
                :ImageAdvGuide => "trading11",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING12 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("In the game, select the option 'Finalize Trade'."),
                :Image => "trading12",
                :ImageAdvGuide => "trading12",
                :YAdjustmentAdvGuide => -36,
            },
            :TRADING13 => {
                :Title => _INTL("Trading"),
                :Text => _INTL("The trade will commence for you. Happy trading!"),
                :Image => "trading13",
                :ImageAdvGuide => "trading13",
                :YAdjustmentAdvGuide => -36,
            },
			#--------------------------------------------------------------------------------
			#  Berry Planting
			#--------------------------------------------------------------------------------
            :ABOUTBERRIES1 => {
                :Title => _INTL("Berries: About"),
                :Text => _INTL("When interacting with soft soil, you can plant any berry you have in your bag."),
                :Image => "about berries 1",
                :ImageAdvGuide => "about berries 1",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTBERRIES2 => {
                :Title => _INTL("Berries: About"),
                :Text => _INTL("After planting a berry, you can water it. All berries need water to grow! Make sure you water it when the soil dries out, otherwise the tree won't produce a decent harvest!"),
                :Image => "", #[Show image of player watering berries]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTBERRIES3 => {
                :Title => _INTL("Berries: About"),
                :Text => _INTL("It takes time for your berry trees to grow large enough to yield berries. To ensure a healthy crop, keep them watered and pull up any weeds. Once your trees mature, you'll be able to harvest the berries."),
                :Image => "", #[Show image of player obtaining large harvest]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTBERRIES4 => {
                :Title => _INTL("Berries: About"),
                :Text => _INTL("Different berries have different effects. Some berries heal status conditions, while others have even more useful benefits."),
                :Image => "", #[Show image of several different berries that have effects]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTBERRIES5 => {
                :Title => _INTL("Berries: About"),
                :Text => _INTL("Although most berries are hard to come by, you can grow as many as you like in soft soil. They're great for making candy over a campfire or feeding them to your Pokémon to make them happy!"),
                :Image => "", #[Show player next to many sprouting berry trees, player facing camera]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTCULTIVARS1 => {
                :Title => _INTL("Berries: Cultivars"),
                :Text => _INTL("Many berries that have special effects can only produce cultivars of themselves, which have no special effects."),
                :Image => "", #[Show image of player harvesting cultivar]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTCULTIVARS2 => {
                :Title => _INTL("Berries: Cultivars"),
                :Text => _INTL("Berries that are not cultivars can be quite rare, so be sure you want to plant them before you do! Alternatively, if you come across a cultivar, you can plant it to grow more of that cultivar."),
                :Image => "", #no image
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTMUTATIONS1 => {
                :Title => _INTL("Berries: Mutations"),
                :Text => _INTL("Mutations can sometimes occur when two different trees are planted next to each other. For example, an Aspear Berry and a Leppa Berry planted next to each other will sometimes give rise to a mutation."),
                :Image => "", #[Show image of mutation sprouted between two berry trees]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTMUTATIONS2 => {
                :Title => _INTL("Berries: Mutations"),
                :Text => _INTL("Some berries are so rare, they've only been found through mutations! Try planting as many different trees next to each other as you can, and see what develops!"),
                :Image => "", #[add silouettes of rare berry only obtained through mutation]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTMULCH1 => {
                :Title => _INTL("Berries: Mulch"),
                :Text => _INTL("Mulch can help your berry trees yield greater crops-or even surprising ones."),
                :Image => "", #no image
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTMULCH2 => {
                :Title => _INTL("Berries: Mulch"),
                :Text => _INTL("When interacting with soft soil, you can use any mulch you have in your bag. Only one bag of mulch can be used on a soil spot at one time until a berry is planted there and harvested."), #I think? I need to test
                :Image => "", #[Show image of mulch on soil (I think I have a graphic for it)]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:ABOUTMULCH3 => {
                :Title => _INTL("Berries: Mulch"),
                :Text => _INTL("First inspect a patch of soft soil to spread the mulch, then plant a berry."),
                :Image => "", #[Show images of different mulch]
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:BERRYAPPS1 => {
                :Title => _INTL("Berries: Helpful Apps"),
                :Text => _INTL("The berry mode on the town map app can also show you which berries are ready to harvest, which need to be watered, etc."),
                :Image => "", #no image
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:BERRYAPPS2 => {
                :Title => _INTL("Berries: Helpful Apps"),
                :Text => _INTL("This will only show on the map for berries you've planted. Naturally-occurring berries don't appear on the town map."),
                :Image => "", #no image
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
			:BERRYAPPS3 => {
                :Title => _INTL("Berries: Helpful Apps"),
                :Text => _INTL("The Berrydex app on your phone shows you all the berries you've discovered as well as the mutations needed to produce those berries."), #I think - need to test
                :Image => "", #no image
                :ImageAdvGuide => "",
                :YAdjustmentAdvGuide => -36,
            },
        }
		
		#--------------------------------------------------------------------------------
		#  Tip Card Groups
		#--------------------------------------------------------------------------------
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
            :TRADING => {
                :Title => _INTL("Trading"),
                :Tips => [:TRADING1, :TRADING2, :TRADING3, :TRADING4, :TRADING5, :TRADING6, :TRADING7, :TRADING8, :TRADING9, :TRADING10, :TRADING11, :TRADING12, :TRADING13]
            },
            :ABOUTBERRIES => {
                :Title => _INTL("About Berries"),
                :Tips => [:ABOUTBERRIES1, :ABOUTBERRIES2, :ABOUTBERRIES3, :ABOUTBERRIES4, :ABOUTBERRIES5]
            },
			:ABOUTCULTIVARS => {
                :Title => _INTL("Berry Cultivars"),
                :Tips => [:ABOUTCULTIVARS1, :ABOUTCULTIVARS1]
            },
            :ABOUTMUTATIONS => {
                :Title => _INTL("Berry Mutations"),
                :Tips => [:ABOUTMUTATIONS1, :ABOUTMUTATIONS2]
            },
            :ABOUTMULCH => {
                :Title => _INTL("About Berry Mulch"),
                :Tips => [:ABOUTMULCH1, :ABOUTMULCH2, :ABOUTMULCH3]
            },
            :BERRYAPPS => {
                :Title => _INTL("Berry Farming: Helpful Apps"),
                :Tips => [:BERRYAPPS1, :BERRYAPPS2, :BERRYAPPS3]
            },
        }
end