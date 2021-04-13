require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'
require 'mina/systemd/puma'
require 'fileutils'

FileUtils.mkdir_p "#{Dir.pwd}/deploy"

set :ssh_options, '-o StrictHostKeyChecking=no'

set :domain, '127.0.0.1'
set :deploy_to, "#{Dir.pwd}/deploy"
set :repository, 'https://github.com/chagel/rails-template.git'

set :user, -> { command %(whoami) }


task :remote_environment do
  invoke :'rbenv:load'
end

task setup: :remote_environment do
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/pids/")
  command %(mkdir -p "#{fetch(:deploy_to)}/shared/log/")
end

task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    on :launch do
      #invoke :'puma:install'
    end
  end
end
