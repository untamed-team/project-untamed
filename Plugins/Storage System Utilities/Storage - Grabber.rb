#===============================================================================
# Storage Grabber
# By Swdfm
# Used For Storage Utilities
#===============================================================================
class StorageGrabber
  def initialize
    clear
  end
  
  #===============================================================================
  # Adds hovered over pokemon to held pokemon
  #===============================================================================
  def add_to(position, position_1)
    @mons.push([position, position_1])
  end

  #===============================================================================
  # Is the grabber holding a Pokemon?
  #===============================================================================
  def holding_anything?
    return !@mons.empty?
  end
  
  #===============================================================================
  # Sets the pivot (top left Pokemon)
  #===============================================================================
  def setPivot(selection)
    @pivot      = selection
    @mock_pivot = selection
  end
  
  #===============================================================================
  # Begins hovering phase
  #===============================================================================
  def do_with(selection)
    p_col = @pivot % PokemonBox::BOX_WIDTH
    p_row = (@pivot / PokemonBox::BOX_WIDTH).floor
    s_col = selection % PokemonBox::BOX_WIDTH
    s_row = (selection / PokemonBox::BOX_WIDTH).floor
    @mons = []
    f_row = [p_row, s_row].min # F stands for flow
    f_col = [p_col, s_col].min
    @mock_pivot = f_col + f_row * PokemonBox::BOX_WIDTH
    for i in 0...PokemonBox::BOX_WIDTH
      next if (i < p_col && i < s_col) || (i > p_col && i > s_col)
      for j in 0...PokemonBox::BOX_HEIGHT
        next if (j < p_row && j < s_row) || (j > p_row && j > s_row)
        add_to(i - f_col,  j - f_row)
      end
    end
  end
  
  #===============================================================================
  # Is the grabber carrying?
  #===============================================================================
  def carrying
    return @carrying
  end
  
  def carrying=(value)
    @carrying = value
  end
  
  #===============================================================================
  # Adds Pokémon and their positions (relative to top left) to @carried_mons
  #===============================================================================
  def pack_up(storage, box_num)
    ret   = []
    p_col = @mock_pivot % PokemonBox::BOX_WIDTH
    p_row = (@mock_pivot / PokemonBox::BOX_WIDTH).floor
    for i in @mons
      x, y = i
      sel  = (p_row + y) * PokemonBox::BOX_WIDTH + (p_col + x)
      pkmn = storage[box_num, sel]
      ret.push([pkmn, x, y])
    end
    @carried_mons = ret
  end
  
  #===============================================================================
  # Gets storage index of carried mons for deletion
  #===============================================================================
  def get_carried_mons
    ret   = []
    p_col = @mock_pivot % PokemonBox::BOX_WIDTH
    p_row = (@mock_pivot / PokemonBox::BOX_WIDTH).floor
    for i in @carried_mons
      x = i[1] + p_col
      y = i[2] + p_row
      ret.push(y * PokemonBox::BOX_WIDTH + x)
    end
    return ret
  end
  
  #===============================================================================
  # Places mons in those positions
  # STOPS IF THERE IS NOT A SPACE FOR EVERY MON
  #===============================================================================
  def place_with_positions(storage, box_num, selection)
    s_col = selection % PokemonBox::BOX_WIDTH
    s_row = (selection / PokemonBox::BOX_WIDTH).floor
    can_place = true
    for i in @carried_mons
      col = s_col + i[1]
      if col >= PokemonBox::BOX_WIDTH
        can_place = false 
        next
      end
      row = s_row + i[2]
      if row >= PokemonBox::BOX_HEIGHT
        can_place = false
        next
      end
      pseudo_sel = row * PokemonBox::BOX_WIDTH + col
      can_place = false if storage[box_num, pseudo_sel] # Occupied
    end
    return can_place
  end
  
  #===============================================================================
  # Gets index number of mons proposed to be put in boxes in above def.
  #===============================================================================
  def get_new_carried_mons(selection)
    
    ret   = []
    s_col = selection % PokemonBox::BOX_WIDTH
    s_row = (selection / PokemonBox::BOX_WIDTH).floor
    for i in @carried_mons
      col = s_col + i[1]
      row = s_row + i[2]
      pseudo_sel = row * PokemonBox::BOX_WIDTH + col
      ret.push([pseudo_sel, i[0]])
    end
    return ret
  end
  
  #===============================================================================
  # Removes any poured Pokemon
  #===============================================================================
  def pour(count)
    return if count == 0
    to_del = get_new_carried_mons(0)
	to_del = to_del.sort{ |a, b| a[0] <=> b[0] }
	ret = @carried_mons.clone
	count.times do
	  ret.pop
	end
	@carried_mons = ret
  end
  
  #===============================================================================
  # Clears everything
  #===============================================================================
  def clear
    @mons         = []
    @pivot        = nil
    @mock_pivot   = nil
    @carrying     = false
    @carried_mons = []
  end
  
  #===============================================================================
  # Utilities
  #===============================================================================
  def mons
    return @mons
  end
  
  def mock_pivot
    return @mock_pivot
  end
  
  def contains_an_egg?
    for i in @carried_mons
      return true if i[0].egg?
    end
    return false
  end
  
  def carried_mons
    return @carried_mons
  end
end

#===============================================================================
# PokemonStorage override
#===============================================================================
class PokemonStorage
  def swap(one, two)
    t = @boxes[one]
    @boxes[one] = @boxes[two]
    @boxes[two] = t
  end
end