require './bootstrap'

map '/assets' do
  run Keystone::Server
end

map '/' do
	run SyncApp
end