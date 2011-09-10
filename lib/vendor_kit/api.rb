require 'httparty'

module VendorKit
  module API

    class Error < StandardError; end

    include HTTParty

    base_uri VendorKit::Config.get(:"development.api_uri") || 'http://vendorage.com'

    def self.api_key(username, password)
      options = { :basic_auth => { :username => username, :password => password } }
      response = get("/users/#{username}/api_key.json", options)

      if response.code == 200
        JSON.parse(response.body)["api_key"]
      elsif response.code == 401
        raise Error.new("Login or password is incorrect")
      else
        raise Error.new("Could not download API key from server. Server returned a staus code of #{response.code}")
      end
    end

  end
end
