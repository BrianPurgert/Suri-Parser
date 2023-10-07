# Set the application directory
@dir = File.join(File.expand_path('../..', __FILE__), '/')

# Define workers for concurrency
workers (['truffleruby', 'jruby'].include? RUBY_ENGINE) ? 1 : Etc.nprocessors

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
# stdout_redirect "#{@dir}log/puma.stderr.log", "#{@dir}log/puma.stdout.log", false

activate_control_app

