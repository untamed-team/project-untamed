class CrustangRacing

	def self.aiBoost
		###################################
		#============= Racer1 =============
		###################################
		self.moveEffect(@racer1, 0) if @racer1[:BoostCooldownTimer] <= 0

		###################################
		#============= Racer2 =============
		###################################
		self.moveEffect(@racer2, 0) if @racer2[:BoostCooldownTimer] <= 0

		###################################
		#============= Racer3 =============
		###################################
		self.moveEffect(@racer3, 0) if @racer3[:BoostCooldownTimer] <= 0

	end #def self.aiBoost
	
	def self.aiMove1
		###################################
		#============= Racer1 =============
		###################################
		racer = @racer1
		
		if racer[:Move1CooldownTimer] <= 0
			case self.getMoveEffect(racer, 1)
			#using 'case' so I can add conditions here since we don't want racers using the effect 100% of the time
			when "invincible"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "spinOut"
				racer[:SpinOutCharge] += 1 if racer[:SpinOutCharge] < CrustangRacingSettings::SPINOUT_MAX_RANGE
				if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE #get to the max range
					self.moveEffect(racer, 1) 
					self.beginCooldown(racer, 1)
				end #if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE
				
			when "overload"
				racer[:OverloadCharge] += 1 if racer[:OverloadCharge] < CrustangRacingSettings::OVERLOAD_MAX_RANGE
				if racer[:OverloadCharge] >= CrustangRacingSettings::OVERLOAD_MAX_RANGE #get to the max range
					self.moveEffect(racer, 1) 
					self.beginCooldown(racer, 1)
				end #if racer[:SpinOutCharge] >= CrustangRacingSettings::SPINOUT_MAX_RANGE

			when "reduceCooldown"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "secondBoost"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "rockHazard"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			when "mudHazard"
				self.moveEffect(racer, 1) 
				self.beginCooldown(racer, 1)
			end #case self.getMoveEffect(racer, 1)
		end #if racer[:Move1CooldownTimer] <= 0
		
	end #def self.useMove1


end #class CrustangRacing