require 'json'
require 'yaml' 
require 'fileutils'
require 'singleton'

class Util
    include Singleton

    def initialize
        #本地主题的目录
        @local_theme_dir = '.theme'
        #当前的工作目录
        @workbench = ''
        #markdown的文件目录
        @content_dir = ''
        #构建的目标目录
        @build_dir = nil
        #配置文件
        @config_file = nil
    end

    ####################  属性 ####################
    def config_file
        @config_file
    end

    def content_dir
        @content_dir
    end

    def local_theme_dir
        @local_theme_dir
    end

    #用户的配置文件
    def config
        @config
    end


    def project_name
        @project_name
    end

    #获取产品相关的信息
    def get_product
        {
            'name' => 'm2b',
            'version' => '0.0.1',
            'url' => 'http://m2b.wvv8oo.com'
        }
    end

    #设置构建目录
    def build_dir=(dir)
        @build_dir = dir
    end

    #最终的构建目录
    def build_dir
        dir = @build_dir
        #已经处理过了
        return dir if dir.class == Pathname

        #如果没有指定构建目录，则使用配置文件的目录
        dir = @config['target'] if not dir
        #依然没有获取准确的目录，则使用使用临时目录
        dir = File::join(@get_temp_dir, @project_name) if not dir

        #如果是字符类型，则获取相对于workbench的目录
        if dir.class == String
            @build_dir = self.get_merge_path(dir)
        end

        @build_dir
    end

    #获取工作台
    def workbench
        @workbench
    end

    def workbench=(dir)
        #在设置工作目录的时候，检查配置文件
        @config_file = self.get_merge_path 'm2b.config', dir
        if not File::exists?(@config_file)
            puts 'Warning: m2b.config is not found, please use <m2b init --config> to create it.'
            exit(1)
        end
        #读取配置文件
        @config = JSON.parse IO.read(@config_file)
        #使用yaml的格式
        # @config = YAML.load IO.read(file)

        #工作目录
        @workbench = dir
        #项目名称
        @project_name = File::basename dir
        #获取文件的根目录
        @content_dir = self.get_merge_path(@config['content'] || './', @workbench)
    end

    ####################  获取 ####################
    #临时目录
    def get_temp_dir
        dir = File.join(Dir.home, ".m2b")
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
        source.relative_path_from(target)
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

    ####################  判断 ####################
    #检查一个文件是否为markdown
    def is_markdown_file?(file)
        (/\.(md)|(markdown)$/i =~ file) != nil
    end

    #检查文件是否为.开头的文件
    def is_shadow_file?(file)
        (/^\./ =~ file) != nil
    end

    #是否为用户忽略的文件
    def is_user_ignore_file?(file)
        ignore = @config['ignore']
        return false if not ignore

        ignore.each { |current|
            #TODO 这里还需要再增加
        }

        return false
    end
end