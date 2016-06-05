#将markdown发送为邮件
require 'mail'
require_relative './scan'
require_relative './compiler'
require_relative './util'
require_relative './store'

class Mailer
	def initialize
		@util = Util.instance
		@mail_config = @util.config['mail']

		return @util.error '请配置邮件参数' if not @mail_config

		#扫描所有文件
        scan = Scan.new
        scan.execute

        @store = Store.new scan.files
        @compiler = Compiler.new

        self.set_mail_defaults
	end

	def set_mail_defaults
		smtp_server = @mail_config['smtp']
		port = @mail_config['port']
		password = @mail_config['password']
		username = @mail_config['account']
		ssl = @mail_config['ssl']

        #配置邮件参数
		Mail.defaults do
		  delivery_method :smtp, {
		  	:address => smtp_server,
		  	:port => port,
		  	# :domain => smtp_server,
		  	:user_name => username,
		  	:password => password,
		  	:enable_starttls_auto => false
		  }
		end
	end

	#获取邮件接收人
	def get_to(to)
		if not to
			to = @mail_config['to']
		end

		return @util.error '邮件接收人无效' if not to

		to = [to] if to.class == String
		to
	end

	#获取将要发送的markdown文件
	def get_article(md_file)
		#如果用户没有指定, 则取最新的
		if not md_file
			items = @store.get_children()
			return @util.error '没有找到任何的Markdown文件' if items.length == 0

			key = items[0]
			article = @store.articles[key]
			return article
		end

		#如果用户指定， 遍历所有文件，查找匹配的文章，如果有多个，则提示用户选择
	end

	#优先读取用户指定的，然后读取文章中指定的subject，再读取配置文件中的
	def get_subject(subject, article)
		#读取文章中mate的
		if not subject
			meta = article['meta']
			subject = meta['subject'] if meta
		end

		#文章中没有，则使用配置文件中的
		subject = @mail_config['subject'] if not subject
		#配置文件也没有，则使用文件名

		self.covert_date_macro subject
	end

	def get_from
		from = @mail_config['from']
		from = @mail_config['account'] if not from
		from
	end

	#将标题中的日期宏，转换为对应的日期
	def covert_date_macro(subject)
		format = @mail_config['format'] || '%Y-%m-%d'
		subject = subject.gsub('$now', Date.today.strftime(format))
		subject = subject.gsub('$last_week', (Date.today - 7).strftime(format))
		subject
	end

# 	#获取邮件的message
# 	def get_message_with_attachment(from, to, subject, body)
# 		marker = 'AUNIQUEMARKER'

# 		header = <<EOF
# From: #{from}
# To: #{to}
# MIME-Version: 1.0
# Content-type: multipart/mixed; boundary=#{marker}
# Subject: #{subject}
# --#{marker}
# EOF

# 		body = <<EOF
# Content-Type: text/html
# Content-Transfer-Encoding:8bit

# #{body}
# --#{marker}
# EOF

# 		return header + body + self.get_attachment(body, marker)
# 	end

# 	#没有附件的message
# 	def get_message(from, to, subject, body)
# 		message = <<EOF
# From: #{from}
# To: #{to}
# MIME-Version: 1.0
# Content-type: text/html
# Subject: #{subject}

# #{body}
# EOF
# 		message
# 	end

# 	#根据邮件正方，分析附件，并附加到邮件内容中
# 	def get_attachment(body, marker)
# 		return ''
# 	end

# 	#发送邮件
# 	def send(message, to)
# 		#发送邮件
# 		smtp_server = @mail_config['smtp']
# 		port = @mail_config['port']
# 		password = @mail_config['password']
# 		username = @mail_config['account']

# 		puts message
# 		begin
# 			Net::SMTP.start(smtp_server, port, 
# 				'localhost', username, password) do |smtp|
# 		     smtp.sendmail(message, username, [to])
# 			end
# 		rescue Exception => e  
# 			puts '邮件发送失败，原因如下：'
# 			print "Exception occured: " + e  
# 		end 
# 	end


	#发送邮件
	def execute(to, md_file, subject)
		Mail::TestMailer.deliveries
		to = self.get_to to
		from = self.get_from
		article = self.get_article md_file
		subject = self.get_subject subject, article

		#获取body的内容
		data = {
			"article" => article
		}
		body = @compiler.execute 'mail', data, false

		mail = Mail.deliver do
			from from
			to to
			subject subject
			html_part do
				content_type 'text/html; charset=UTF-8'
				body body
			end
		end

		puts "邮件发送成功 => #{subject}"

		# return
		# #获取邮件的message
		# message = self.get_message from, to, subject, body

 	# 	self.send message, to
 	# 	puts '发送成功'
	end
end