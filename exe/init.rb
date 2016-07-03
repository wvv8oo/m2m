# -*- coding: utf-8 -*-

require 'commander'
require 'fileutils'
require_relative '../lib/util'

module InitCommand
	def init(c)
		c.syntax = 'm2m init [options]'
		c.summary = '初始化'
		c.description = ''
		c.option '--theme', '创建一个主题'
		c.option '--force', String, '强行创建，如果已经存在，则删除'
		c.action do |args, options|
			util = Util.instance
			
			if options.theme
				source = File::join util.themes_dir, 'hyde'
				target = File::join util.get_merge_path(util.local_theme_dir)

				#检查目标目录是否存在
				if File::exists? target
					question = "目标目录已经存在，您确认需要删除吗？[y/n]"
					tips = "目标目录已经存在，创建失败"
					util.error tips if not (options.force or agree question)

					#删除目标目录
        			FileUtils.rmtree target
				end

				FileUtils.cp_r source, target

				puts '创建本地主题成功'
			end
		end
	end
end