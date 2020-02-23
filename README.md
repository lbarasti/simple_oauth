[![GitHub release](https://img.shields.io/github/release/lbarasti/simple_oauth.svg)](https://github.com/lbarasti/simple_oauth/releases)
![Build Status](https://github.com/lbarasti/simple_oauth/workflows/build/badge.svg)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

# simple_oauth

A minimal implementation of OAuth Consumer, to be relied upon when implementing OAuth1.0 flows.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     simple_oauth:
       github: lbarasti/simple_oauth
   ```

2. Run `shards install`

## Usage

Just extend SimpleOAuth::Consumer and define the request, authenticate and access token URLs as class variables.
```crystal
require "simple_oauth"

class TumblrAPI < SimpleOAuth::Consumer
  @@request_token_url = "https://www.tumblr.com/oauth/request_token"
  @@authenticate_url = "https://www.tumblr.com/oauth/authorize"
  @@access_token_url = "https://www.tumblr.com/oauth/access_token"
end

consumer_key = ENV["TUMBLR_CONSUMER_KEY"]
consumer_secret = ENV["TUMBLR_CONSUMER_SECRET"]
callback_url = ENV["TUMBLR_CALLBACK_URL"]

consumer = TumblrAPI.new(consumer_key, consumer_secret, callback_url)
```

## Contributing

1. Fork it (<https://github.com/lbarasti/simple_oauth/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [lbarasti](https://github.com/lbarasti) - creator and maintainer
