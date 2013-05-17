module Leonidas
	module Commands
		
		# requires that #all_commands be defined on the includer
		module Filterer
			
			# inclusive of timestamp
			def commands_from(timestamp)
				filter_commands(from: timestamp)
			end

			def commands_through(timestamp)
				filter_commands(through: timestamp)
			end

			# exclusive of timestamp
			def commands_since(timestamp)
				filter_commands(since: timestamp)
			end

			def commands_to(timestamp)
				filter_commands(to: timestamp)
			end

			private

			def filter_commands(options={})
				filtered_commands = all_commands

				filtered_commands.select! {|command| command.timestamp >= get_timestamp(options[:from])} unless options[:from].nil?
				filtered_commands.select! {|command| command.timestamp >  get_timestamp(options[:since])} unless options[:since].nil?
				filtered_commands.select! {|command| command.timestamp <= get_timestamp(options[:through])} unless options[:through].nil?
				filtered_commands.select! {|command| command.timestamp <  get_timestamp(options[:to])} unless options[:to].nil?
				
				filtered_commands
			end

			def get_timestamp(timestampy_thing)
				return timestampy_thing if timestampy_thing.is_a? Time
				return Time.at(timestampy_thing) if timestampy_thing.is_a? Fixnum
				raise TypeError, "Argument must be more 'timestampy'"
			end

		end

	end
end