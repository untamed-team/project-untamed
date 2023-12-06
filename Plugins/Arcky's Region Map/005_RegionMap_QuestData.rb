class QuestData
    def getQuestMapPositions(mapData)
        questMap = []
        return if !$quest_data
        activeQuests = $PokemonGlobal.quests.active_quests
        return if !activeQuests
        activeQuests.each do |quest|
            mapId = ("Map" + "#{quest.stage}").to_sym
            if QuestModule.const_get(quest.id).key?(mapId)
                map = QuestModule.const_get(quest.id)[mapId]
            else
                map = QuestModule.const_get(quest.id)[:Map]
            end
            next if !map
            findMap = mapData[2].find { |point| point[0] == map[1] && point[1] == map[2]}
            map.push(quest, findMap[7]) if findMap && !map.include?(quest) && !map.include?(findMap[7]) 
            questMap.push(map)  
        end
        return questMap
    end
end