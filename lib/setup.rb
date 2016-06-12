require 'yaml' 
require 'singleton'
require_relative './util'
require_relative './product'

class Setup
	include Singleton
	attr :target_dir, true
	
	def initialize
		@util = Util.instance
		#合并后的配置信息
		@merge_config = nil
		#内容目录
		@content_dir = nil
		#构建的目标目录
        @target_dir = nil
        #邮件的配置
        @mail_config = nil
        #网站的配置
        @site_config = nil
	end

	#读取邮件的配置
	def mail_config
		@mail_config = self.get_merged_config['mail'] || {} if not @mail_config
		@mail_config
	end

	#读取网站的配置
	def site_config
		@site_config = self.get_merged_config['site'] || {} if not @mail_config
		@site_config
	end


	#最终的构建目录
    def target_dir
        dir = @target_dir
        #已经处理过了
        return dir if dir.class == Pathname

        #如果没有指定构建目录，则使用配置文件的目录
        config = self.get_merged_config
        dir = config['target'] if not dir

        #依然没有获取准确的目录，则使用使用临时目录
        # dir = File::join(@util.get_temp_dir, @util.project_name) if not dir
        #如果没有获取构建目录，则在当前目录下，创建一个
        dir = './m2m-site' if not dir
        #如果是字符类型，则获取相对于workbench的目录
        @target_dir = @util.get_merge_path dir if dir.class == String

        @target_dir
    end

	#获取内容的目录
    def content_dir
        if not @content_dir
            content_dir = self.get_merged_config['content'] || './'
            @content_dir = @util.get_merge_path(content_dir, @util.workbench)
        end

        @content_dir
    end

	#获取配置文件的地址
	def get_config_file(is_global = true)
		root = is_global ? @util.get_temp_dir : @util.workbench
		#全局的配置文件
		File::join root, @util.config_file
	end

	#读取配置文件
	def read(is_global)
		file = self.get_config_file is_global
		return {} if not File::exists? file

		#读取配置文件 
        YAML.load IO.read(file)
	end

	#写入配置文件
	def write(config, is_global)
		file = self.get_config_file is_global
		@util.write_file file, config.to_yaml
	end

	#读取本地与全局的配置文件，然后合并
	def get_merged_config
		return @merge_config if @merge_config

		global_config = self.read true
		local_config = self.read false
		@merge_config = global_config.merge local_config
		@merge_config
	end

    #是否为用户在配置文件中的忽略的文件
    def is_user_ignore_file?(file)
    	config = self.get_merged_config
        ignores = config['ignore']
        return false if not ignores

        ignores.each { |current|
            #TODO 这里还需要再增加
        }

        return false
    end

	#根据问题的配置文件列表，揭示用户输入
	def ask_items(items, data)
		items.each { |item|
			type = item['type']
			value = ask(item['ask'], type){|q| 
				q.default = item['default'] if item['default']
				q.echo = item['echo'] if item['echo']
				q.validate = item['validate'] if item['validate']
				q.responses[:not_valid] = item['error'] if item['error']
			}

			if type == Integer
				value = value.to_i
			else
				value = value.to_s
			end

			data[item['key']] = value
		}
		data
	end

	#检查邮件的配置
	def check_mail_setup
		mail_config = self.get_merged_config['mail']

		return @util.error '请执行[m2m mail --setup]启动配置' if not mail_config
		
		items = {
			'smtp_server' => 'STMP服务器',
			'port' => '端口',
			'username' => '用户名',
			'password' => '密码',
			'from' => '发件人'
		}

		items.each {|key, desc|
			@util.error "#{desc}没有配置，请执行[m2m mail --setup]启动配置" if mail_config[key] == ''
		}
	end

	#询问用户的信息
	def ask_mail
		#获取全局的配置
		data = self.read true
		mail_data = data['mail'] || {}

		items = [
			{
				'key' => 'smtp_server',
				'ask' => '请输入您的【SMTP服务器地址】，如smpt.163.com',
				'default' => mail_data['smtp_server'],
				'type' => String,
				'validate' => /(\.[a-zA-Z0-9\-]+){2,}/,
				'error' => '您的SMTP地址输入不正确，请输入域名或者IP地址'
			},{
				'key' => 'port',
				'ask' => '请输入您的【SMTP端口】，默认为465',
				'default' => mail_data['port'] || 465,
				'type' => Integer,
				'validate' => /^\d+$/,
				'error' => '您的端口输入不正确，只能输入整数'
			},{
				'key' => 'username',
				'ask' => '请输入您的【邮件帐号】，如mail@example.com',
				'default' => mail_data['username'],
				'type' => String,
				'validate' => /^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$/,
				'error' => '您的邮箱帐号输入不正确'
			},{
				'key' => 'from',
				'ask' => '请输入您的【发件人邮件地址】，如<张三> mail@example.com，如果没有设置，则与邮件帐号一致',
				'default' => mail_data['from'],
				'type' => String
			},{
				'key' => 'subject',
				'ask' => '请输入您的【默认邮件主题】，非必填，按回车可以跳过',
				'default' => mail_data['subject'],
				'type' => String
			},{
				'key' => 'to',
				'ask' => '请输入您的【默认收件人】，多个以逗号为分隔，非必填，按回车可以跳过',
				'default' => mail_data['to'],
				'type' => String
			},{
				'key' => 'ssl',
				'ask' => '请确认【是否启用SSL】，一般465或者587端口都会启用SSL，[y/n]',
				'default' => mail_data['ssl'] || 'y',
				'validate' => /^[yn]$/,
				'error' => '请输入y或者n表示是否启用SSL',
				'type' => String
			}
		]

		mail_data = self.ask_items items, mail_data
		#设置默认的format
		mail_data['format'] = '%Y/%m/%d' if mail_data['format'] == ''
		#没有设置from，则使用username
		mail_data['from'] = mail_data['username'] if mail_data['from'] == ''

		#填到mail
		data['mail'] = mail_data

		#写入文件
		self.write data, true

		#询问密码
		self.ask_mail_password false

		puts "您的邮件基本信息配置成功，更多配置方式请参考：#{M2M::HOMEPAGE}config.html"
	end

	#用户输入密码以及加密内容
	def ask_mail_password(show_success_message = false)
		data = self.read true
		mail_data = data['mail'] || {}

		items = [
			{
				'key' => 'password',
				'ask' => '请输入您的【邮箱密码】，邮件密码以加密的方式保存在您本地电脑上',
				'default' => nil,
				'echo' => '*',
				'type' => String,
				'validate' => /.{1,}/,
				'error' => '请输入您的邮件密码'
			},{
				'key' => 'encrypt_key',
				'ask' => '请输入您的【加密钥匙】，此钥匙用于解密您的密码，请务必牢记，按回车可以跳过',
				'default' => nil,
				'echo' => '*',
				'type' => String
			}
		]

		new_data = {}
		new_data = self.ask_items items, new_data

		#对密码进行加密
		password = new_data['password']
		encrypt_key = new_data['encrypt_key']

		password = @util.encrypt password, encrypt_key
		mail_data['password'] = password
		mail_data['safer'] = encrypt_key != ''

		data['mail'] = mail_data
		self.write data, true

		puts '您的邮件密码配置成功' if show_success_message
	end

	#配置网站相关的
	def ask_site
		data = self.read false
		site_data = data['site'] || {}

		items = [
			{
				'key' => 'title',
				'ask' => '您的网站标题，如：M2M官方网站，按回车跳过',
				'default' => site_data['title'],
				'type' => String
			},{
				'key' => 'host',
				'ask' => '主机地址，如：http://m2m.wvv8oo.com/，按回车跳过',
				'default' => site_data['host'],
				'type' => String
			}
		]

		data['site'] = self.ask_items items, site_data
		self.write data, false
		puts "您的网站配置成功，更多配置方式请参考：#{M2M::HOMEPAGE}config.html"
	end
end