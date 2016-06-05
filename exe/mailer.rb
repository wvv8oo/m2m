require 'commander'
require_relative '../lib/mailer'

module MailCommand
	def mail(c)
		c.syntax = 'm2b mail [options]'
		c.summary = '将Markdown转换为HTML，并邮件发送给某人'
		c.description = ''
		c.option '-s STRING', '--subject STRING', String, '邮件主题，可选'
		c.option '-t STRING', '--to STRING', String, '要发送的人，可选'
		c.option '-f STRING', '--file STRING', String, '要发送的markdown文件，如果不指定，则使用最近修改的文件'
		c.action do |args, options|
		
		util = Util.instance
		#合并目录
		util.workbench = util.get_merge_path('./')
		
		mailer = Mailer.new
		mailer.execute options.file, options.to, options.subject
		end
	end
end