# Set the application directory
@dir = File.expand_path('../..', __FILE__) + '/'

# Define workers for concurrency
threads 1, 5

# Specify port
port 80

# Specify path for process id and state
pidfile "#{@dir}tmp/pids/puma.pid"
state_path "#{@dir}tmp/pids/state"

# Define SSL bindings and certificates
require 'rbconfig'

is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)

ssl_bind '0.0.0.0', '443', {
key:         is_windows ? 'C:/Certbot/live/getthis.page/privkey.pem' : '/mnt/c/Certbot/live/getthis.page/privkey.pem',
cert:        is_windows ? 'C:/Certbot/live/getthis.page/fullchain.pem' : '/mnt/c/Certbot/live/getthis.page/fullchain.pem',
verify_mode: 'none'
}

# Activate control app
activate_control_app