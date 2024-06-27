# config valid for current version and patch releases of Capistrano
lock "~> 3.18.1"

set :application, "portfolio"
set :repo_url, "git@github.com:jaggdl/portfolio.git"

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

# set :linked_dirs, %w[db/production.sqlite3]
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

# Optionally, you can symlink your database.yml and/or secrets.yml file from the shared directory during deploy
# This is useful if you don't want to use ENV variables
append :linked_files, 'config/database.yml', '.env.production'

namespace :deploy do
  desc 'Upload database.yml'
  task :upload_database_yml do
    on roles(:app) do
      unless test("[ -f #{shared_path}/config/database.yml ]")
        upload! 'config/database.yml', "#{shared_path}/config/database.yml"
      end
    end
  end

  before :starting, :upload_database_yml

  desc 'Upload .env.production'
  task :upload_env do
    on roles(:app) do
      upload! '.env.production', "#{shared_path}/.env.production"
    end
  end

  before :starting, :upload_env

  desc 'Persist current DB file'
  task :copy_sqlite do
    on roles(:all) do |_host|
      execute "cp #{current_path}/db/production.sqlite3 #{release_path}/db/"
    end
  end

  before 'deploy:migrate', 'deploy:copy_sqlite'
end

namespace :sitemap do
  desc 'Generate sitemap'
  task :generate do
    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :rake, 'sitemap:refresh'
        end
      end
    end
  end

  after 'deploy:published', 'sitemap:generate'
end

# Only keep the last 5 releases to save disk space
set :keep_releases, 5

# Default branch is :master
set :branch, 'main'

# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'


# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
