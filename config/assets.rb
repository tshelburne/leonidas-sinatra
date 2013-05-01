assets_are_in "#{::Leonidas.root_path}/assets"

asset 'leonidas.js' do |a|
	a.scan 'scripts/coffee', 'scripts/js'
	a.toolchain :coffeescript, :require
	a.post_build :closure
end