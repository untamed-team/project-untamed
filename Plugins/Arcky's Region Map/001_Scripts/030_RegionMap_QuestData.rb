class QuestData
  def getQuestMapPositions(mapData, region)
    return if !$quest_data
    activeQuests = $PokemonGlobal.quests.active_quests
    return if !activeQuests
    questMap = []
    activeQuests.each do |quest|
      mapId = ("Map" + "#{quest.stage}").to_sym
      if QuestModule.const_get(quest.id).key?(mapId)
        map = QuestModule.const_get(quest.id)[mapId]
      else
        map = QuestModule.const_get(quest.id)[:Map]
      end
      next unless map && map[0] == region
      findMap = mapData.find { |point| point[0..1] == map[1..2] }
      map[4] = map[3] if map[3].is_a?(String) 
      switch = findMap[7] if findMap
      if (findMap || (map[3] && !map[3].is_a?(String))) && !map.include?(quest)
        questMap << [map[0..2], quest, switch, map[4]].flatten
      end 
    end
    return questMap
  end
end