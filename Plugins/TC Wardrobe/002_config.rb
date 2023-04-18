#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                       Temporal Chains' Wardrobe Script                       #
#                                     v1.0                                     #
#                            Resource by DarrylBD99                            #
#                           Backgrounds by StarWolff                           #
#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#               Implements a wardrobe that can makes events that               #
#                      changes the player's outfit easier                      #
#==============================================================================#
#             call the script $player.pbUnlockOutfit(outfit_index)             #
#                    (or just pbUnlockOutfit(outfit_index))                    #
#               in the event to unlock outfits into the wardrobe               #
#------------------------------------------------------------------------------#
#          call the script pbWardrobe in the event to access wardrobe          #
#==============================================================================#
#                                   WARNING                                    #
#------------------------------------------------------------------------------#
#        please make sure you make a new save before using this script         #
#==============================================================================#


#==============================================================================#
#                                   SETTINGS                                   #
#==============================================================================#
module WardrobeConfig
	# Determine the type of wardrobe you want:
    # 0 - A scroll selection like Yes or No choices
    # 1 - Wardrobe with custom GUI
    TYPE = 1

    # Outfit Names in order of number index (must keep/consist of base outfit)
    OUTFITS = [
        "Basic Clothes"
    ]

	# Change background style (only works if TYPE is 1):
    # 0 - Basic Background
    # 1 - Basic Background (Pokeball Silhouette)
    # 2 - Basic Background (Pikachu Silhouette)
    # 3 - Elite Trainer Background
    # 4 - Sword and Shield Background
    BG_TYPE = 1
end
#==============================================================================#
