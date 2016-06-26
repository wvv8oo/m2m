# -*- coding: utf-8 -*-

require 'pathname'
require_relative './util'
require_relative './setup'

class Scan
    #初始化
    def initialize()
        @util = Util.instance
        @setup = Setup.instance
        @files = Array.new
    end

    #返回已经获取的文件列表
    def files
        return @files
    end

    #获取文件
    def fetch(dir)
        Dir::entries(dir).each do |filename|
            #忽略的文件
            next if @util.is_shadow_file?(filename)

            #检查是否配置文件中所忽略的文件
            #这里需要用相对路径
            next if @setup.is_user_ignore_file?(filename)

            file = File::join(dir, filename)
            #如果是文件夹类型, 则继承查找
            if(File.ftype(file) == 'directory')
                self.fetch file
                next
            end

            #如果文件扩展名是md, 则加入到files中
            if @util.is_markdown_file?(filename)
                current_dir = Pathname.new file
                @files.push current_dir.relative_path_from(@setup.content_dir)
            end
        end
    end

    #执行
    def execute()
        fetch @setup.content_dir
    end
end