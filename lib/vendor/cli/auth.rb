module Vendor

  module CLI

    module Auth

      require 'highline/import'

      extend self

      def api_key
        Vendor::Config.get(:"credentials.vendorforge_api_key")
      end

      def api_key=(value)
        Vendor::Config.set(:"credentials.vendorforge_api_key", value)
      end

      def fetch_api_key
        Vendor.ui.warn "Please enter your vendorforge.org login and password"

        username = ask("Login: ")
        password = ask("Password: ") { |q| q.echo = false }

        Vendor::Config.set(:"credentials.vendorforge_api_key", Vendor::API.api_key(username, password))
      end

      def with_api_key(&block)
        fetch_api_key unless is_authenticated?
        yield api_key if api_key
      end

      def is_authenticated?
        !api_key.nil?
      end

    end

  end

end
