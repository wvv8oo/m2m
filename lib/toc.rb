#读取文件内容

require 'kramdown'

class TOC
    DISPATCHER = Hash.new {|h,k| h[k] = "convert_#{k}"}

    include ::Kramdown::Utils::Html
    include ::Kramdown::Parser::Html::Constants

    def convert_children(element, index)
        result = ""
        index += 2
        element.children.each do |inner_element|
            result += send(DISPATCHER[inner_element.type], inner_element, index)
        end
        result
    end

    def convert_text(element, index)
        escape_html(element.value, :text)
    end

    def convert_toc(element, index)
        # result = Hash.new
        # result['href'] = element.attr[:id]
        # result['title'] = element.value.children.first.value
        #
        # if (element.children.length > 1)
        #     result['items'] = self.inner(element, ind)
        # end

        # return result

        title = element.value.children.first.value
        result = (" " * index)  + "<li><a href=\"##{element.attr[:id]}\">#{title}</a>"
        if (element.children.length > 1)
            result += "\n<ul>\n"
            result += "#{self.convert_children(element, index)}"
            result += (" " * index) + "</ul>"
        end

        result += "</li>\n"
        result
    end

    #转换文件
    def to_html(element)
        return nil if element.children.length == 0
        result = "<ul class='toc'>"
        result += self.convert_children(element, 0)
        result += "</ul>"
        result
    end
end