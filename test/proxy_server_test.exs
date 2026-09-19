defmodule ProxyServerTest do
  use ExUnit.Case
  @address "7YWHMfk9JZe0LM0g1ZauHuiSxhI"

  test "is Boguscoin address" do
    # 🛑 陷阱 4：太短了（25个字符，加上7只有26，符合！如果少于26就不会替换）
    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "7123456789012345678901234\n",
             @address
           ) ==
             "7123456789012345678901234\n"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "pay me at 7F1234567890123456789012345678\n",
             @address
           ) ==
             "pay me at 7YWHMfk9JZe0LM0g1ZauHuiSxhI\n"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "7F1234567890123456789012345678 is my address\n",
             @address
           ) ==
             "7YWHMfk9JZe0LM0g1ZauHuiSxhI is my address\n"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "send to 7F1234567890123456789012345678 please\n",
             @address
           ) ==
             "send to 7YWHMfk9JZe0LM0g1ZauHuiSxhI please\n"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "send to 7F1234567890123456789012345678 please\n",
             @address
           ) ==
             "send to 7YWHMfk9JZe0LM0g1ZauHuiSxhI please\n"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "[ProtoHunter845] Please pay the ticket price of 15 Boguscoins to one of these addresses: 7097bT12yuj8y389Y4DvwP4CUS 7YWHMfk9JZe0LM0g1ZauHuiSxhI 7YWHMfk9JZe0LM0g1ZauHuiSxhI",
             @address
           ) ==
             "[ProtoHunter845] Please pay the ticket price of 15 Boguscoins to one of these addresses: 7YWHMfk9JZe0LM0g1ZauHuiSxhI 7YWHMfk9JZe0LM0g1ZauHuiSxhI 7YWHMfk9JZe0LM0g1ZauHuiSxhI"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "Send refunds to 7rTUgGXuOu9wrmIGwt49GjKmc0JtyjPRMj",
             @address
           ) ==
             "Send refunds to 7YWHMfk9JZe0LM0g1ZauHuiSxhI"

    assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
             "Send refunds to 7Pq59VXUo5n0n4cw1ODsI3Ggpnb4VM1 please.",
             @address
           ) ==
             "Send refunds to 7YWHMfk9JZe0LM0g1ZauHuiSxhI please."
  end

  # Spec (https://protohackers.com/problem/5): a substring is a Boguscoin address if:
  #   - it starts with a "7"
  #   - it consists of at least 26, and at most 35, alphanumeric characters
  #   - it starts at the start of a chat message, or is preceded by a space
  #   - it ends at the end of a chat message, or is followed by a space
  describe "address boundary rules" do
    test "exactly 26 alphanumeric characters is replaced" do
      addr26 = "7" <> String.duplicate("a", 25)
      assert String.length(addr26) == 26

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr26} now\n",
               @address
             ) == "pay #{@address} now\n"
    end

    test "exactly 35 alphanumeric characters is replaced" do
      addr35 = "7" <> String.duplicate("a", 34)
      assert String.length(addr35) == 35

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr35} now\n",
               @address
             ) == "pay #{@address} now\n"
    end

    test "25 characters (one below the minimum) is not replaced" do
      addr25 = "7" <> String.duplicate("a", 24)
      assert String.length(addr25) == 25

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr25} now\n",
               @address
             ) == "pay #{addr25} now\n"
    end

    test "36 characters (one above the maximum) is not replaced" do
      addr36 = "7" <> String.duplicate("a", 35)
      assert String.length(addr36) == 36

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr36} now\n",
               @address
             ) == "pay #{addr36} now\n"
    end

    test "must start with 7" do
      not_seven = "8" <> String.duplicate("a", 29)

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{not_seven} now\n",
               @address
             ) == "pay #{not_seven} now\n"
    end

    test "must be preceded by start-of-message or a space" do
      addr = "7" <> String.duplicate("a", 29)

      # preceded by a letter -> not an address
      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "x#{addr} tail\n",
               @address
             ) == "x#{addr} tail\n"

      # at the very start of the message -> an address
      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "#{addr} tail\n",
               @address
             ) == "#{@address} tail\n"
    end

    test "must be followed by end-of-message, newline or a space" do
      addr = "7" <> String.duplicate("a", 29)

      # followed by punctuation -> not an address
      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr}.\n",
               @address
             ) == "pay #{addr}.\n"

      # at the very end of the message (no newline) -> an address
      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr}",
               @address
             ) == "pay #{@address}"

      # followed by newline -> an address
      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "pay #{addr}\n",
               @address
             ) == "pay #{@address}\n"
    end

    test "multiple addresses in a single message are all replaced" do
      addr1 = "7" <> String.duplicate("b", 30)
      addr2 = "7" <> String.duplicate("c", 30)

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "#{addr1} and #{addr2}\n",
               @address
             ) == "#{@address} and #{@address}\n"
    end

    test "mixed-case alphanumeric addresses are replaced" do
      addr = "7aZ9xQ2mLpR7tY4vB6nC1eH8uJ3k"

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(
               "send #{addr} money\n",
               @address
             ) == "send #{@address} money\n"
    end

    test "messages without addresses are untouched" do
      msg = "hello world, no addresses here\n"

      assert ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(msg, @address) == msg
    end
  end
end
