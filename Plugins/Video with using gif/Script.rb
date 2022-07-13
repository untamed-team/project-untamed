# Video with using Gif
# Credit: bo4p5687

module Video
	class Create
		# Dir of file
		DirGif  = "Gif"
		# Dir of audio, don't change it
		DirAudio = "Audio/BGM/#{DirGif}"
		# Key on keyboard
		StopKey  = :X
		BackKey  = :LEFT
		NextKey  = :RIGHT
		PauseKey = :Z
		# Times when press BackKey or NextKey
		OneSec   = 12 # Don't change it
		TimesKey = OneSec * 10 # 10 secs

		attr_writer :canpause
		attr_writer :canback
		attr_writer :cannext
		attr_writer :canstop

		def initialize
			@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
			@viewport.z = 99999
			@video = {}
			# Store for change video
			@audiotime = {}
			@giftime = {}
			# Create folder
			Dir.mkdir("#{DirGif}") if !safeExists?("#{DirGif}")
			Dir.mkdir("#{DirAudio}") if !safeExists?("#{DirAudio}")
			# Trigger 'pause'
			@paused = false
			# Trigger
			@canpause = @canback = @cannext = @canstop = true
			@exit = false
		end

		def setVideo(name=nil,volume=nil,pitch=nil)
			return if name.nil? || !name.is_a?(String)
			return if !File.exist?("#{DirGif}/#{name}.gif")
			@video[name.to_sym] = {} if !@video[name.to_sym]
			gif = Sprite.new(@viewport)
			gif.bitmap = Bitmap.new("#{DirGif}/#{name}.gif")
			gif.ox = gif.bitmap.width/2
			gif.oy = gif.bitmap.height/2
			gif.x  = Graphics.width / 2
			gif.y  = Graphics.height / 2
			gif.visible = false
			# Set gif
			@video[name.to_sym][:gif] = gif
			# Set audio
			@video[name.to_sym][:name]    = name
			@video[name.to_sym][:volume] = volume
			@video[name.to_sym][:pitch]  = pitch
		end

		# Show gif, play audio
		def show(name)
			return if !@sprites[name]
			pbUpdateSpriteHash(@sprites)
			@sprites[name].bitmap.play if @sprites[name].bitmap.animated? && !@paused
		end

		# Check finish
		def finishGif?(name)
			bitmap = @sprites[name].bitmap
			return bitmap.current_frame >= bitmap.frame_count-1
		end

		# Check when beginning
		def beginGif?(name)
			bitmap = @sprites[name].bitmap
			return bitmap.current_frame <= 0
		end

		# Store
		def storeGifinSprite(name)
			# Dispose
			@sprites.clear if @sprites
			# New
			sprite = {}
			@video.each { |k,v|
				sprite[k] = @video[k][:gif]
				sprite[k].bitmap.goto_and_stop(0)
				sprite[k].visible = k==name
			}
			@sprites = sprite
		end

		# Play audio
		def playAudio(name,nameaudio,position=nil)
			Audio.bgm_stop
			return if !FileTest.audio_exist?("#{DirAudio}/#{@video[name][:name]}")
			volume = @video[name][:volume].nil? ? 100 : @video[name][:volume]
			volume *= $PokemonSystem.bgmvolume/100.0
			volume = volume.to_i
			pitch  = @video[name][:pitch].nil? ? 100 : @video[name][:pitch]
			position.nil? ? Audio.bgm_play("#{DirAudio}/#{nameaudio}",volume,pitch) : Audio.bgm_play("#{DirAudio}/#{nameaudio}",volume,pitch,position)
		end

		# Set time on video
		def moveTimeVideo(name,namenext,nameback,namefirst,limit,once=false,back=false,time=TimesKey)
			changeb = false if !changeb
			changen = false if !changen
			gtozero = false if !gtozero # Return first video
			# Set bitmap
			bitmapzero = @sprites[namefirst].bitmap
			bitmapback = @sprites[nameback].bitmap rescue bitmapzero
			bitmap     = @sprites[name].bitmap     rescue bitmapzero
			bitmapnext = @sprites[namenext].bitmap rescue bitmapzero
			# Gif
			position = bitmap.current_frame
			# Back
			if back
				position -= time
				@giftime[:move] = position
				if position < 0
					if @position==0
						@giftime[:move] = 0
						gtozero = true
					else
						@giftime[:move] = bitmapback.frame_count + position
						changeb = true
					end
				end
			# Next
			else
				position += time
				@giftime[:move] = position
				if position >= bitmap.frame_count-1
					@position==limit-1 ? gtozero = true : changen = true
					@giftime[:move] = position - bitmap.frame_count
				end
			end
			if changeb
				self.storeGifinSprite(nameback)
				bitmapback.goto_and_play(@giftime[:move])
			elsif changen
				self.storeGifinSprite(namenext)
				bitmapnext.goto_and_play(@giftime[:move])
			elsif gtozero
				self.storeGifinSprite(namefirst)
				bitmapzero.goto_and_play(@giftime[:move])
			else
				bitmap.goto_and_play(@giftime[:move])
			end
			# Audio
			audiozero = @video[namefirst][:name] rescue nil
			audioback = @video[nameback][:name] rescue nil
			audio     = @video[name][:name] rescue nil
			audionext = @video[namenext][:name] rescue nil
			@audiotime[:move] = (@giftime[:move]+1) / 12.0
			Audio.bgm_stop
			if changeb && !audioback.nil?
				self.playAudio(nameback,audioback,@audiotime[:move])
			elsif changen && !audionext.nil?
				self.playAudio(namenext,audionext,@audiotime[:move])
			elsif gtozero
				self.playAudio(namefirst,audiozero,@audiotime[:move])
			else
				self.playAudio(name,audio,@audiotime[:move])
			end
			Graphics.frame_reset
			# Change video
			if once && (@position+1)==limit && gtozero && @giftime[:move]!=0
				@exit = true
				return
			end
			if changeb
				@position -= 1
				@position = 0 if @position<0
			elsif changen
				@position += 1
				@position = 0 if @position>=limit
			end
			@position = 0 if gtozero
		end

		# Next video
		def nextVideo(namesprite,limit)
			return false if @video.size<=1 || !self.finishGif?(namesprite)
			@position += 1
			@position = 0 if @position==limit
			return true
		end

		# Pause video
		def pauseVideo(name)
			return if !@paused
			@sprites[name].bitmap.stop
			# Store audio when pause
			@audiotime[:paused] = Audio.bgm_pos rescue 0
			Audio.bgm_stop
		end

		# Unpause video
		def unpauseVideo(name)
			return if @paused
			@sprites[name].bitmap.play
			self.playAudio(name,@video[name][:name],@audiotime[:paused])
		end

		# Check audio play
		def canPlayBgm?(name)
			return !@video[name][:name].nil? && FileTest.audio_exist?("#{DirAudio}/#{@video[name][:name]}")
		end

		#---------#
		# Looping #
		#---------#
		def play(once=false)
			return if @video.size <= 0
			name = @video.keys
			# Gif displays with order
			@position = 0
			# Check store
			stored = false
			# Check audio
			checkedaudio = false
			loop do
				Graphics.update
				Input.update
				# Store in @sprites
				if !stored
					self.storeGifinSprite(name[@position])
					stored = true
				end
				# Show animate
				self.show(name[@position])
				# Check audio
				if !checkedaudio
					Audio.bgm_stop
					self.playAudio(name[@position],@video[name[@position]][:name]) if canPlayBgm?(name[@position])
					checkedaudio = true
				end
				# Next or Back Video
				if Input.triggerex?(NextKey) && @cannext && !@paused
					self.moveTimeVideo(name[@position],name[@position+1],name[@position-1],name[0],name.size,once)
				elsif Input.triggerex?(BackKey) && @canback && !@paused
					self.moveTimeVideo(name[@position],name[@position+1],name[@position-1],name[0],name.size,once,true)
				elsif Input.triggerex?(PauseKey) && @canpause
					@paused = !@paused
					self.pauseVideo(name[@position])
					self.unpauseVideo(name[@position])
				end
				# Stop
				break if (Input.triggerex?(StopKey) && @canstop) || (self.finishGif?(name[@position]) && @position==name.size-1 && once) || @exit
				# Next gif if it exist
				if @video.size>1 && self.finishGif?(name[@position])
					self.nextVideo(name[@position],name.size)
					checkedaudio = false
					stored = false
				end
			end
		end

		# Dispose viewport
		def endVideo
			# Dispose
			@sprites.clear if @sprites
			@video.each { |k,v|
				s = @video[k][:gif]
				s.bitmap.stop
				s.dispose if s && !pbDisposed?(s)
			}
			@video.clear
			@viewport.dispose
		end
	end

	#--------------#
	# Def for call #
	#--------------#
	def self.once(cannext=true,canback=true,canpause=true,canstop=true)
		pbFadeOutInWithMusic {
			v = Create.new
			arr = yield
			if arr.is_a?(Array)
				arr.each { |a|
					next if !a.is_a?(Array)
					name, volume, pitch = a
					v.setVideo(name, volume, pitch)
				}
				v.cannext  = cannext
				v.canback  = canback
				v.canpause = canpause
				v.canstop  = canstop
				v.play(true)
			end
			v.endVideo
			pbWait(30)
			Graphics.frame_reset
		}
	end

	def self.multi(cannext=true,canback=true,canpause=true,canstop=true)
		pbFadeOutInWithMusic {
			v = Create.new
			arr = yield
			if arr.is_a?(Array)
				arr.each { |a|
					next if !a.is_a?(Array)
					name, volume, pitch = a
					v.setVideo(name, volume, pitch)
				}
				v.cannext  = cannext
				v.canback  = canback
				v.canpause = canpause
				v.canstop  = canstop
				v.play
			end
			v.endVideo
			pbWait(30)
			Graphics.frame_reset
		}
	end
end