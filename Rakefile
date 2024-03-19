def kill_server
    pid_file_path = './tmp/pids/puma.pid'
    if File.exist?(pid_file_path)
        pid = File.read(pid_file_path).strip
        puts "Killing process with pid #{pid}"
        Process.kill('TERM', pid.to_i)
    else
        puts "PID file does not exist"
    end

    # Kill processes using port 80
    port_80_processes = `lsof -i :80 -t`.split("\n")
    port_80_processes.each do |pid|
        puts "Killing process with pid #{pid} on port 80"
        Process.kill('TERM', pid.to_i)
    rescue Errno::ESRCH
        puts "Process #{pid} does not exist"
    rescue Errno::EPERM
        puts "Insufficient permissions to kill process #{pid}"
    end
end

PUMA_C = 'puma -C ./conf/puma.rb'

def start_server(background: false)
    cmd = PUMA_C
    cmd += ' &' if background
    sh cmd
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

task(:default) { puts `rake -T` }

desc 'run dev'
task :dev do |_|
    sh "rerun -- #{PUMA_C}"
end

desc 'Start the puma server'
task :puma do |_|
    start_server
end



