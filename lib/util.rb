require 'json'
require 'fileutils'
require 'singleton'

class Util
    include Singleton

    def initialize
        file = File::join(Dir::pwd, 'config.json')
        @config = JSON.parse IO.read(file)

        @local_theme_dir = '.theme'
        @workbench = ''
    end

    #获取产品相关的信息
    def get_product
        {
            'name' => 'roblog',
            'version' => '0.0.1',
            'url' => 'http://roblog.silky.com'
        }
    end

    def local_theme_dir
        @local_theme_dir
    end

    #用户的配置文件
    def config
        @config
    end

    #临时目录
    def temp_dir
        dir = File.join(Dir.home, ".roblog")
        #如果不存在则创建一个
        Dir::mkdir(dir) if(!File::exists?(dir))
        dir
    end

    def write_file(file, content)
        dir = File::dirname file
        #如果不在存文件夹, 则先创建
        puts dir
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
        @workbench = dir
    end

    def workbench
        @workbench
    end
end