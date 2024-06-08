class CrustangRacing
	def self.collides_with?(player,object)
		if (object.x + object.width  >= player.x) && (object.x <= player.x + player.width) &&
			 (object.y + object.height >= player.y) && (object.y <= player.y + player.height)
			return true
		end
	end
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end