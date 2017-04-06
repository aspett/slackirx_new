defmodule Relay.Repo do
  alias Relay.Location.{Slack,Irc,Pipeline}

  def all(Pipeline) do
    [
      %Pipeline{
        pipe_id: 1,
        type: :dual,
        source: %Slack{
          id: 1,
          token: Application.get_env(:relay, :slack_token),
          channel: "***REMOVED***"
        },
        destination: %Irc{
          id: 1,
          bot_name: "andrewbot",
          server: "***REMOVED***",
          port: 6667,
          channel: "***REMOVED***x"
        }
      }
    ]
  end
end