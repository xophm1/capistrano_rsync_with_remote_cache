require 'capistrano/recipes/deploy/strategy/remote'
require 'fileutils'

module Capistrano
  module Deploy
    module Strategy
      class RsyncWithRemoteCache < Remote

        def deploy!
          update_remote_cache
          copy_remote_cache
        end

        def update_remote_cache
          target_hostname = roles[:app].servers[0].host
          cmd = "rsync -rlogvz --delete --delete-excluded --perms --chmod=g+w #{Dir.pwd}/ #{user}@#{target_hostname}:#{configuration[:remote_cache]}"
          rsync_exclude.each { |pattern|
              cmd = cmd + " --exclude=#{pattern}"
          }
          run_locally_live cmd
        end

        def copy_remote_cache
          # Use rsync for copy because: cp -p fails with error "operation not supported" on our ovh server
          cmd = "rsync -rlog --perms #{configuration[:remote_cache]}/ #{configuration[:release_path]}"
          run cmd
        end

      end
    end
  end
end
