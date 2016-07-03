# -*- coding: utf-8 -*-

#缓存数据, 并建立索引

require_relative './article'
require_relative './util'

class Store
    def initialize(files)
        #直接子级的key
        @children_key = '__children__'
        #所有后代的key
        @posterity_key = '__posterity__'
        #所有文章
        @article = Article.new

        @data = {
            #首页
            'home' => nil,
            #完整的分类
            'categories' => [],
            #所有文章列表
            'articles' => self.get_articles(files),
            #目录树
            'tree' => {
                @children_key => []
            }
        }

        self.make_tree
        self.sort @data['tree']
    end

    #获取所有的分类
    def categories
        return @data['categories']
    end

    #获取
    def tree
        @data['tree']
    end

    def articles
        @data['articles']
    end

    #从节点数据中, 获取items
    def get_children(node = @data['tree'])
        node[@children_key]
    end

    def is_children_key(key)
        key == @children_key
    end

    #获取所有的文章列表
    #以hash的方式保存, key即是文件路径的md5值
    def get_articles(files)
        result = Hash.new

        files.each { | file |
            article = @article.convert(file)
            key = article['relative_path_md5']
            result[key] = article;
        }

        result
    end

    #创建树状结构的索引, 以及分类
    def make_tree
        this = self
        @data['articles'].each{ |key, article|
            dir = File::dirname(article['relative_path'])
            relative_path_md5 = article['relative_path_md5']
            this.mount_node_to_index dir, relative_path_md5
            this.mount_node_to_categories dir, relative_path_md5
        }
    end

    #当前的路径挂到正确的路径上
    def mount_node_to_tree(root, url, children_key, callback)
        #根目录下的， 直接挂上去
        return callback.call root, nil, 0, 0 if url == '.'

        node = root
        #将路径分成段， 如果没存在这个节点， 则创建
        index = 1
        segments = url.split('/')
        segments.each{ |segment|
            node = callback.call node, segment, index, segments.length
            index = index + 1
        }
    end

    #将节点挂到索引上
    def mount_node_to_index(url, relative_path_md5)
        key = @children_key
        #回调的处理
        callback = lambda { |node, segment, index, total|
            #根节点， 直接插入到items中
            if segment == nil
                node[@children_key].push relative_path_md5
                return node
            end

            #如果没有找到， 则创建新的节点
            current_node = node[segment]
            if not current_node
                current_node = Hash.new()
                current_node[key] = Array.new
                node[segment] = current_node
            end

            current_node[key].push relative_path_md5
            return current_node
        }

        self.mount_node_to_tree @data['tree'], url, @children_key, callback
    end

    #将节点挂到分类下
    def mount_node_to_categories(url, relative_path_md5)
        #回调的处理
        callback = lambda { |parent, segment, index, total|
            if segment != nil
                node = self.get_categories_node_children parent, segment
                #还不是最后一个节点
                return node if index < total
            else
                node = parent
            end

            #获取文章的信息
            article = @data['articles'][relative_path_md5]
            meta = article['meta']

            #分类中的文章
            item = {
                'title' => meta['title'],
                'relative_url' => article['relative_url']
            }

            if segment == nil
                node.push item
                return node
            end

            #还没有这个键
            node[@children_key] = [] if node[@children_key] == nil
            node[@children_key].push item
            return node
        }

        self.mount_node_to_tree @data['categories'], url, @children_key, callback
    end    

    #从数组的分类中，获取节点， 如果节点不存在， 则创建一个
    def get_categories_node_children(parent, segment)
        parent.each { | current |
            return current if current['title'] == segment
        }

        #如果没有找到， 则创建一个
        node = {
            'title' => segment,
            @children_key => []
        }

        parent.push node
        node
    end

    #挂到节点上, 如果不在则创建
    # def mount_node_to_tree(path, relative_path_md5)
    #     node = @data['tree']


    #     #根目录下的
    #     if path == '.'
    #         node[@children_key].push relative_path_md5
    #         return
    #     end

    #     path.split('/').each{ |segment|
    #         current_node = node[segment]
    #         if not current_node
    #             current_node = Hash.new()
    #             current_node[@children_key] = Array.new
    #             node[segment] = current_node
    #         end

    #         node = current_node
    #         node[@children_key].push relative_path_md5

    #         #所有的子级，都要向root插入数据
    #         @data['tree'][@children_key].push relative_path_md5
    #     }
    # end


    #给所有的文件夹排序
    def sort(node)
        this = self
        node.each { | key, current |
            #items, 需要进行排序
            if key == @children_key
                #根据文章的最后修改日期进行排序
                current.sort! {|left, right|
                    left_article = @data['articles'][left]
                    right_article = @data['articles'][right]
                    right_article['mtime'] <=> left_article['mtime']
                }
            else
                #递归调用进行排序
                this.sort(current)
            end
        }
    end
end