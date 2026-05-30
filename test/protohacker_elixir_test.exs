defmodule ProtohackerElixirTest do
  use ExUnit.Case
  @address "7YWHMfk9JZe0LM0g1ZauHuiSxhI"
  doctest ProtohackerElixir

  test "is prime" do
    assert ProtohackerElixir.Prime.Helper.prime?(3) == true
    assert ProtohackerElixir.Prime.Helper.prime?(4) == false
  end

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
end
