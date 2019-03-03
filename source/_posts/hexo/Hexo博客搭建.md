---
title: Hexo博客搭建
tags: hexo
categories: hexo
grammar_cjkRuby: true
---

# 搭建

- [GitHub+Hexo搭建个人博客（一）GitHub新建一个blog项目](https://www.jianshu.com/p/3fc5869ab62d)
[GitHub+Hexo搭建个人博客（二）配置Hexo博客基础框架](https://www.jianshu.com/p/8fcacc55e5fb)
- [使用Hexo+Github一步步搭建属于自己的博客（基础）](https://www.cnblogs.com/fengxiongZz/p/7707219.html)
[使用Hexo+Github一步步搭建属于自己的博客（进阶）](https://www.cnblogs.com/fengxiongZz/p/7707568.html)

- 个性化配置
 [GitHub+Hexo搭建个人博客（三）Hexo个性化配置进阶](https://www.jianshu.com/p/01ebebc1d063)
 [hexo定制&优化](https://www.jianshu.com/p/3884e5cb63e5)
 

# 解决的问题

## 插入图片

- 使用本地路径：在hexo/source目录下新建一个images文件夹，将图片放入该文件夹下，插入图片时链接即为/images/图片名称。 
- 使用微博图床，地址http://weibotuchuang.sinaapp.com/，将图片拖入区域中，会生成图片的URL，这就是链接地址。

## 本地路径

使用本地路径的方法要求图片的路径必须是绝对路径。可是，当图片比较多的时候不容易管理。而且，对于我自己而言，我习惯使用相对路径，如下：

![enter description here][1]

这是我在用hexo之前就养成的习惯。同时，我的很多博客都使用的相对路径，不可能把每个图片的引用改一遍。为了解决这个问题，只有另辟蹊径了。

stop1：
利用shell脚本，把图片都拷贝到source/images下面：
``` shell
#!/bin/bash


# 字符串是否匹配正则
# 1 否；0 是
function is_string_match_regular(){
    str=$(echo $1 | grep -ioE $2)
    if test -z "$str"
    then
        return 1
    else
        return 0
    fi
}

# 拷贝图片
function getdir(){
    for element in `ls $1`
    do  
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ];then

            is_string_match_regular "$dir_or_file" '.*\bimages$'

            if test 0 -eq $?;then
                echo "copy images : [$dir_or_file] ---> [$direction_dir]"
                cp -r "$dir_or_file/" "$direction_dir" 
            else
                getdir $dir_or_file
            fi    
        fi  
    done
}
root_dir="source/_posts"
direction_dir="source/images"
getdir $root_dir
```
脚本放在hexo的根目录下，如下：

![enter description here][2]

在每次执行`hexo g`前执行shell脚本`sh copy_images.sh `


stop2:
使用[hexo-change-img-url插件](https://github.com/yearyeardiff/hexo-change-img-url)插件，在执行`hexo g`的时候会自动地把html中的相对路径改成绝对路径。如下：
``` xml
<img src="./imags/hh.jpg"></img>

变成

<img src="/images/hh.jpg"></img>

```

ps: hexo-change-img-url插件只支持这种使用方式![enter description here][1]（第一次写插件，谅解 :)）。



## 首页预览

[Hexo之next主题设置首页不显示全文(只显示预览)](https://www.jianshu.com/p/393d067dba8d)

## 添加站内搜索
- [Hexo博客添加站内搜索](https://www.ezlippi.com/blog/2017/02/hexo-search.html)
- [Hexo 博客无法搜索的解决方法](https://www.jianshu.com/p/02afabcae502)

## 生成sitemap站点地图

[hexo(3)-生成sitemap站点地图](https://www.jianshu.com/p/9c2d6db2f855)
[解决github pages屏蔽百度爬虫的问题](https://www.jianshu.com/p/3884e5cb63e5)

## 使用cnzz统计网站访问量

[使用cnzz统计网站访问量](https://www.jianshu.com/p/5b72aa71d6e4)
[不蒜子计数](https://www.jianshu.com/p/c311d31265e0)

## 加上评论系统

[为你的Hexo加上评论系统-Valine](https://blog.csdn.net/blue_zy/article/details/79071414)

## 置顶

[Hexo增加置顶属性](https://blog.csdn.net/adobeid/article/details/82704982)

## RSS
[GitHub+Hexo搭建个人博客（四）Hexo高阶之第三方插件](https://www.jianshu.com/p/dda25ffcfd43)


  [1]: ./images/1551530441279.jpg "1551530441279.jpg"
  [2]: ./images/1551531164567.jpg "1551531164567.jpg"