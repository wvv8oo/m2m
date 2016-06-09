require 'json'
require 'yaml' 
require 'fileutils'
require 'singleton'
require_relative './product'

class Util
    include Singleton
    
    attr :config_file
    attr :local_theme_dir
    attr :config
    attr :project_name
    attr :workbench
    attr :build_dir, true

    def initialize
        #本地主题的目录
        @local_theme_dir = '.theme'
        #当前的工作目录
        @workbench = nil
        #markdown的文件目录
        @content_dir = nil
        #构建的目标目录
        @build_dir = nil
        #配置文件的文件名
        @config_file = 'm2m.config'
    end

    ####################  属性 ####################
    def content_dir
        #获取文件的根目录
        if not @content_dir
            @content_dir = self.get_merge_path(@config['content'] || './', @workbench)
        end

        @content_dir
    end


    #获取产品相关的信息
    def get_product
        {
            'name' => M2M::NAME,
            'version' => M2M::VERSION,
            'homepage' => M2M::HOMEPAGE,
            'repos' => M2M::REPOS
        }
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

    def workbench=(dir)
        #在设置工作目录的时候，检查配置文件
        file = self.get_merge_path @config_file, dir
        if not File::exists?(@config_file)
            self.error '提示: 配置文件<m2m.config>不存在, 请使用命令<m2m init --config>创建'
        end

        #读取配置文件
        @config = JSON.parse IO.read(file)
        #使用yaml的格式
        # @config = YAML.load IO.read(file)

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