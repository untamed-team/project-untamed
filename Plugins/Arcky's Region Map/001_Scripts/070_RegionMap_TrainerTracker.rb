if ARMSettings::PROGRESS_COUNTER && ARMSettings::PROGRESS_COUNT_TRAINERS
  EventHandlers.add(:on_end_battle, :trainer_tracker,
    proc { |decision, canLose|
      if decision == 1 || canLose
        map = $game_map
        unless map.nil?
          unless pbMapInterpreter.get_self.nil?
            eventID = pbMapInterpreter.get_self.id
            if map.events[eventID].name[/trainer/i]
              district = getDistrictName(map.metadata)
              $ArckyGlobal.trainerTracker[district] ||= { :total => 0 }
              $ArckyGlobal.trainerTracker[district][:maps] ||= {}
              $ArckyGlobal.trainerTracker[district][:maps][map.map_id] ||= {:defeated => 0}
              $ArckyGlobal.trainerTracker[district][:maps][map.map_id][eventID] ||= { :defeated => 0 }
              unless $ArckyGlobal.trainerTracker[district][:maps][map.map_id][eventID][:defeated] != 0
                $ArckyGlobal.trainerTracker[district][:maps][map.map_id][eventID][:defeated] += $ArckyGlobal.trainerTracker[:trainers]
                $ArckyGlobal.trainerTracker[district][:total] += $ArckyGlobal.trainerTracker[:trainers]
                $ArckyGlobal.trainerTracker[district][:maps][map.map_id][:defeated] += $ArckyGlobal.trainerTracker[:trainers]
              end
            end 
          end
        end 
      end
    }
  )

  class TrainerBattle
    def self.start_core(*args)
      outcome_variable = $game_temp.battle_rules["outcomeVar"] || 1
      can_lose         = $game_temp.battle_rules["canLose"] || false
      # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
      if BattleCreationHelperMethods.skip_battle?
        return BattleCreationHelperMethods.skip_battle(outcome_variable, true)
      end
      # Record information about party Pokémon to be used at the end of battle (e.g.
      # comparing levels for an evolution check)
      EventHandlers.trigger(:on_start_battle)
      # Generate information for the foes
      foe_trainers, foe_items, foe_party, foe_party_starts = TrainerBattle.generate_foes(*args)
      $ArckyGlobal.trainerTracker[:trainers] ||= 0
      $ArckyGlobal.trainerTracker[:trainers] = foe_trainers.length
      # Generate information for the player and partner trainer(s)
      player_trainers, ally_items, player_party, player_party_starts = BattleCreationHelperMethods.set_up_player_trainers(foe_party)
      # Create the battle scene (the visual side of it)
      scene = BattleCreationHelperMethods.create_battle_scene
      # Create the battle class (the mechanics side of it)
      battle = Battle.new(scene, player_party, foe_party, player_trainers, foe_trainers)
      battle.party1starts = player_party_starts
      battle.party2starts = foe_party_starts
      battle.ally_items   = ally_items
      battle.items        = foe_items
      # Set various other properties in the battle class
      setBattleRule("#{foe_trainers.length}v#{foe_trainers.length}") if $game_temp.battle_rules["size"].nil?
      BattleCreationHelperMethods.prepare_battle(battle)
      $game_temp.clear_battle_rules
      # Perform the battle itself
      outcome = 0
      pbBattleAnimation(pbGetTrainerBattleBGM(foe_trainers), (battle.singleBattle?) ? 1 : 3, foe_trainers) do
        pbSceneStandby { outcome = battle.pbStartBattle }
        BattleCreationHelperMethods.after_battle(outcome, can_lose)
      end
      Input.update
      # Save the result of the battle in a Game Variable (1 by default)
      BattleCreationHelperMethods.set_outcome(outcome, outcome_variable, true)
      return outcome
    end
  end 
end 