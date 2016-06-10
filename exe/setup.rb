require 'commander'
require_relative '../lib/setup'

module SetupCommand
	def setup(c)
		c.syntax = 'm2m setup [options]'
		c.summary = ''
		c.description = '配置M2M'
		c.option '--mail', '配置邮件相关的信息'
		c.option '--mail-password', '配置邮件相关的信息'
		c.action do |args, options|
			setup = Setup.instance

			if options.mail
				setup.ask_mail
			elsif options.mail_password
				setup.ask_mail_password
			end
		end
	end
end