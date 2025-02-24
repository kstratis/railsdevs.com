class LocationComponent < ApplicationComponent
  def initialize(location)
    @city = location&.city
    @state = location&.state
    @country = location&.country
    @country_code = location&.country_code
  end

  def render?
    @city.present? || @state.present? || @country.present?
  end

  def location
    if us_or_uk?
      "#{@city}, #{@state}"
    else
      "#{@city}, #{@country}"
    end
  end

  def us_or_uk?
    %w[us gb].include?(@country_code&.downcase)
  end
end
