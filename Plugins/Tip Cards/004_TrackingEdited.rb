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
    if sections.length > 1 || (sections.length == 1 && Settings::TIP_CARDS_SINGLE_GROUP_SHOW_HEADER)
        scene = AdventureGuide_Scene.new(sections, true, continuous)
        screen = AdventureGuide_Screen.new(scene)
        screen.pbStartScreen
    elsif sections[0]
        tips = Settings::TIP_CARDS_GROUPS[sections[0]][:Tips]
        arr = []
        tips.each do |tip| 
            next if !Settings::TIP_CARDS_CONFIGURATION[tip] || Settings::TIP_CARDS_CONFIGURATION[tip][:HideRevisit] || 
            !pbSeenTipCard?(tip)
            arr.push(tip)
        end
        pbShowTipCard(*arr)
    else
		pbMessage(_INTL("The app is empty..."))
		Console.echo_warn "No available tips to show"
    end
end