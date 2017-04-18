defmodule Relay.Repo do
  alias Relay.Location.{Slack,Irc,Pipeline}

  @moduledoc false

  @doc false
  def all(Pipeline) do
    [
      %Pipeline{
        pipe_id: 1,
        type: :dual,
        source: %Slack{
          id: 1,
          token: Application.get_env(:relay, :slack_token),
          channel: "***REMOVED***",
          pipeline_id: 1
        },
        destination: %Irc{
          id: 1,
          bot_name: "andrewbot",
          server: "***REMOVED***",
          port: 6667,
          channel: "***REMOVED***x",
          pipeline_id: 1
        }
      },
      %Pipeline{
        pipe_id: 2,
        type: :dual,
        source: %Slack{
          id: 2,
          token: Application.get_env(:relay, :slack_token),
          channel: "***REMOVED***",
          pipeline_id: 2
        },
        destination: %Irc{
          id: 2,
          bot_name: "andrewbot2",
          server: "***REMOVED***",
          port: 6667,
          channel: "***REMOVED***",
          pipeline_id: 2
        }
      }
    ]
  end

  @doc false
  def get!(Pipeline, pipe_id) do
    Enum.find(all(Pipeline), fn pipeline -> pipeline.pipe_id == pipe_id end)
  end
end