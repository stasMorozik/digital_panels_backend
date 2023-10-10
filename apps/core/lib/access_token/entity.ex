defmodule Core.AccessToken.Entity do
  use Joken.Config

  def token_config, do: default_claims(default_exp: 90 * 10)
end
