require 'rest_client'

module VendorKit
  module API

    extend self

    class Error < StandardError; end


    def api_key(username, password)
      begin
        response = resource(username, password)["users/#{username}/api_key.json"].get
        JSON.parse(response.body)["api_key"]
      rescue RestClient::Exception => e
        if e.http_code == 401
          raise Error.new("Login or password is incorrect")
        else
          raise Error.new("Could not download API key from server. Server returned a staus code of #{e.http_code}")
        end
      end
    end

    private

      def self.resource(user, pass)
        RestClient::Resource.new(ENV["API_URI"] || 'http://vendorage.com', :user => user, :password => pass)
      end

  end
end
