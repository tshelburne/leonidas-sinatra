assets_are_in File.expand_path("#{File.dirname(__FILE__)}/assets")

asset 'leonidas.js' do |a|
	a.scan 'scripts/coffee', 'scripts/js'
	a.toolchain :coffeescript, :require
	a.post_build :closure
end