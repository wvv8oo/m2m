require 'rack'
require_relative './util'
require_relative './setup'

class Server < ::Rack::Server
	def app
		Rack::Directory::new Setup.instance.target_dir
	end
end