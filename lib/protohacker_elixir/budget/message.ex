defmodule ProtohackerElixir.Budget.Message do
  alias ProtohackerElixir.Budget.User
  @spec createPresenceNotification([User.t()]) :: String.t()
  def createPresenceNotification(users) do
    "* The room contains: #{users |> Enum.map(& &1.name) |> Enum.join(", ")}\n"
  end
end
