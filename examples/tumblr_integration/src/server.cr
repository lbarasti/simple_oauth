require "kemal"
require "uuid"
require "./tumblr_api"

consumer_key = ENV["TUMBLR_CONSUMER_KEY"]
consumer_secret = ENV["TUMBLR_CONSUMER_SECRET"]
callback_url = ENV["TUMBLR_CALLBACK_URL"]
callback_path = URI.parse(callback_url).path

consumer = TumblrAPI.new(consumer_key, consumer_secret, callback_url)

Users = Hash(String, TumblrAPI::TokenPair).new
Tokens = Hash(String, TumblrAPI::TokenPair).new

def credentials(ctx) : {String?, TumblrAPI::TokenPair?}
  app_token = ctx.request.headers["token"]?
  twitter_token = app_token.try{ Users[app_token]? }
  {app_token, twitter_token}
end

get "/" do |ctx|
  send_file ctx, "public/index.html"
end

get "/authenticate" do |ctx|
  request_token = consumer.get_token
  # store the request token for later verification in the /callback-url step
  Tokens[request_token.oauth_token] = request_token
  ctx.redirect TumblrAPI.authenticate_url(request_token.oauth_token)
end

get callback_path do |ctx|
  token = ctx.params.query["oauth_token"]
  # verify that the token matches the request token stored in the step above
  halt(ctx, status_code: 400) unless Tokens.has_key? token
  request_token = Tokens[token]
  Tokens.delete(token)

  verifier = ctx.params.query["oauth_verifier"]
  access_token = consumer.upgrade_token(request_token, verifier)
  
  app_token = UUID.random.to_s
  # store the access token and secret - to be used for future authenticated requests to the TumblrAPI
  Users[app_token] = access_token

  ctx.response.headers.add "Location", "/?token=#{app_token}"
  ctx.response.status_code = 302
end

get "/verify" do |ctx|
  _, twitter_token = credentials(ctx)
  halt(ctx, status_code: 401) if twitter_token.nil?

  ctx.response.content_type = "application/json"
  consumer.verify(twitter_token)
end

get "/logout" do |ctx|
  app_token, twitter_token = credentials(ctx)
  halt(ctx, status_code: 401) if twitter_token.nil?
  
  # consumer.invalidate_token(twitter_token) # Tumblr does not seem to support token invalidation
  Users.delete(app_token)
  
  ctx.redirect "/"
end

Kemal.run 8090