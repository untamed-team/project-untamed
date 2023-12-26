module OWShadowSettings
  # Set this to true if you want the event name and character name blacklists to be case sensitive.
  CASE_SENSITIVE_BLACKLISTS = false

  # If an event name contains one of these words, it will not have a shadow.
  SHADOWLESS_EVENT_NAME     = [
    "door", "nurse", "Healing balls", "Mart", "SmashRock", "StrengthBoulder",
    "CutTree", "HeadbuttTree", "BerryPlant", ".shadowless", ".noshadow", ".sl"
  ]

  # If the character file and event uses contains one of these words in its filename, it will not have a shadow.
  SHADOWLESS_CHARACTER_NAME = ["nil"]

  # If an event stands on a tile with one of these terrain tags, it will not have a shadow.
  # (Names can be seen in the script section "Terrain Tag")
  SHADOWLESS_TERRAIN_NAME   = [
    :Grass, :DeepWater, :StillWater, :Water, :Waterfall, :WaterfallCrest,
    :Puddle
  ]

  # If an event doesn't have a custom shadow defined, it will use this shadow graphic
  DEFAULT_SHADOW_FILENAME   = "defaultShadow"

  # Defaul shadow graphic used by the player
  PLAYER_SHADOW_FILENAME    = "defaultShadow"
end