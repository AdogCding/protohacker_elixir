defmodule BudgetUnitTest do
  @moduledoc """
  Unit tests for Budget Chat building blocks (Problem 3:
  https://protohackers.com/problem/3): message formatting and name validation.
  """
  use ExUnit.Case, async: true

  alias ProtohackerElixir.Budget.Message
  alias ProtohackerElixir.Budget.User

  defp user(name), do: %User{name: name, id: "id-#{name}", pid: self()}

  describe "User.valid_name?/1" do
    test "accepts alphanumeric names" do
      assert User.valid_name?("a")
      assert User.valid_name?("alice")
      assert User.valid_name?("Bob42")
      assert User.valid_name?("0")
      # must allow at least 16 characters
      assert User.valid_name?(String.duplicate("x", 16))
      assert User.valid_name?(String.duplicate("x", 64))
    end

    test "rejects empty names" do
      refute User.valid_name?("")
    end

    test "rejects names with non-alphanumeric characters" do
      refute User.valid_name?("bad name")
      refute User.valid_name?("bad!name")
      refute User.valid_name?("bad-name")
      refute User.valid_name?("bad_name")
      refute User.valid_name?("名字")
      refute User.valid_name?("\n")
      refute User.valid_name?(" ")
    end
  end

  describe "Message.Welcome" do
    test "starts with '*' and contains the user's name" do
      msg = Message.Welcome.new(user("bob"))
      assert msg == "* bob has entered the room\n"
      assert String.starts_with?(msg, "*")
      assert String.contains?(msg, "bob")
    end
  end

  describe "Message.GoodBye" do
    test "starts with '*' and contains the user's name" do
      msg = Message.GoodBye.new(user("bob"))
      assert msg == "* bob has left the room\n"
      assert String.starts_with?(msg, "*")
      assert String.contains?(msg, "bob")
    end
  end

  describe "Message.ChatMessage" do
    test "formats as [name] message with a trailing newline" do
      assert Message.ChatMessage.new(user("alice"), "Hello, world!") ==
               "[alice] Hello, world!\n"
    end

    test "supports long messages (at least 1000 characters)" do
      long = String.duplicate("x", 1000)
      msg = Message.ChatMessage.new(user("alice"), long)
      assert msg == "[alice] #{long}\n"
    end
  end

  describe "Message.PresenceNotification" do
    test "starts with '*' and lists all names" do
      msg = Message.PresenceNotification.new([user("bob"), user("charlie"), user("dave")])
      assert String.starts_with?(msg, "*")
      assert String.contains?(msg, "bob")
      assert String.contains?(msg, "charlie")
      assert String.contains?(msg, "dave")
    end

    test "an empty room still yields a notification line" do
      msg = Message.PresenceNotification.new([])
      assert String.starts_with?(msg, "*")
      assert String.ends_with?(msg, "\n")
    end
  end
end
