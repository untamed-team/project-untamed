class CrustangRacing
	def self.collides_with?(racer,object)
		if (object.x + object.width-object.width >= racer.x) && (object.x <= racer.x + racer.width) &&
			 (object.y + object.height >= racer.y) && (object.y <= racer.y + racer.height)
			return true
		end
	end
	
	#colliding with something in a direction
	def self.collides_with_object_above?(racer,object)
		#is the racer colliding with something above them?
		return true if object.y < racer.y && racer.y.between?(object.y, object.y + object.height) && (racer.x.between?(object.x, object.x + object.width) || object.x.between?(racer.x, racer.x + racer.width))
	end
	def self.collides_with_object_below?(racer,object)
		#is the racer colliding with something below them?
		return true if object.y > racer.y && object.y.between?(racer.y, racer.y + racer.height) && (object.x.between?(racer.x, racer.x + racer.width) || racer.x.between?(object.x, object.x + object.width))
	end
	def self.collides_with_object_behind?(racer,object)
		#is the racer colliding with something behind them?
		return true if self.collides_with?(racer,object) && object.x < racer.x
	end
	def self.collides_with_object_front?(racer,object)
		#is the racer colliding with something in front of them?
		return true if self.collides_with?(racer,object) && object.x > racer.x
	end
end #class CrustangRacing

#from http://stackoverflow.com/questions/3668345/calculate-percentage-in-ruby
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.0
  end
end