require "spec"
require "../src/simple_oauth"

module FixturesModule
  # request fixtures
  getter whitelisted_callback_url = "localhost:3000",
    oauth_verifier = "oauth:v3rifier"
  # response fixtures
  getter oauth_token = "oauth:tok3n",
    oauth_token_secret = "oauth:token:s3cret",
    oauth_token_access = "acc3ss:token",
    oauth_token_secret_access = "acc3ss:secret",
    user_id = "38895958",
    token_pair = SimpleOAuth::Consumer::TokenPair.new("oauth:tok3n", "acc3ss:secret")
end
  
class Fixtures
  include FixturesModule
end

# Consumer with stubbed HTTP responses
class TestConsumer < SimpleOAuth::Consumer
  include FixturesModule
  @@host = "https://api.twitter.com/"
  @@request_token_url = "#{@@host}oauth/request_token"
  @@access_token_url = "#{@@host}oauth/access_token"
  @@authenticate_url = "#{@@host}oauth/authenticate"

  def exec(method : Symbol, url : String, headers : Hash(String, String), params : Hash(String, String))
    auth_header = headers["Authorization"]
    auth_header.should match(/^OAuth /)
    case url
    when "#{@@host}oauth/request_token"
      # Step 1 of https://developer.twitter.com/en/docs/basics/authentication/overview/3-legged-oauth.html
      auth_header.should contain(
        "oauth_callback=\"#{Signature.escape(@callback_url)}\"")
      auth_header.should contain(
        "oauth_consumer_key=\"#{Signature.escape(@consumer_key)}\"")

      "oauth_token=#{oauth_token}&" \
      "oauth_token_secret=#{oauth_token_secret}&" \
      "oauth_callback_confirmed=#{@callback_url==whitelisted_callback_url}"
    when "#{@@host}oauth/access_token"
      # Step 3 of https://developer.twitter.com/en/docs/basics/authentication/overview/3-legged-oauth.html
      auth_header.should contain(
        "oauth_token=\"#{Signature.escape(oauth_token)}\"")
      auth_header.should contain(
        "oauth_verifier=\"#{Signature.escape(oauth_verifier)}\"")
      auth_header.should contain(
        "oauth_consumer_key=\"#{Signature.escape(@consumer_key)}\"")
      params["oauth_verifier"].should eq oauth_verifier

      "oauth_token=#{oauth_token_access}&" \
      "oauth_token_secret=#{oauth_token_secret_access}"
    when "#{@@host}1.1/account/verify_credentials.json"
      # See https://developer.twitter.com/en/docs/accounts-and-users/manage-account-settings/api-reference/get-account-verify_credentials
      auth_header.should contain(
        "oauth_token=\"#{Signature.escape(oauth_token_access)}\"")
      "{\"id\": #{user_id},\"id_str\": \"#{user_id}\"}"
    when "#{@@host}1.1/oauth/invalidate_token"
      # See https://developer.twitter.com/en/docs/basics/authentication/api-reference/invalidate_access_token
      auth_header.should contain(
        "oauth_token=\"#{Signature.escape(oauth_token_access)}\"")
      "{\"access_token\":\"#{oauth_token_access}\"}"
    else
      raise Exception.new("Unexpected Twitter URL")
    end
  end
end