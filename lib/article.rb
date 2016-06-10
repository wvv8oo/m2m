#读取文件内容
require 'nokogiri'
require 'kramdown'
require 'digest'

require_relative 'meta'
require_relative 'toc'
require_relative 'util'
require_relative 'setup'

class Article
    def initialize
        @meta = Meta.new
        @toc = TOC.new
        @util = Util.instance
        @setup = Setup.instance
    end

    #转换文件
    def convert(relative_path)
        result = Hash.new

        file = File::join @setup.content_dir, relative_path

        #原始路径
        result['file'] = file
        #路径的MD5值
        result['relative_path_md5'] = Digest::SHA256.hexdigest(relative_path.to_s)[0..15]

        result['mtime'] = File::ctime file

        #读取原始内容
        original = IO.read(file)
        result['original'] = original

        #相对路径
        result['relative_path'] = relative_path
        result['relative_url'] = relative_path.to_s.gsub(/\.md$/, '.html')


        meta_result = @meta.analysis original
        meta = meta_result['meta'] || {}
        body = meta_result['body']

        meta['title'] = File::basename(file, '.md') if !meta['title']
        meta['publish_date'] = result['mtime'] if !meta['publish_date']

        result['meta'] = meta
        result['body_markdown'] = body

        if body
            #创建markdown实例
            markdown = Kramdown::Document.new(body)
            html = result['body_html'] = markdown.to_html

            result['excerpt'] = Nokogiri::HTML(html).text[0..99]
            #获取toc相关的内容
            result['toc_html'] = @toc.to_html markdown.to_toc
        end

        result
    end
end