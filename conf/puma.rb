# set path to app that will be used to configure puma,
# note the trailing slash in this example
@dir = File.expand_path("../..", __FILE__) + '/'
puts @dir
# @dir = '/home/pi/roda/plug-control/'

# Set workers equal to CPU core count
workers Etc.nprocessors

# Min and Max threads per worker
threads 1, 4

# Set application directory
app_dir = @dir

# Specify path to socket puma listens to,
# we will use this in our nginx.conf later
# bind "#{@dir}tmp/sockets/puma.sock", :backlog => 64
port 80

# Set process id path
pidfile "#{@dir}tmp/pids/puma.pid"
state_path "#{@dir}tmp/pids/state"

# Certificate is saved at: /etc/letsencrypt/live/dev.brianpurgert2.com/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/dev.brianpurgert2.com/privkey.pem
# Certificate is saved at: /etc/letsencrypt/live/getthis.page/fullchain.pem
# Key is saved at:         /etc/letsencrypt/live/getthis.page/privkey.pem

ssl_bind '0.0.0.0', '443', {
key:  '/etc/letsencrypt/live/getthis.page/privkey.pem',
cert: '/etc/letsencrypt/live/getthis.page/fullchain.pem'
}

# Set log file paths
stdout_redirect "#{@dir}log/puma.stderr.log", "#{@dir}log/puma.stdout.log", true

activate_control_app
