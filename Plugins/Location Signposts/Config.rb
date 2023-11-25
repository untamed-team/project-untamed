class LocationWindow
  # The path to the signpost images
  # Default: "Graphics/Maps/"
  PATH = "Graphics/Maps/"

  # Speed of the signpost animations (in frames)
  SHOW_FRAMES       = 18  # Show signpost
  HIDE_FRAMES       = 18  # Hide signpost
  HIDE_FRAMES_MENU  = 10  # Hide signpost (when a menu is opened)

  # Duration of the signpost (in frames)
  # Default: 140
  DURATION = 140

  # The signpost images to use and the keywords to match
  # "Filename" => ["Map name keyword 1","Map name keyword 2", ...]
  SIGNPOSTS = {
      "Route_1" => ["Route", "Path"],
      "Town_1"  => ["Town", "Village"],
      "Lake_1"  => ["Lake"],
      "Cave_1"  => ["Cave"],
      "City_1"  => ["City"],
      "Blank"   => ["Blank"]
  }
end