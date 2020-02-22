require "./spec_helper"

include SimpleOAuth

F = Fixtures.new

describe Consumer do
  consumer_key = "consumer:k3y"
  consumer_secret = "consumer:s3cret"
  access_token = Consumer::TokenPair.new(F.oauth_token_access, F.oauth_token_secret_access)

  api = TestConsumer.new(consumer_key, consumer_secret, F.whitelisted_callback_url)
  api_unverified_callback_url = TestConsumer.new(consumer_key, consumer_secret, "https://other.url")

  describe "#get_token" do
    it "generates a request token + secret" do
      api.get_token.should eq(
        Consumer::TokenPair.new(F.oauth_token, F.oauth_token_secret))
    end
    it "throws an error if the callback is not verified" do
      expect_raises(Consumer::CallbackNotConfirmed) do
        api_unverified_callback_url.get_token
      end
    end
  end
  describe "#upgrade_token" do
    it "converts a request token pair into an access one" do
      api.upgrade_token(F.token_pair, F.oauth_verifier).should eq(access_token)
    end
  end
  describe "Consumer.authenticate_url" do
    it "returns the /authenticate URL with the given token as query string parameter" do
      url = TestConsumer.authenticate_url("my-token")
      url.should eq "https://api.twitter.com/oauth/authenticate?oauth_token=my-token"
    end
  end
end
