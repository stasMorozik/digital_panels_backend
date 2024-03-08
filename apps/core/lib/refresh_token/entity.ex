defmodule Core.RefreshToken.Entity do
  use Joken.Config

  def token_config, do: default_claims(default_exp: 90 * 90)
end
