assets_are_in File.expand_path("#{File.dirname(__FILE__)}/app/assets")

asset 'commands.js' do |a|
	a.scan 'scripts/coffee', 'scripts/js'
	a.toolchain :coffeescript, :require
	# a.post_build :closure
end