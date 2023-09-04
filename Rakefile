desc 'Run the server'
task :run, [:port] do |_, args|
	puts 'Starting server'
	args.with_defaults(port: 80)
	sh "rackup config.ru -p #{args.port}"
end

# Set :run as the default task
task default: :run

desc 'Start the puma server'
task :puma do |_|
	sh 'puma -C ./conf/puma.rb'
end

desc 'Start the puma server'
task :pumad do |_|
	sh 'puma -C ./conf/puma.rb &'
	puts 'Puma is running in the background'
end

desc 'Restart puma server'
task :restart do |_|
	pid = `cat ./tmp/pids/puma.pid`
	puts "Killing process with pid #{pid}"
	`kill -9 #{pid}`
	puts 'Restarting server'
	sh 'puma -C ./conf/puma.rb &'
	puts 'Puma is running in the background'
end

desc 'Kill Puma server'
task :killserver do |_|
	pid = `cat ./tmp/pids/puma.pid`
	puts "Killing process with pid #{pid}"
	`kill -9 #{pid}`
end
