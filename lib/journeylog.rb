class JourneyLog
  attr_reader :journey_class
  def initialize(journey_class )
    @journey_class = journey_class
    @journeys = []
  end

end
