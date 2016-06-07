# m2b

将Markdown转换为博客的工具，也可以将Markdown作为邮件发送

## 如何安装

* 请确认你的电脑上已经安装了`ruby`环境，`Mac OSX`系统已经自带`Ruby`环境，Windows系统，请移步Ruby官方网站进行安装：https://www.ruby-lang.org/zh_cn/downloads/
* 打开命令行，执行`sudo gem install m2b`即可安装

## 配置文件

在你要生成的文件目录，创建一个`m2b.config`的文件，`m2b.config`是一个JSON格式的文件，格式如下：


	{
	  "blog":{
	    "title": "M2B官方博客",
	    "host": "https://github.com/wvv8oo/m2b/"
	  },
	  "theme": "hyde",
	  "target": "./site"
	}

* `blog.title`：博客的标题
* `blog.host`：博客的网址
* `theme`：主题，目前仅提供一个主题
* `target`：生成的目的目录，如果不设置，则会生成到`~/.m2b/[project_name]`

** 很快m2b将会提供自动生成配置文件的功能 **

## 命令介绍

### m2b build

将当前目录下的markdown生成博客，也可以使用别名`m2b`，`m2b build`提供多个参数：

* `m2b --target`或`m2b -t`：指定生成的目标
* `m2b --source`或`m2b -s`：指定工作目录，默认为当前目录

### m2b mail

m2b提供将最近改动的markdown发送到指定邮箱的功能，也可以指定发送某个Markdown文件，此功能提供给需要写周报的同学使用，你懂的。

你需要在`m2b.config`文件中增加如下配置：


	"mail": {
	  	"smtp": "SMTP的地址",
	    "port": "端口，一般是25",
	    "account": "你的帐号",
	    "password": "密码",
	    "ssl": false,
	    "from": "发件人",
	    "to": "收件人，多个以逗号为分隔",
	    "format": "%Y-%m-%d",
	    "subject": "邮件标题"
	}

* 发件人可以用`姓名 <yourname@email.com>`这种格式，注意姓名与邮件地址中间的空格，否则会造成发不出邮件的情况
* 邮件标题中，可以添加`$last_week`(上周)与`$now`(今天)两个占位符，发邮件时会自动替换
* `format`是邮件标题中时间占位符的格式化字符，默认为`%Y-%m-%d`，生成结果参考：`2016-06-04`

### m2b pdf(暂未提供)

M2b允许将指定的Markdown文件生成pdf
