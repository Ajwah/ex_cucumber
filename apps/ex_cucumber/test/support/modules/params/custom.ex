defmodule Support.Params.Custom do
  use ExCucumber
  @feature "custom_params.feature"

  alias Support.ParameterTypes.{
    City,
    Date,
    Duration,
    Flight,
    Price,
    Time
  }

  @custom_param_types [
    origin: City,
    destination: City,
    latest_arrival_time: Date,
    departure_date: Date,
    departure_time: Time,
    arrival_date: Date,
    arrival_time: Time,
    total_flight_time: Duration,
    price: Price,
    flight: Flight
  ]

  Given._ "I live in {origin} and need to travel to {destination} arriving before {latest_arrival_time}",
          arg do
    assert arg.params == [
             origin: %Support.ParameterTypes.City.Transformer{
               raw: "New York",
               value: "New York"
             },
             destination: %Support.ParameterTypes.City.Transformer{
               raw: "Istanbul",
               value: "Istanbul"
             },
             latest_arrival_time: %Support.ParameterTypes.Date{
               day: 21,
               day_name: "Friday",
               month: "July",
               raw: "Friday, 21 July 2017",
               value: "Friday, 21 July 2017",
               year: 2017
             }
           ]

    1
  end

  When._("I input all these details into the UI", do: 2)

  Then._ "I will see: Take {flight} from {origin} to {destination} on {departure_date} at {departure_time} to arrive by {arrival_date} at {arrival_time} for a total flight time of {total_flight_time} at a discounted price of {price} in total",
         arg do
    assert arg.params == [
             flight: "LHRL-OSL",
             origin: %Support.ParameterTypes.City.Transformer{
               raw: "New York",
               value: "New York"
             },
             destination: %Support.ParameterTypes.City.Transformer{
               raw: "Istanbul",
               value: "Istanbul"
             },
             departure_date: %Support.ParameterTypes.Date{
               day: 19,
               day_name: "Wednesday",
               month: "July",
               raw: "Wednesday, 19 July 2017",
               value: "Wednesday, 19 July 2017",
               year: 2017
             },
             departure_time: %Support.ParameterTypes.Time{
               hour: 13,
               minutes: 40,
               raw: "13:40",
               value: "13:40"
             },
             arrival_date: %Support.ParameterTypes.Date{
               day: 20,
               day_name: "Thursday",
               month: "July",
               raw: "Thursday, 20 July 2017",
               value: "Thursday, 20 July 2017",
               year: 2017
             },
             arrival_time: %Support.ParameterTypes.Time{
               hour: 9,
               minutes: 0,
               raw: "09:00",
               value: "09:00"
             },
             total_flight_time: %Support.ParameterTypes.Duration{
               hours: 17,
               raw: "17 hours",
               value: "17 hours"
             },
             price: %Support.ParameterTypes.Price{
               amount: 2500,
               raw: "2500 USD",
               unit: :usd,
               value: "2500 USD"
             }
           ]

    3
  end
end
