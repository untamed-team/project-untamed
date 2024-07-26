class CrustangRacing

	def self.aiBoostWhenPossible
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

	end #def self.boostWhenPossible


end #class CrustangRacing