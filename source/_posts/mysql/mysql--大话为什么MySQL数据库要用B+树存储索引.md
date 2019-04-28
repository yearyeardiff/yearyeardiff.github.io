---
title: mysql--大话为什么MySQL数据库要用B+树存储索引
tags: [mysql, 索引]
grammar_cjkRuby: true
categories: mysql
---

>小史是一个应届生，虽然学的是电子专业，但是自己业余时间看了很多互联网与编程方面的书，一心想进 BAT 互联网公司。

![enter description here][1]

>话说两个多月前，小史通过了 A 厂的一面，两个多月后的今天，小史终于等到了 A 厂的二面。

![enter description here][2]

>在简单的自我介绍后，面试官看了看小史的简历，开始发问了。

## 面试现场

![enter description here][3]

![enter description here][4]

小史：没问题，这个项目前端用的 React+Webpack，后端用的 Nginx+Spring Boot+Redis+MySQL，前后端是分离的，最后用 Docker 进行容器化部署。主要模块有师生系统、课程系统、成绩系统、选课系统等。

![enter description here][5]

![enter description here][6]

![enter description here][7]

小史：底层 MySQL 是存储，Redis 是缓存，Dao 层操作 MySQL，Cache层操作 Redis，Service 层处理业务逻辑，Rest API 层为前端提供 Rest 接口。
前端这边用 React 进行模块化，Webpack 打包部署。网关 Nginx 进行负载均衡。MySQL、Redis、Nginx 和 Spring Boot 应用都放在 Docker 里部署。

![enter description here][8]

![enter description here][9]

![enter description here][10]

![enter description here][11]

![enter description here][12]

![enter description here][13]

![enter description here][14]

![enter description here][15]

![enter description here][16]

![enter description here][17]

![enter description here][18]

![enter description here][19]

![enter description here][20]

![enter description here][21]

**题目：为什么 MySQL 数据库要用 B+ 树存储索引？小史听到这个题目，陷入了回忆。**

![enter description here][22]

## 前段时间的饭局

话说吕老师给小史讲完人工智能的一些知识后，他们一起回家吃小史姐姐做的饭去了。

![enter description here][23]

![enter description here][24]

![enter description here][25]

![enter description here][26]

吕老师：面试的时候一定是往深了问，不精通的话容易吃亏。不过面试时一般都是根据项目来问，项目中用到的技术，一定要多看看原理，特别是能和数据结构和算法挂钩的那部分。

![enter description here][27]

![enter description here][28]

![enter description here][29]

小史：树的话，无非就是前中后序遍历、二叉树、二叉搜索树、平衡二叉树，更高级一点的有红黑树、B 树、B+ 树，还有之前你教我的字典树。

### 红黑树

![enter description here][30]

一听到红黑树，小史头都大了，开始抱怨了起来。

![enter description here][31]

小史：红黑树看过很多遍了，但是每次都记不住，它的规则实在是太多了，光定义就有四五条规则，还有插入删除的时候，需要调整树，复杂得很。

![enter description here][32]

吕老师：小史，问你红黑树，并不是让你背诵它的定义，或者让你手写一个红黑树，而是想问问你它为什么这样设计，它的使用场景有哪些。

![enter description here][33]

![enter description here][34]

![enter description here][35]

![enter description here][36]

![enter description here][37]

![enter description here][38]

![enter description here][39]

![enter description here][40]

![enter description here][41]

![enter description here][42]

![enter description here][43]

![enter description here][44]

![enter description here][45]

![enter description here][46]

![enter description here][47]

![enter description here][48]

![enter description here][49]

### B 树

![enter description here][50]

![enter description here][51]

![enter description here][52]

![enter description here][53]

![enter description here][54]

![enter description here][55]

![enter description here][56]

![enter description here][57]

![enter description here][58]

![enter description here][59]

![enter description here][60]

![enter description here][61]

![enter description here][62]

![enter description here][63]

![enter description here][64]

![enter description here][65]

![enter description here][66]

![enter description here][67]

吕老师：小史，你要知道，文件系统和数据库的索引都是存在硬盘上的，并且如果数据量大的话，不一定能一次性加载到内存中。

![enter description here][68]

两个月前，小史面试没考虑内存情况差点挂了。

![enter description here][69]

![enter description here][70]

![enter description here][71]

![enter description here][72]

![enter description here][73]

![enter description here][74]

### B+ 树

