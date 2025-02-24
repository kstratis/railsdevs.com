require "test_helper"

class LocationComponentTest < ViewComponent::TestCase
  test "doesn't render if city, state, and country aren't present" do
    render_inline LocationComponent.new(nil)
    assert_no_select "*"

    render
    assert_no_select "*"
  end

  test "renders if city, state, or country is present" do
    render(city: "Suffern")
    assert_selector "*"

    render(state: "New York")
    assert_selector "*"

    render(country: "USA")
    assert_selector "*"
  end

  test "renders 'city, state' for US and UK locations" do
    render(city: "Suffern", state: "New York", code: "US")
    assert_text "Suffern, New York"

    render(city: "Edinburgh", state: "Scotland", code: "GB")
    assert_text "Edinburgh, Scotland"
  end

  test "renders 'city, country' otherwise" do
    render(city: "Paris", state: "Ile-de-France", country: "France")
    assert_text "Paris, France"

    render(city: "Berlin", state: "Berlin", country: "Germany", code: "DE")
    assert_text "Berlin, Germany"
  end

  def render(city: nil, state: nil, country: nil, code: nil)
    location = Location.new(city:, state:, country:, country_code: code)
    render_inline LocationComponent.new(location)
  end
end
