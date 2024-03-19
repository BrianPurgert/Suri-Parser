# environment 'production'

# Set the application directory
@dir = File.join(File.expand_path('../..', __FILE__), '/')
puts @dir
# Define workers for concurrency
threads 1, 6

port 80

privkey            = File.join('C:', 'Certbot', 'live', 'getthis.page', 'privkey.pem')
fullchain          = File.join('C:', 'Certbot', 'live', 'getthis.page', 'fullchain.pem')
realpath_privkey   = File.realpath(privkey)
realpath_fullchain = File.realpath(fullchain)
puts realpath_privkey
# Specify path for process id and state

pidfile "#{@dir}tmp/pids/puma.pid"
state_path "#{@dir}tmp/pids/state"

puts File.exist? privkey
puts File.exist? fullchain
# privkey = File.join('C:', 'Certbot', 'archive', 'getthis.page', 'privkey1.pem'),
# fullchain = File.join('C:', 'Certbot', 'archive', 'getthis.page', 'fullchain1.pem')

ssl_bind '0.0.0.0', '443', {
key:         privkey,
cert:        fullchain,
verify_mode: 'none'
}

activate_control_app
