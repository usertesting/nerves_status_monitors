# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :logger,
  level: :info

config :ut_monitor_fw, :hardware_spec,
  [
    %{name: :apdex_leds, buffer: 0, type: :led},
    %{name: :hb_leds, buffer: 1, type: :led},
    %{name: :pingdom_relay, pin: 4, type: :relay}
  ]
# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.Project.config[:target]}.exs"
import_config "secret.exs"
