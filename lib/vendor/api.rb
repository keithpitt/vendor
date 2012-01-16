require 'rest_client'

module Vendor
  module API

    require 'json'
    require 'tmpdir'

    extend self

    class Error < StandardError; end

    def api_uri
      ENV["API_URI"] || 'http://vendorkit.com'
    end

    def api_key(username, password)
      perform do
        url = resource(username, password)["users/#{username}/api_key.json"]
        Vendor.ui.debug "GET #{url}"

        response = url.get
        JSON.parse(response.body)["api_key"]
      end
    end

    def meta(name)
      @meta ||= {}

      perform :on_404 => "Could not find a valid vendor '#{name}'" do
        unless @meta[name]
          url = resource["vendors/#{slugerize(name)}.json"]
          Vendor.ui.debug "GET #{url}"

          @meta[name] = JSON.parse(url.get.body)
        end

        @meta[name]
      end
    end

    def download(name, version)
      perform do
        info = meta(name)

        # Does the version exist?
        unless info['versions'].find { |v| Vendor::Version.create(v[0]) == Vendor::Version.create(version) }
          raise Error.new("Could not find a valid version for '#{name}' that matches '#{version}'")
        end

        url = resource["vendors/#{slugerize(name)}/versions/#{version}/download"]
        Vendor.ui.debug "GET #{url}"
        Vendor.ui.info "Downloading #{name} #{version}"

        binary = url.get

        filename = "#{name}-#{version}.vendor"
        tmpfile = File.join(Dir.mktmpdir(filename), filename)

        file = File.new(tmpfile, 'w')
        file.write binary
        file.close

        file
      end
    end

    def push(options)
      perform do
        url = resource["vendors.json"]
        Vendor.ui.debug "POST #{url}"

        response = url.post :version => { :package => File.new(options[:file]) }, :api_key => options[:api_key]
        json = JSON.parse(response.body)

        if json["status"] == "ok"
          json["url"]
        else
          raise Error.new(json["message"])
        end
      end
    end

    private

      def slugerize(string)
        string.gsub(/[^a-zA-Z0-9\-\_\s]/, ' ').gsub(/\s+/, '-')
      end

      def perform(options = {}, &block)
        begin
          yield
        rescue RestClient::Exception => e
          if e.http_code == 401
            raise Error.new("Login or password is incorrect")
          elsif e.http_code == 404
            raise Error.new(options[:on_404] || "Resource could not be found")
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
