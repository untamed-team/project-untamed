if Essentials::VERSION.include?("21")
  module GameData
    class TrainerType
      def self.map_icon_filename(tr_type)
        return self.check_file(tr_type, "Graphics/UI/Town Map/Icons/player_")
      end

      def self.player_map_icon_filename(tr_type)
        outfit = ($player) ? $player.outfit : 0
        return self.check_file(tr_type, "Graphics/UI/Town Map/Icons/player_", sprintf("_%d", outfit))
      end
    end 
  end 
end 