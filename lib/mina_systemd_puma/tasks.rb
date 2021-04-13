set :puma_status, -> { "#{fetch(:bundle_bin)} exec puma-status" }
set :puma_state,  -> { "#{fetch(:current_path)}/tmp/sockets/puma.state" }
set :puma_config, -> { "#{fetch(:deploy_to)}/shared/config/puma.rb" }
set :puma_sock,   -> { "#{fetch(:deploy_to)}/shared/tmp/sockets/puma.sock" }

set :sysctl_cmd,        'sudo systemctl'
set :service_unit_name, 'puma.service'
set :socket_unit_name,  'puma.socket'
set :systemd_unit_path, '/etc/systemd/system'
set :system_bundler,    -> { "/home/#{fetch(:user)}/.rbenv/bin/rbenv exec bundle" }

namespace :puma do
  desc "Init systemd units"
  task :install do
    template_service = %{
[Unit]
Description=Puma HTTP Server
After=network.target
Requires=#{ fetch(:socket_unit_name) }

[Service]
Type=simple
User=ubuntu
WorkingDirectory=#{ fetch(:current_path) }
ExecStart=#{fetch(:system_bundler)} exec puma -C #{fetch(:puma_config)}
Restart=always

[Install]
WantedBy=multi-user.target
}

    template_socket = %{
[Unit]
Description=Puma HTTP Server Accept Sockets

[Socket]
ListenStream=#{ fetch(:puma_sock) }

NoDelay=true
ReusePort=true
Backlog=1024

[Install]
WantedBy=sockets.target
}
    service_path = fetch(:systemd_unit_path) + "/" + fetch(:service_unit_name)
    comment %{Creating service unit file}
    command %{ sudo touch #{service_path} }
    command %{ echo "#{ template_service }" | sudo tee -a #{ service_path } }

    socket_path = fetch(:systemd_unit_path) + "/" + fetch(:socket_unit_name)
    comment %{Creating socket unit file}
    command %{ sudo touch #{socket_path} }
    command %{ echo "#{ template_socket }" | sudo tee -a #{ socket_path } }

    comment %{Reloading systemctl daemon}
    command %{ #{ fetch(:sysctl_cmd) } daemon-reload }

    comment %{Enabling services }
    command %{ #{ fetch(:sysctl_cmd) } enable #{ socket_path } }
    command %{ #{ fetch(:sysctl_cmd) } enable #{ service_path } }
  end

  desc "Remove units"
  task :uninstall do
    command %{ #{ fetch(:sysctl_cmd) } disable #{fetch(:service_unit_name)} }
    command %{ sudo rm #{File.join(fetch(:systemd_unit_path), fetch(:service_unit_name))}  }

    command %{ #{ fetch(:sysctl_cmd) } disable #{fetch(:socket_unit_name)} }
    command %{ sudo rm #{File.join(fetch(:systemd_unit_path), fetch(:socket_unit_name))}  }

    comment %{Reloading systemctl daemon}
    command %{ #{ fetch(:sysctl_cmd) } daemon-reload }

  end

  desc "Check puma state"
  task :state => :remote_environment do
    command %{cd #{fetch(:current_path)} && #{fetch(:puma_status)} #{fetch(:puma_state)} }
  end

  desc "Check puma.service status"
  task :status => :remote_environment do
    command %{ #{ fetch(:sysctl_cmd) } status #{fetch(:socket_unit_name)} #{fetch(:service_unit_name)} }
  end

  desc "Restart puma.service "
  task :restart => :remote_environment do
    command %{ #{ fetch(:sysctl_cmd) } restart #{fetch(:service_unit_name)} }
  end

  desc "Restart puma.service and puma.socket"
  task :hard_restart => :remote_environment do
    command %{ #{ fetch(:sysctl_cmd) } restart #{fetch(:socket_unit_name)} #{fetch(:service_unit_name)} }
  end

end
