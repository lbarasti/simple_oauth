require "simple_oauth"

class TumblrAPI < SimpleOAuth::Consumer
  @@request_token_url = "https://www.tumblr.com/oauth/request_token"
  @@authenticate_url = "https://www.tumblr.com/oauth/authorize"
  @@access_token_url = "https://www.tumblr.com/oauth/access_token"

  @@verify_credentials_url = "https://api.tumblr.com/v2/user/info"

  # Returns a representation of the requesting user if authentication was successful;
  # raises an exception if not. Use this method to test if supplied user credentials are valid.
  #
  # See the [Tumblr documentation](https://www.tumblr.com/docs/en/api/v2#userinfo--get-a-users-information)
  def verify(token : TokenPair)
    user_auth = SimpleOAuth::Signature.new(@consumer_secret, token.oauth_token_secret)

    auth_params = {
      "oauth_token" => token.oauth_token
    }

    exec_signed(:get, @@verify_credentials_url, auth_params, @@empty_params, auth = user_auth)
  end
end