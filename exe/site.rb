require 'commander'
require_relative '../lib/generator'
require_relative '../lib/setup'

module SiteCommand
	def site(c)
		c.syntax = 'm2m site [options]'
		c.summary = ''
		c.description = ''
		c.option '-s STRING', '--source STRING', String, 'Markdown源文件的目录'
		c.option '-t STRING', '--target STRING', String, '生成的目标目录'
		c.option '--force', String, '强行生成，如果目录存在，则会被删除'
		c.action do |args, options|
			target = options.target
			source = options.source


			util = Util.instance
			setup = Setup.instance

			#合并目录
			util.workbench = util.get_merge_path(source)
			#设置构建目录
			setup.target_dir = target

			#检查目标目录是否存在
			if File::exists? setup.target_dir
				question = "目标目录已经存在，您确认需要删除吗？[y/n]"
				tips = "目标目录存在，生成失败"
				util.error tips if not (options.force or agree question)
			end

			#执行生成
			Generator.new
		end
	end
end