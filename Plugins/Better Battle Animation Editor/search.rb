def pbOpenMoveSearch(animations, canvas, animwin, oldSearch = [])
  term = pbMessageFreeText(_INTL("Search for what?"), "", false, 32)
  return false if term == "" || term == nil
  stack = 1
  if oldSearch.length > 0
    stack = pbMessage(_INTL("Stack search terms?"), [_INTL("Yes"),_INTL("No")], 1)
  end
  
  newSearch = []
  if stack > 0
    animations.length.times do |i|
      animations[i] = PBAnimation.new if !animations[i]
      if animations[i].name.downcase.include?(term.downcase)
        newSearch[newSearch.length] = i
      end
    end
  else
    oldSearch.length.times do |i|
      animations[oldSearch[i]] = PBAnimation.new if !animations[oldSearch[i]]
      if animations[oldSearch[i]].name.downcase.include?(term.downcase)
        newSearch[newSearch.length] = oldSearch[i]
      end
    end
  end
  if newSearch.length < 1
    pbMessage(_INTL("No results found."))
    return []
  else
    return newSearch
  end
  return []
end

