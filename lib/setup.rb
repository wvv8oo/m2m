require 'yaml' 
require 'singleton'
require_relative './util'

class Setup
	include Singleton

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
	end

	#读取邮件的配置
	def mail_config
		@mail_config = self.get_merged_config['mail'] if not @mail_config
		@mail_config
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
        dir = File::join(@util.get_temp_dir, @util.project_name) if not dir

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
			value = ask(item['ask'], item['type']){|q| 
				q.default = item['default'] if item['default']
				q.echo = item['echo'] if item['echo']
				q.validate = item['validate'] if item['validate']
				q.responses[:not_valid] = item['error'] if item['error']
			}

			data[item['key']] = value.to_s
		}
		data
	end


	#询问用户的信息
	def ask_mail
		#获取全局的配置
		data = self.read true
		mail_data = data['mail'] || {}

		items = [
			{
				'key' => 'smtp_server',
				'ask' => '请输入您的STMP服务器地址，如smpt.163.com',
				'default' => mail_data['smtp_server'],
				'type' => String,
				'validate' => /(\.[a-zA-Z0-9\-]+){2,}/,
				'error' => '您的SMTP地址输入不正确，请输入域名或者IP地址'
			},{
				'key' => 'port',
				'ask' => '邮件发送的端口，默认为465',
				'default' => mail_data['port'] || 465,
				'type' => Integer,
				'validate' => /^\d+$/,
				'error' => '您的端口输入不正确，只能输入整数'
			},{
				'key' => 'username',
				'ask' => '邮件帐号，如mail@example.com',
				'default' => mail_data['username'],
				'type' => String,
				'validate' => /^[a-z0-9]+([._\\-]*[a-z0-9])*@([a-z0-9]+[-a-z0-9]*[a-z0-9]+.){1,63}[a-z0-9]+$/,
				'error' => '您的邮箱帐号输入不正确'
			},{
				'key' => 'from',
				'ask' => '发件人，如<张三> mail@example.com，如果没有设置，则与邮件帐号一致',
				'default' => mail_data['from'],
				'type' => String
			},{
				'key' => 'subject',
				'ask' => '默认的邮件主题，非必填，按回车可以跳过',
				'default' => mail_data['subject'],
				'type' => String
			},{
				'key' => 'addressee',
				'ask' => '默认收件人，多个以逗号为分隔，非必填，按回车可以跳过',
				'default' => mail_data['subject'],
				'type' => String
			}
		]

		mail_data = self.ask_items items, mail_data
		#设置默认的format
		mail_data['format'] = mail_data['format'] || '%Y/%m/%d'
		mail_data['from'] = mail_data['from'] || mail_data['username']
		#填到mail
		data['mail'] = mail_data

		#写入文件
		self.write data, true

		#询问密码
		self.ask_mail_password
	end

	#用户输入密码以及加密内容
	def ask_mail_password
		data = self.read true
		mail_data = data['mail'] || {}

		items = [
			{
				'key' => 'password',
				'ask' => '您邮件密码，邮件密码以加密的方式保存在您本地电脑上',
				'default' => nil,
				'echo' => '*',
				'type' => String,
				'validate' => /.{1,}/,
				'error' => '请输入您的邮件密码'
			},{
				'key' => 'encrypt_key',
				'ask' => '用于加密您密码的钥匙，请牢记，按回车可以跳过',
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

		puts mail_data
		data['mail'] = mail_data
		self.write data, true
	end
end