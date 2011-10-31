module Vendor
  module VendorFile
    module Library

      class Git < Base

        class GitError < StandardError; end

        attr_accessor :uri
        attr_accessor :tag

        alias :branch= :tag=
        alias :ref= :tag=
        alias :git= :uri=

        def initialize(attributes = {})
          super({ :tag => "master" }.merge(attributes))
        end

        def download(path)
          cache_path = File.join(path, "git", name)

          if File.exist?(cache_path)
            Vendor.ui.info "Updating #{uri}"

            Dir.chdir(cache_path) do
              git %|fetch --force --quiet --tags #{uri_escaped} "refs/heads/*:refs/heads/*"|
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

        private

          def git(command)
            out = %x{git #{command}}

            if $?.exitstatus != 0
              msg = "Git error: command `git #{command}` in directory #{Dir.pwd} has failed.".red
              raise GitError, msg
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
