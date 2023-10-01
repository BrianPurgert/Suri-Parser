def start_server(background: false)
    cmd = 'bundle exec rerun -- puma -C ./conf/puma.rb'
    cmd += ' &' if background
    sh cmd
end

def kill_server
    pid = File.read('./tmp/pids/puma.pid').strip
    puts "Killing process with pid #{pid}"
    Process.kill('TERM', pid.to_i)
end

task(:default) { puts `rake -T` }

desc 'run dev'
task :dev, [:port] do |_, args|
    puts 'Starting server'
    args.with_defaults(port: 80)
    sh "puma -C ./conf/puma.rb -p #{args.port}"
end

desc 'Start the puma server'
task :puma do |_|
    start_server
end

desc 'Start the puma server in the background'
task :pumad do |_|
    start_server(background: true)
    puts 'Puma is running in the background'
end

desc 'Restart puma server'
task :restart do |_|
    kill_server
    puts 'Restarting server'
    start_server(background: true)
    puts 'Puma is running in the background'
end

desc 'Kill Puma server'
task :kys do |_|
    kill_server
end

