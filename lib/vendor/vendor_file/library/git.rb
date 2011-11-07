module Vendor
  module VendorFile
    module Library

      require 'digest/md5'

      class Git < Base

        class GitError < StandardError; end

        attr_accessor :uri
        attr_accessor :tag

        alias :branch= :tag=
        alias :ref= :tag=
        alias :git= :uri=

        def initialize(attributes = {})
          attributes[:tag] ||= attributes[:ref] || attributes[:branch] || "master"

          super(attributes)
        end

        def download
          if File.exist?(cache_path)
            Vendor.ui.info "Updating #{uri}"

            Dir.chdir(cache_path) do
              git %|fetch --force --quiet --tags #{uri_escaped}|
            end
          else
            Vendor.ui.info "Fetching #{uri}"

            FileUtils.mkdir_p(cache_path)
            git %|clone #{uri_escaped} "#{cache_path}"|
          end

          Dir.chdir(cache_path) do
            git "reset --hard #{tag}"
          end
        end

        # If you change the git path, and not the lib name, we want to update
        # the sources correctly. So instead of using the name, use a hash of
        # the URI
        def cache_path
          File.join(Vendor.library_path, "git", Digest::MD5.hexdigest(uri)) if uri
        end

        private

          def git(command)
            out = %x{git #{command}}

            if $?.exitstatus != 0
              raise GitError, "Git error: command `git #{command}` in directory #{Dir.pwd} has failed."
            end
            out
          end

          def uri_escaped
            # Bash requires single quoted strings, with the single quotes escaped
            # by ending the string, escaping the quote, and restarting the string.
            "'" + uri.gsub("'") {|s| "'\\''"} + "'"
          end

      end

    end
  end
end
