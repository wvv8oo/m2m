# -*- coding: utf-8 -*-

#使用模板转换为HTML

require 'pathname'
require 'mustache'
require 'fileutils'

require_relative './util'
require_relative './setup'

class Compiler
    def initialize()
        @util = Util.instance
        @setup = Setup.instance

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
        dir = @util.target_dir
        #存在则先删除
        FileUtils.rm_rf(dir) if File::exists?(dir)
        #创建目录
        Dir::mkdir(dir)
        dir
    end


    #根据配置获取theme, 如果没有, 则使用默认的theme
    def get_theme_dir()
        #获取用户配置的theme
        theme_dir = @setup.get_theme
        #如果这个目录存在，则使用用户设置的主题
        return theme_dir if theme_dir and File::exists?(theme_dir)

        #没有找到配置，则考虑默认的theme目录
        theme_dir = File::join(@workbench, @util.local_theme_dir)
        return theme_dir if(File::exists?(theme_dir))

        #还是没有找到，则使用系统自带主题
        File::join(@util.themes_dir, 'hyde')
    end


    #读取模板
    def read_template(name)
        file = File::join(@template_dir, name + '.mustache')
        @util.read_file file
    end

    #执行生成,
    #filename: 相对文件路径
    def execute(type, data, auto_save = true, filename = '')
        data['site'] = @setup.site_config
        data['m2m'] = @util.get_product

        template = self.read_template type
        html = Mustache.render(template, data)

        return html if not auto_save

        file = File::join @setup.target_dir, filename
        @util.write_file file, html
    end
end