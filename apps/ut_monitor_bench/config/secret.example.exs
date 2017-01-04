use Mix.Config

config :ut_monitor_lib, :new_relic, %{
    api_key: "your_new_relic_api_key",
    app_id: "your_new_relic_app_id"
}

config :ut_monitor_lib, :honeybadger, %{
    api_key: "your_honeybadger_api_key",
    project_id: "your_honeybadger_project_id"
}

config :ut_monitor_lib, :pingdom, %{
  user_name: "your_pingdom_username",
  password: "your_pingdom_password",
  application_id: "your_pingdom_app_id"
}

