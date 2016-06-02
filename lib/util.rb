require 'json'
require 'fileutils'
require 'singleton'

class Util
    include Singleton

    def initialize
        file = File::join(Dir::pwd, 'm2b.config')
        if not File::exists?(file)
            puts 'Warning: m2b.config is not found, please use <m2b init> to create it.'
            exit(1)
        end

        @config = JSON.parse IO.read(file)

        #本地主题的目录
        @local_theme_dir = '.theme'
        #当前的工作目录
        @workbench = ''
        #markdown的文件目录
        @content_dir = ''
        #构建的目标目录
        @build_dir = nil
    end

    #获取产品相关的信息
    def get_product
        {
            'name' => 'm2b',
            'version' => '0.0.1',
            'url' => 'http://m2b.wvv8oo.com'
        }
    end

    def build_dir
        @build_dir
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

    def workbench
        @workbench
    end

    def project_name
        @project_name
    end

    #临时目录
    def temp_dir
        dir = File.join(Dir.home, ".m2b")
        #如果不存在则创建一个
        Dir::mkdir(dir) if(!File::exists?(dir))
        dir
    end

    def write_file(file, content)
        dir = File::dirname file
        #如果不在存文件夹, 则先创建
        # puts dir
        FileUtils.mkpath(dir) if not File::exists?(dir)
        #写入文件
        IO.write(file, content)
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

    #获取一个相对路径离root有几个..
    def get_relative_dot(relative_url)
        depth = relative_url.split('/').length - 1
        return './' if depth == 0
        return '../' * (relative_url.split('/').length - 1)
    end

    def workbench=(dir)
        #工作目录
        @workbench = dir
        #项目名称
        @project_name = File::basename dir

        #获取文件的根目录
        @content_dir = Pathname.new(dir) + Pathname.new(@config['content'] || './')

        #如果用户有配置构建目标，则使用用户的配置
        target = @config['target']
        if(target)
            @build_dir = Pathname.new(@workbench) + Pathname.new(target)
        else
            #没有的情况下，使用临时目录构建
            @build_dir = Pathname.new File::join(@temp_dir, @project_name)
        end
    end
end