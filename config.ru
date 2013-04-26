require './bootstrap'

map '/assets' do
  run Keystone::Server
end

map '/sync' do
	run Leonidas::Routes::SyncApp
end

map '/' do
	run TestApp
end