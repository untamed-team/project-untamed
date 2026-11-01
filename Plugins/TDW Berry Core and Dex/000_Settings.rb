module Settings
    #====================================================================================
    #================================ Berrydex Settings =================================
    #====================================================================================
    
        #--------------------------------------------------------------------------------
        # If true, the Berrydex will appear in the Pause Menu if the player has access. 
        # Otherwise, you'll need to set up other ways to view it using pbBerryDex.
        #--------------------------------------------------------------------------------	
        SHOW_BERRYDEX_IN_PAUSE_MENU       = false

        #--------------------------------------------------------------------------------
        # If true, any berries you receive before you get the BerryDex will not be 
        # "registered" and you'll need to receive berries again after receiving
        # the BerryDex to register them. If false, berries you've already received will
        # be "registered" when you receive the BerryDex.
        #--------------------------------------------------------------------------------	
        REQUIRE_BERRYDEX_BEFORE_REGISTRATION = false
    
        #--------------------------------------------------------------------------------
        # Switch ID to be set to true to have access to the Berrydex.
        # Set to 0 to always allow access.
        #--------------------------------------------------------------------------------	
        ACCESS_BERRYDEX_SWITCH_ID         = 0

        #--------------------------------------------------------------------------------
        # If true, the Berrydex will prepend the berry name with its number, determined
        # by the order it appears in berry_dexes.txt
        #--------------------------------------------------------------------------------		
        BERRYDEX_SHOW_NUMBER             = true

        #--------------------------------------------------------------------------------
        # If true, the Berrydex will show the entire list of potential berries from the
        # start, instead of only showing up through a berry that is registered.
        # For instance, if you have 60 berries defined in the dex, but you only have 
        # berry #2 registered, instead of showing #1 as unregistered and #2 as registered, 
        # it would show all 60 in the list, with unregistered berries still appearing
        # unregistered.
        # Note: This also makes it so the player can view the Berrydex without having
        # any berries registered! It will just show an empty list.
        #--------------------------------------------------------------------------------		
        BERRYDEX_SHOW_ENTIRE_LIST        = true

        #--------------------------------------------------------------------------------
        # If true, the images for berries in the Berrydex will use those found in the
        # Tag Icons folder, instead of their item icons. Item icons will be the fallback
        # if a Tag Icon image does not exist for a berry.
        #--------------------------------------------------------------------------------		
        BERRYDEX_USE_TAG_ICONS           = true

        #--------------------------------------------------------------------------------
        # When true, flavor stats on the Berrydex Tag page will use a pentagon.
        # The pentagon graph uses Marin's Better Bitmaps plugin, so it is required if true.
        # https://reliccastle.com/resources/169/
        #--------------------------------------------------------------------------------
        BERRYDEX_USE_PENTAGON_GRAPH		= true

        #--------------------------------------------------------------------------------
        # If true, show the berry's color on the Berrydex Tag page.
        #--------------------------------------------------------------------------------		
        BERRYDEX_SHOW_COLOR             = true

        #--------------------------------------------------------------------------------
        # Set to the max value the Flavor of Berries is. This is used for the pentagon
        # graph on the Berrydex Tag page to help scale the graph.
        #--------------------------------------------------------------------------------
        BERRYDEX_MAX_FLAVOR		        = 40

        #--------------------------------------------------------------------------------
        # If true, the Berrydex will have a page that shows information about the berry
        # that pertains to battles, like Fling damage, Natural Gift type and power, and
        # the effect when eaten.
        #--------------------------------------------------------------------------------		
        BERRYDEX_BATTLE_PAGE            = true

        #--------------------------------------------------------------------------------
        # If true, the Berrydex will have a page that shows the mutations that the berry
        # is a part of (either parent or child). 
        # Requires the Berry Planting Improvements plugin
        #--------------------------------------------------------------------------------		
        BERRYDEX_MUTATIONS_PAGE         = true

        #--------------------------------------------------------------------------------
        # If true, only berries that you have registered in the Berrydex will appear
        # when viewing the mutations page. Otherwise, they'll appear as unknown.
        #--------------------------------------------------------------------------------	
        BERRY_MUTATION_HIDE_UNREGISTERED    = true

        #--------------------------------------------------------------------------------
        # Defines how DryingPerHour values appear in the Berrydex's Plant tab. You can
        # define each range to meet your needs, or add additional ranges.
        # [Label to appear in the Dex, min value (inclusive), max value (inclusive)]
        #--------------------------------------------------------------------------------		
        BERRYDEX_DRY_RATE_CATEGORIES     = [
            [_INTL("Slow"),0,6],
            [_INTL("Average"),7,13],
            [_INTL("Fast"),14,22],
            [_INTL("Very Fast"),23,99]
        ]

end