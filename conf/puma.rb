# set path to app that will be used to configure puma,
# note the trailing slash in this example
@dir = File.expand_path("../..", __FILE__) + '/'
puts @dir
# @dir = '/home/pi/roda/plug-control/'

# Change to match your CPU core count
workers 2

# Min and Max threads per worker
threads 1, 4
app_dir = @dir

# Specify path to socket puma listens to,
# we will use this in our nginx.conf later
# bind "#{@dir}tmp/sockets/puma.sock", :backlog => 64
port 80

# Set process id path
pidfile "#{@dir}tmp/pids/puma.pid"
state_path "#{@dir}tmp/pids/state"

# Set log file paths
stdout_redirect "#{@dir}log/puma.stderr.log", "#{@dir}log/puma.stdout.log", true

activate_control_app
