require 'json'
require 'yaml' 
require 'fileutils'
require 'singleton'
require 'aescrypt'
require 'base64'

require_relative './product'

class Util
    include Singleton
    
    attr :config_file
    attr :local_theme_dir
    attr :project_name
    attr :workbench
    attr :encrypt_key

    def initialize
        #本地主题的目录
        @local_theme_dir = '.theme'
        #当前的工作目录
        @workbench = nil
        
        #配置文件的文件名
        @config_file = 'm2m.config'
        @encrypt_key = 'm2m'
    end

    ####################  属性 ####################

    #获取产品相关的信息
    def get_product
        {
            'name' => M2M::NAME,
            'version' => M2M::VERSION,
            'homepage' => M2M::HOMEPAGE,
            'repos' => M2M::REPOS
        }
    end


    def workbench=(dir)
        #工作目录
        @workbench = dir
        #项目名称
        @project_name = File::basename dir
    end

    ####################  获取 ####################
    #临时目录
    def get_temp_dir
        dir = File.join(Dir.home, ".m2m")
        #如果不存在则创建一个
        Dir::mkdir(dir) if(!File::exists?(dir))
        dir
    end

    #获取一个相对路径离root有几个..
    def get_relative_dot(relative_url)
        depth = relative_url.split('/').length - 1
        return './' if depth == 0
        return '../' * (relative_url.split('/').length - 1)
    end

    #合并两个路径
    def get_merge_path(relative_path, base_path = Dir::pwd)
        base_path = Pathname.new base_path
        return base_path if not relative_path
        base_path + Pathname.new(relative_path)
    end

    #获取相对路径，如果没有设定source，则使用当前的工作目录
    def get_relative_path(target, source = Dir::pwd)
        target = Pathname.new(target) if target.class == String
        source = Pathname.new(source) if source.class == String
        target.relative_path_from(source).to_s
    end

    ####################  操作 ####################

    def write_file(file, content)
        dir = File::dirname file
        #如果不在存文件夹, 则先创建
        # puts dir
        FileUtils.mkpath(dir) if not File::exists?(dir)
        #写入文件
        IO.write(file, content)
    end

    def error(log, level = 1)
        puts log
        exit level
    end

    ####################  判断 ####################
    #判断一个文件是否为配置文件
    def is_config_file?(file)
        filename = self.get_relative_path file, @workbench
        filename == @config_file
    end
    #检查一个文件是否为markdown
    def is_markdown_file?(file)
        (/\.(md)|(markdown)$/i =~ file) != nil
    end

    #检查文件是否为.开头的文件
    def is_shadow_file?(file)
        (/^\./ =~ file) != nil
    end

    ####################  加解密 ####################
    def encrypt(str, encrypt_key = @encrypt_key)
        AESCrypt.encrypt(str, encrypt_key)
    end

    def decrypt(str, encrypt_key = @encrypt_key)
        AESCrypt.decrypt(str, encrypt_key)
    end
end