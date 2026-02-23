defmodule ProtohackerElixir.Budget.Message do
  @moduledoc false
  alias ProtohackerElixir.Budget.User

  defmodule PresenceNotification do
    @moduledoc false
    @spec new([User.t()]) :: String.t()
    def new(users) do
      "* The room contains: #{users |> Enum.map_join(",", fn u -> u.name end)}\n"
    end
  end
end
