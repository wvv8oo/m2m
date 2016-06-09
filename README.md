# m2m

> Markdown to More

将Markdown转换为其它格式的内容，如一个博客，一个网站，或者是一封邮件

它还能将你的博客或网站自动提交到git，或者发布到你的服务器上。也可以通过简单的命令将最近的Markdown作为邮件发送，并将邮件中的图片插入到邮件中。

## 如何安装

* 请确认你的电脑上已经安装了`ruby`环境，`Mac OSX`系统已经自带`Ruby`环境，Windows系统，请移步Ruby官方网站进行安装：https://www.ruby-lang.org/zh_cn/downloads/
* 打开命令行，执行`sudo gem install m2m`即可安装

## 配置文件

在你要生成的文件目录，创建一个`m2m.config`的文件，`m2m.config`是一个JSON格式的文件，格式如下：


	{
	  "blog":{
	    "title": "m2m官方博客",
	    "host": "https://github.com/wvv8oo/m2m/"
	  },
	  "theme": "hyde",
	  "target": "./site"
	}

* `blog.title`：博客的标题
* `blog.host`：博客的网址
* `theme`：主题，目前仅提供一个主题
* `target`：生成的目的目录，如果不设置，则会生成到`~/.m2m/[project_name]`

**很快m2m将会提供自动生成配置文件的功能**

## 命令介绍

### m2m build

将当前目录下的markdown生成博客，也可以使用别名`m2m`，`m2m build`提供多个参数：

* `m2m --target`或`m2m -t`：指定生成的目标
* `m2m --source`或`m2m -s`：指定工作目录，默认为当前目录

### m2m mail

m2m提供将最近改动的markdown发送到指定邮箱的功能，也可以指定发送某个Markdown文件，此功能提供给需要写周报的同学使用，你懂的。

你需要在`m2m.config`文件中增加如下配置：


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
* 给个邮件标题的设置例子吧：`部门-姓名(花名) $last_week ~ $now`

`m2m mail`蛮多个参数：

* `--subject`或`-s`：指定邮件主题，优先级高于`m2m.config`的设置
* `--markdown`或`-m`：指定相对于当前目录的markdown文件，适用于要发送指定的markdown文件，如果不指定，则会发送最近修改的markdown文件
* `--slient`：静默发送，如果指定了此参数，将不会让用户确认直接发送
* `--addressee`或`-a`：指定发件人，优先级高于`m2m.config`的设置

### 邮件件发收件人

你有三个地方可以配置邮件主题与收件人，优先级为：`markdown文件>命令行参数指定>m2m.config文件`

在markdown文件中，你可以通过写入meta的方式来指定邮件主题以及收件人，书写的方式如下：

	<!--
	subject: 我指定的邮件主题，也可以使用$last_week和$now两个变量
	addressee: mail@example.com,other@example.com
	-->
	这是你的markdown文件内容

### m2m pdf(暂未提供)

m2m允许将指定的Markdown文件生成pdf
