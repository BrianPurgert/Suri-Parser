# Set the application directory
@dir = File.expand_path("../..", __FILE__) + '/'
puts @dir

# Define workers for concurrency
# RUBY_ENGINE == 'truffleruby' ? workers 1 : workers Etc.nprocessors

# Define threads for workers
threads 1, 12

# Specify port
port 80

# Specify path for process id and state
pidfile "#{@dir}tmp/pids/puma.pid"
state_path "#{@dir}tmp/pids/state"

# Define SSL bindings and certificates
ssl_bind '0.0.0.0', '443', {
  key:  '/etc/letsencrypt/live/getthis.page/privkey.pem',
  cert: '/etc/letsencrypt/live/getthis.page/fullchain.pem'
}

# Define log file paths
# stdout_redirect "#{@dir}log/puma.stderr.log", "#{@dir}log/puma.stdout.log", true

activate_control_app

