module Leonidas
	module Commands
		
		# requires that #all_commands be defined on the includer
		module Filterer
			
			# inclusive of timestamp
			def commands_from(timestamp, commands=nil)
				filter_commands({ from: timestamp }, commands)
			end

			def commands_through(timestamp, commands=nil)
				filter_commands({ through: timestamp }, commands)
			end

			# exclusive of timestamp
			def commands_since(timestamp, commands=nil)
				filter_commands({ since: timestamp }, commands)
			end

			def commands_to(timestamp, commands=nil)
				filter_commands({ to: timestamp }, commands)
			end

			private

			def filter_commands(options={}, commands=nil)
				raise StandardError, "Includee class must include #all_commands" unless self.respond_to? :all_commands
				filtered_commands = commands.nil? ? all_commands.dup : commands.dup

				filtered_commands.select! {|command| command.timestamp >= get_timestamp(options[:from])} unless options[:from].nil?
				filtered_commands.select! {|command| command.timestamp >  get_timestamp(options[:since])} unless options[:since].nil?
				filtered_commands.select! {|command| command.timestamp <= get_timestamp(options[:through])} unless options[:through].nil?
				filtered_commands.select! {|command| command.timestamp <  get_timestamp(options[:to])} unless options[:to].nil?
				
				filtered_commands
			end

			def get_timestamp(timestampy_thing)
				return timestampy_thing if timestampy_thing.is_a? Time
				return timestampy_thing.timestamp if timestampy_thing.is_a? ::Leonidas::Commands::Command
				return Time.at(timestampy_thing) if [ Fixnum, Float ].include? timestampy_thing.class
				raise TypeError, "Argument must be more 'timestampy'"
			end

		end

	end
end