![enter description here][75]

![enter description here][76]

![enter description here][77]

![enter description here][78]

![enter description here][79]

![enter description here][80]

![enter description here][81]

吕老师：这也是和业务场景相关的，你想想，数据库中 Select 数据，不一定只选一条，很多时候会选多条，比如按照 ID 排序后选 10 条。

![enter description here][82]

小史：我明白了，如果是多条的话，B 树需要做局部的中序遍历，可能要跨层访问。

而 B+ 树由于所有数据都在叶子结点，不用跨层，同时由于有链表结构，只需要找到首尾，通过链表就能把所有数据取出来了。

![enter description here][83]

![enter description here][84]

## 回到现场

![enter description here][85]

![enter description here][86]

小史：这和业务场景有关。如果只选一个数据，那确实是 Hash 更快。但是数据库中经常会选择多条，这时候由于 B+ 树索引有序，并且又有链表相连，它的查询效率比 Hash 就快很多了。

![enter description here][87]

小史：而且数据库中的索引一般是在磁盘上，数据量大的情况可能无法一次装入内存，B+ 树的设计可以允许数据分批加载，同时树的高度较低，提高查找效率。

![enter description here][88]

HR 和小史简单地聊了聊基本情况，这次面试就结束了。小史走后，面试官在系统中写下了面试评语：

![enter description here][89]

几天后，小史收到了 A 厂的 Offer。

![enter description here][90]

![enter description here][91]


