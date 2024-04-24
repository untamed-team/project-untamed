def adventureGuideApp(*groups, continuous: false)
	#before opening the tips log, if this isn't the first time saving, set the tips for multisave as seen if they are not set to seen already
	if SaveData.get_newest_save_slot && !pbSeenTipCard?(:MULTISAVE1)
		pbSetTipCardSeen(:MULTISAVE1) 
		pbSetTipCardSeen(:MULTISAVE2)
		pbSetTipCardSeen(:MULTISAVE3)
	end
	
    groups = Settings::TIP_CARDS_GROUPS.keys if !groups || groups.empty?
    sections = []
    groups.each_with_index do |group, i|
        group = Settings::TIP_CARDS_GROUPS[group]
        next unless group
        group[:Tips].each do |tip|
            next if !Settings::TIP_CARDS_CONFIGURATION[tip] || Settings::TIP_CARDS_CONFIGURATION[tip][:HideRevisit] || 
                !pbSeenTipCard?(tip)
            sections.push(groups[i])
            break
        end
    end
    if sections.length > 0
        scene = AdventureGuide_Scene.new(sections, true, continuous)
        screen = AdventureGuide_Screen.new(scene)
        screen.pbStartScreen
    else
		pbMessage(_INTL("The app is empty..."))
		Console.echo_warn "No available tips to show"
    end
end