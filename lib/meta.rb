#分析meta值
# http://pythonhosted.org/Markdown/extensions/meta_data.html

class Meta
    def initialize

    end

    #分析meta的部分
    def analysis_meta(original)
        return nil if not original

        result = Hash.new
        list = original.split(/\r\n/)

        # 提取meta值
        list.each{ |line|
            return if (/^(\w+):(.+)/i =~ line) == nil

            key = $1.lstrip.rstrip
            value = $2.lstrip.rstrip

            result[key] = value
        }

        result
    end

    #分析内容
    def analysis(original)
        result = Hash.new

        pattern = /(\s+)?<!\-\-(.+)\-\->(.+)?/m
        matches = pattern.match(original)

        #如果没有匹配到, 则body就是完整的original
        if matches == nil
            result['body'] = original
        end

        #获取body内容
        result['body'] = $3
        result['meta'] = self.analysis_meta $2
        result
    end
end