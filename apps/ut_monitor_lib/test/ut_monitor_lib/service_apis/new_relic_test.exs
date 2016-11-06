defmodule UtMonitorLib.ServiceApis.NewRelicTest do
  use ExUnit.Case
  alias UtMonitorLib.ServiceApis.NewRelic
  
  defmodule GoodTeslaClient do
    def get_apdex_data do
      %Tesla.Env{status: 200, body: %{
        "metric_data" => %{
          "metrics" => [
            %{
              "name" => "Apdex",
              "timeslices" => [%{
                "from" => "2016-11-01T10:41:00+00:00",
                "to" => "2016-11-01T10:46:00+00:00",
                "values" => %{
                  "count" => 2112, "f" => 11, "s" => 2050,
                  "score" => 0.98, "t" => 47, "threshold" => 0.5,
                  "threshold_min" => 0.42, "value" => 0.98
                }
              }]
            }
          ]
        }
      }}
    end
  end
  
  test "properly calculates the apdex on a 200 response" do
    assert NewRelic.get_apdex_values(GoodTeslaClient) == {:ok, [(2050 + 47/2)/(2050 + 47 + 11)]}
  end
  
  defmodule Tesla404Client do
    def get_apdex_data do
      %Tesla.Env{status: 404, body: "Not Found"}
    end
  end
  
  test "returns the error from the body on a non-200 request" do
    assert NewRelic.get_apdex_values(Tesla404Client) == {:error, "Not Found"}
  end
  
  defmodule NonTeslaEnvClient do
    def get_apdex_data do
      %{}
    end
  end
  
  test "returns a generic error when a non-Tesla.Env comes back" do
    assert NewRelic.get_apdex_values(NonTeslaEnvClient) == {:error, "Unknown Error"}
  end
  
end
