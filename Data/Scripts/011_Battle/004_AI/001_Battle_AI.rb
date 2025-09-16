# AI skill levels:
#     0:     Wild Pokémon
#     1-31:  Basic trainer (young/inexperienced)
#     32-47: Some skill
#     48-99: High skill
#     100+:  Best trainers (Gym Leaders, Elite Four, Champion)
# NOTE: A trainer's skill value can range from 0-255, but by default only four
#       distinct skill levels exist. The skill value is typically the same as
#       the trainer's base money value.
module PBTrainerAI
  # Minimum skill level to be in each AI category.
  def self.minimumSkill; return 10; end
  def self.mediumSkill;  return 20; end
  def self.highSkill;    return 40; end
  def self.bestSkill;    return 80; end
end



class Battle::AI
  def initialize(battle)
    @battle = battle
  end

  def pbAIRandom(x); return rand(x); end

  def pbStdDev(choices)
    sum = 0
    n   = 0
    choices.each do |c|
      sum += c[1]
      n   += 1
    end
    return 0 if n < 2
    mean = sum.to_f / n
    varianceTimesN = 0
    choices.each do |c|
      next if c[1] <= 0
      deviation = c[1].to_f - mean
      varianceTimesN += deviation * deviation
    end
    # Using population standard deviation
    # [(n-1) makes it a sample std dev, would be 0 with only 1 sample]
    return Math.sqrt(varianceTimesN / n)
  end
end
