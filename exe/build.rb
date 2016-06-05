require 'commander'
require_relative '../lib/generator'

module Build
	def execute(c)
		c.syntax = 'm2b build [options]'
		c.summary = ''
		c.description = ''
		c.example 'description', 'command example'
		c.option '-s STRING', '--source STRING', String, 'Markdown source'
		c.option '-t STRING', '--target STRING', String, 'Build target'
		c.action do |args, options|
		target = options.target
		source = options.source


		util = Util.instance
		#合并目录
		util.workbench = util.get_merge_path(source)
		#设置构建目录
		util.build_dir = target

		Generator.new
		end
	end
end