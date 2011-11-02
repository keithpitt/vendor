require 'rest_client'

module Vendor
  module API

    require 'json'

    extend self

    class Error < StandardError; end

    def api_uri
      ENV["API_URI"] || 'http://vendorforge.org'
    end

    def api_key(username, password)
      perform do
        response = resource(username, password)["users/#{username}/api_key.json"].get
        JSON.parse(response.body)["api_key"]
      end
    end

    def push(options)
      perform do
        response = resource["vendors.json"].post :version => { :package => File.new(options[:file]) }, :api_key => options[:api_key]
        body = JSON.parse(response.body)

        if body["status"] == "ok"
          body["url"]
        else
          raise Error.new(body["message"])
        end
      end
    end

    private

      def perform(&block)
        begin
          yield
        rescue RestClient::Exception => e
          if e.http_code == 401
            raise Error.new("Login or password is incorrect")
          else
            raise Error.new("Could not complete request. Server returned a status code of #{e.http_code}")
          end
        end
      end

      def resource(user = nil, pass = nil)
        RestClient::Resource.new(api_uri, :user => user, :password => pass)
      end

  end
end
