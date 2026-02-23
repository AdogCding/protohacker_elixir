defmodule ProtohackerElixir.Budget.Message do
  @moduledoc false
  alias ProtohackerElixir.Budget.User

  defmodule Welcome do
    @moduledoc false
    @spec new(User.t()) :: String.t()
    def new(user) do
      "* #{user.name} has entered the room\n"
    end
  end

  defmodule GoodBye do
    @moduledoc false
    @spec new(User.t()) :: String.t()
    def new(user) do
      "* #{user.name} has left the room\n"
    end
  end

  defmodule ChatMessage do
    @moduledoc false
    @spec new(User.t(), String.t()) :: String.t()
    def new(user, message) do
      "[#{user.name}] #{message}\n"
    end
  end

  defmodule PresenceNotification do
    @moduledoc false
    @spec new([User.t()]) :: String.t()
    def new(users) do
      "* The room contains: #{users |> Enum.map_join(",", fn u -> u.name end)}\n"
    end
  end
end
