module Vendor
  module Config

    require 'fileutils'
    require 'yaml'

    extend self

    def directory
      @directory ||= File.expand_path("~/.vendor")
    end

    def directory=(dir)
      @directory = dir
    end

    def set(key, value)
      hash[key.to_sym] = value
      save
      value
    end

    def get(key)
      hash[key.to_sym]
    end

    def hash
      @hash ||= load_or_create
    end

    private

      def config_file
        File.join(directory, "config")
      end

      def load_or_create
        if File.exist?(config_file)
          YAML.load_file(config_file) || {}
        else
          {}
        end
      end

      def save
        FileUtils.mkdir_p(directory)
        File.open(config_file, "w+") { |f| YAML.dump(hash, f) }
      end

  end
end