## 参考
- 转自：[为什么MySQL数据库要用B+树存储索引？](https://mp.weixin.qq.com/s/yd49Xc4pzvGnVqeptR49vA)
- [浅谈算法和数据结构: 十 平衡查找树之B树](https://www.cnblogs.com/yangecnu/p/Introduce-B-Tree-and-B-Plus-Tree.html)
- [B树与B+树简明扼要的区别](https://blog.csdn.net/zhuanzhe117/article/details/78039692)


  [1]: ./images/1554287107325.jpg "1554287107325.jpg"
  [2]: ./images/1554287160522.jpg "1554287160522.jpg"
  [3]: ./images/1554287377607.jpg "1554287377607.jpg"
  [4]: ./images/1554287389500.jpg "1554287389500.jpg"
  [5]: ./images/1554287449069.jpg "1554287449069.jpg"
  [6]: ./images/1554287455633.jpg "1554287455633.jpg"
  [7]: ./images/1554287462210.jpg "1554287462210.jpg"
  [8]: ./images/1555371643068.jpg "1555371643068.jpg"
  [9]: ./images/1555371658922.jpg "1555371658922.jpg"
  [10]: ./images/1555371682741.jpg "1555371682741.jpg"
  [11]: ./images/1555371692549.jpg "1555371692549.jpg"
  [12]: ./images/1555371717343.jpg "1555371717343.jpg"
  [13]: ./images/1555371727031.jpg "1555371727031.jpg"
  [14]: ./images/1555371735717.jpg "1555371735717.jpg"
  [15]: ./images/1555371744996.jpg "1555371744996.jpg"
  [16]: ./images/1555371757763.jpg "1555371757763.jpg"
  [17]: ./images/1555371765056.jpg "1555371765056.jpg"
  [18]: ./images/1555371774330.jpg "1555371774330.jpg"
  [19]: ./images/1555371790819.jpg "1555371790819.jpg"
  [20]: ./images/1555371798486.jpg "1555371798486.jpg"
  [21]: ./images/1555371814289.jpg "1555371814289.jpg"
  [22]: ./images/1555371843949.jpg "1555371843949.jpg"
  [23]: ./images/1555371883091.jpg "1555371883091.jpg"
  [24]: ./images/1555371895622.jpg "1555371895622.jpg"
  [25]: ./images/1555371932710.jpg "1555371932710.jpg"
  [26]: ./images/1555371945256.jpg "1555371945256.jpg"
  [27]: ./images/1555371963992.jpg "1555371963992.jpg"
  [28]: ./images/1555372008361.jpg "1555372008361.jpg"
  [29]: ./images/1555372813157.jpg "1555372813157.jpg"
  [30]: ./images/1555372844684.jpg "1555372844684.jpg"
  [31]: ./images/1555372862275.jpg "1555372862275.jpg"
  [32]: ./images/1555372878719.jpg "1555372878719.jpg"
  [33]: ./images/1555372908109.jpg "1555372908109.jpg"
  [34]: ./images/1555372915512.jpg "1555372915512.jpg"
  [35]: ./images/1555372924005.jpg "1555372924005.jpg"
  [36]: ./images/1555372931578.jpg "1555372931578.jpg"
  [37]: ./images/1555372939824.jpg "1555372939824.jpg"
  [38]: ./images/1555372948390.jpg "1555372948390.jpg"
  [39]: ./images/1555372964156.jpg "1555372964156.jpg"
  [40]: ./images/1555372973110.jpg "1555372973110.jpg"
  [41]: ./images/1555372980779.jpg "1555372980779.jpg"
  [42]: ./images/1555372989879.jpg "1555372989879.jpg"
  [43]: ./images/1555373003863.jpg "1555373003863.jpg"
  [44]: ./images/1555373012934.jpg "1555373012934.jpg"
  [45]: ./images/1555373020749.jpg "1555373020749.jpg"
  [46]: ./images/1555373031829.jpg "1555373031829.jpg"
  [47]: ./images/1555373040444.jpg "1555373040444.jpg"
  [48]: ./images/1555373052788.jpg "1555373052788.jpg"
  [49]: ./images/1555373064397.jpg "1555373064397.jpg"
  [50]: ./images/1555373086302.jpg "1555373086302.jpg"
  [51]: ./images/1555373095221.jpg "1555373095221.jpg"
  [52]: ./images/1555373104257.jpg "1555373104257.jpg"
  [53]: ./images/1555373112068.jpg "1555373112068.jpg"
  [54]: ./images/1555373120461.jpg "1555373120461.jpg"
  [55]: ./images/1555373127954.jpg "1555373127954.jpg"
  [56]: ./images/1555373137200.jpg "1555373137200.jpg"
  [57]: ./images/1555373145168.jpg "1555373145168.jpg"
  [58]: ./images/1555373153890.jpg "1555373153890.jpg"
  [59]: ./images/1555373164790.jpg "1555373164790.jpg"
  [60]: ./images/1555373186810.jpg "1555373186810.jpg"
  [61]: ./images/1555373194296.jpg "1555373194296.jpg"
  [62]: ./images/1555373202894.jpg "1555373202894.jpg"
  [63]: ./images/1555373211914.jpg "1555373211914.jpg"
  [64]: ./images/1555373219688.jpg "1555373219688.jpg"
  [65]: ./images/1555373228236.jpg "1555373228236.jpg"
  [66]: ./images/1555373240677.jpg "1555373240677.jpg"
  [67]: ./images/1555373249882.jpg "1555373249882.jpg"
  [68]: ./images/1555373275689.jpg "1555373275689.jpg"
  [69]: ./images/1555373292079.jpg "1555373292079.jpg"
  [70]: ./images/1555373307415.jpg "1555373307415.jpg"
  [71]: ./images/1555373318238.jpg "1555373318238.jpg"
  [72]: ./images/1555373354524.jpg "1555373354524.jpg"
  [73]: ./images/1555373385035.jpg "1555373385035.jpg"
  [74]: ./images/1555373394565.jpg "1555373394565.jpg"
  [75]: ./images/1555373418015.jpg "1555373418015.jpg"
  [76]: ./images/1555373426639.jpg "1555373426639.jpg"
  [77]: ./images/1555373434915.jpg "1555373434915.jpg"
  [78]: ./images/1555373443540.jpg "1555373443540.jpg"
  [79]: ./images/1555373458363.jpg "1555373458363.jpg"
  [80]: ./images/1555373470022.jpg "1555373470022.jpg"
  [81]: ./images/1555373488498.jpg "1555373488498.jpg"
  [82]: ./images/1555373507470.jpg "1555373507470.jpg"
  [83]: ./images/1555373564928.jpg "1555373564928.jpg"
  [84]: ./images/1555373574074.jpg "1555373574074.jpg"
  [85]: ./images/1555373593755.jpg "1555373593755.jpg"
  [86]: ./images/1555373603329.jpg "1555373603329.jpg"
  [87]: ./images/1555373624939.jpg "1555373624939.jpg"
  [88]: ./images/1555373679087.jpg "1555373679087.jpg"
  [89]: ./images/1555373701251.jpg "1555373701251.jpg"
  [90]: ./images/1555373715626.jpg "1555373715626.jpg"
  [91]: ./images/1555373722361.jpg "1555373722361.jpg"