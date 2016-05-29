#使用模板转换为HTML

require 'mustache'
require 'pathname'
require 'fileutils'
require_relative 'util'

class Compiler
    def initialize()
        @util = Util.instance
        #当前的工作目录
        @workbench = @util.workbench
        @theme_dir = self.get_theme_dir
        @template_dir = File::join(@theme_dir, 'template')
        Mustache.template_path = File::join(@template_dir, 'partials')

    end

    def theme_dir
        @theme_dir
    end

    #获取target, 如果存在, 则删除
    def ensure_target()
        dir = @util.build_dir
        #存在则先删除
        FileUtils.rm_rf(dir) if File::exists?(dir)
        #创建目录
        Dir::mkdir(dir)
        dir
    end

    #根据配置获取theme, 如果没有, 则使用默认的theme
    def get_theme_dir()
        #先从当前工作目录下查找theme目录
        dir = File::join(@workbench, @util.local_theme_dir)
        #当前有theme目录
        return dir if(File::exists?(dir))

        base_dir = File::join(Pathname.new(File.dirname(__FILE__)), 'theme')

        
        #根据用户配置获取theme
        theme_name = @util.config['theme']
        theme_dir = File::join(base_dir, theme_name)

        #如果没有找到对应的theme, 则
        return theme_dir if(File.exists?(theme_dir))
        File::join(base_dir, 'hyde')
    end


    #读取模板
    def read_template(name)
        file = File::join(@template_dir, name + '.mustache')
        IO.read(file)
    end

    #执行生成,
    #filename: 相对文件路径
    def execute(filename, type, data)
        template = self.read_template type
        html = Mustache.render(template, data.merge(@util.config))

        file = File::join @util.build_dir, filename
        @util.write_file file, html
    end
end