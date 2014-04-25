require 'leonidas'
require 'leonidas-sinatra/routes/console'
require 'leonidas-sinatra/routes/sync'

module LeonidasSinatra

	VERSION = [0,0,1]

	def self.version
		VERSION.join('.')
	end
	
end