#Are you also annoyed about music that ends, then starts from the beginning with no good transition? A good example is when you have a battle BGM and you want the intro of that BGM only played once and afterwards loop a certain part of the BGM (the actual "battle music").

#This very small script allows you to define BGMs that will behave like this. All BGM files that are part of the hash need a defined start and end position (in seconds). After reaching the defined end position, the script BGM will go back to the defined start position (not to the beginning of the BGM).

#Note: Make sure to double-check the entered values as I did not (yet) include checks (like if the entered end position is actually valid). I also did not test how this behaves when saving/loading the game.

module MusicLoops
  # Music looping: if a BGM file is listed here, the respective start and end
  # time will be used to loop the BGM after playing until the end once
  BGM = {
    "Battle Music" => [21.30, 69.20] # start, end (in seconds)
  }
end

class Game_System
  attr_accessor :bgm_loop_start
  attr_accessor :bgm_loops

  def bgm_play(bgm, track = nil)
    old_pos = @bgm_position
    @bgm_position = 0
    bgm_play_internal(bgm, 0, track)
    @bgm_position = old_pos
    if MusicLoops::BGM.has_key?(bgm.name)
      @bgm_loops = 0
      @bgm_loop_start = System.uptime
    end
  end

  def bgm_loop
    bgm = playing_bgm.name
    pbBGMFade(0.1)
    bgm_play_internal2("Audio/BGM/" + bgm, 100, 100, MusicLoops::BGM[bgm][0])
    @bgm_loop_start = System.uptime
    @bgm_loops += 1
  end

  alias bgmloop_update update unless method_defined?(:bgmloop_update)
  def update
    bgmloop_update
    return if !playing_bgm
    bgm = playing_bgm.name
    return if !MusicLoops::BGM.has_key?(bgm) || !@bgm_loop_start || @bgm_loop_start == 0
    # After intro is finished, jump back to loop start
    if System.uptime >= @bgm_loop_start + MusicLoops::BGM[bgm][1] && @bgm_loops == 0
      bgm_loop
      # After first loop, calculate timing based on loop duration (without intro)
    elsif System.uptime >= @bgm_loop_start + (MusicLoops::BGM[bgm][1] - MusicLoops::BGM[bgm][0]) && @bgm_loops > 0
      bgm_loop
    end
  end
end