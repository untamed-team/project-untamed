def adventureGuideApp(*groups, continuous: false)
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