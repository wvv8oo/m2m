require 'commander'
require_relative '../lib/generator'
require_relative '../lib/setup'
require_relative '../lib/server'

module ServerCommand
	def server(c)
		c.syntax = 'm2m server [options]'
		c.summary = ''
		c.description = '创建一个服务器'
		# c.option '--watch', '监控文件的变化'
		c.action do |args, options|
			util = Util.instance
			setup = Setup.instance

			#合并目录
			util.workbench = util.get_merge_path './'

			Server.new.start
		end
	end
end