#缓存数据, 并建立索引

require_relative './article'
require_relative './util'

class Store
    def initialize(files)
        @items_key = '__items__'
        @article = Article.new

        @data = {
            #所有文章列表
            'articles' => self.get_articles(files),
            #目录树
            'tree' => {
                @items_key => Array.new
            }
        }

        self.make_tree_index
        self.sort @data['tree']
    end

    def tree
        @data['tree']
    end

    def articles
        @data['articles']
    end

    #从节点数据中, 获取items
    def get_items(node)
        node[@items_key]
    end

    def is_items_key(key)
        key == @items_key
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

    #创建树状结构的索引
    def make_tree_index
        this = self
        @data['articles'].each{ |key, article|
            dir = File::dirname(article['relative_path'])
            relative_path_md5 = article['relative_path_md5']

            if dir == '.'
                #挂至根目录的
                @data['tree'][@items_key].push relative_path_md5
            else
                # 将文件挂至节点
                this.mount_node_to_tree dir, relative_path_md5
            end
        }
    end

    #挂到节点上, 如果不在
    def mount_node_to_tree(path, relative_path_md5)
        node = @data['tree']
        path.split('/').each{ |segment|
            current_node = node[segment]
            if not current_node
                current_node = Hash.new()
                current_node[@items_key] = Array.new
                node[segment] = current_node
            end

            node = current_node
            node[@items_key].push relative_path_md5
        }
    end

    #给所有的文件夹排序
    def sort(node)
        this = self
        node.each { | key, current |
            #items, 需要进行排序
            if key == @items_key
                #根据文章的最后修改日期进行排序
                current.sort! {|left, right|
                    left_article = @data['articles'][left]
                    right_article = @data['articles'][right]
                    left_article['mtime'] <=> right_article['mtime']
                }
            else
                #递归调用进行排序
                this.sort(current)
            end
        }
    end
end