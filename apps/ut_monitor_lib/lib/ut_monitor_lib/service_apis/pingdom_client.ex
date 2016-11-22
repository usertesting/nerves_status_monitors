defmodule UtMonitorLib.ServiceApis.PingdomClient do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://api.pingdom.com/api/2.0"
  plug Tesla.Middleware.Headers, %{"Authorization" =>  "Basic " <> Base.encode64(Application.get_env(:ut_monitor_lib, :pingdom).user_name <> ":" <> Application.get_env(:ut_monitor_lib, :pingdom).password) }
  plug Tesla.Middleware.Headers, %{"App-Key" => Application.get_env(:ut_monitor_lib, :pingdom).application_id}
  plug Tesla.Middleware.JSON

  def get_check_list do
    get("checks")
  end

  def get_check_details(check_id) when is_binary(check_id) do
    get("checks/" <> check_id)
  end

  def get_check_details(check_id) when is_integer(check_id) do
    get("checks/" <> Integer.to_string(check_id))
  end
end
