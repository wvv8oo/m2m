# -*- coding: utf-8 -*-

require 'webrick'
require_relative './util'
require_relative './setup'

# class Server < ::Rack::Server
# 	def app
# 		Rack::Directory::new Setup.instance.target_dir
# 	end
# end

class Server
	def start(port)
		port = port || 8000
		root = Setup.instance.target_dir
		server = WEBrick::HTTPServer.new :Port => port, :DocumentRoot => root
		server.start
	end
end