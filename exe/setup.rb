# -*- coding: utf-8 -*-

require 'commander'
require_relative '../lib/setup'
require_relative '../lib/util'

module SetupCommand
	def setup(c)
		c.syntax = 'm2m setup [options]'
		c.summary = ''
		c.description = '配置M2M'
		c.option '--mail', '配置邮件相关的信息'
		c.option '--mail-password', '配置邮件相关的信息'
		c.option '--site', '在当前目录下，配置网站相关信息'
		c.action do |args, options|
			setup = Setup.instance
			util = Util.instance

			if options.mail
				setup.ask_mail
			elsif options.mail_password
				setup.ask_mail_password
			elsif options.site
				util.workbench = util.get_merge_path './'
				setup.ask_site
			end
		end
	end
end