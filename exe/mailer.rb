require 'commander'
require_relative '../lib/mailer'

module MailCommand
	def mail(c)
		c.syntax = 'm2m mail [options]'
		c.summary = '将Markdown转换为HTML，并邮件发送给某人'
		c.description = ''
		c.option '-s STRING', '--subject STRING', String, '邮件主题，可选'
		c.option '-a STRING', '--addressee STRING', String, '收件人，可选'
		c.option '--slient', '静默发送，不提示'
		c.option '-m STRING', '--markdown STRING', String, '要发送的markdown文件，如果不指定，则使用最近修改的文件'
		c.action do |args, options|
		
		util = Util.instance
		#合并目录
		util.workbench = util.get_merge_path('./')

		mailer = Mailer.new
		mailer.send options.addressee, options.markdown, options.subject, options.slient
		end
	end
end