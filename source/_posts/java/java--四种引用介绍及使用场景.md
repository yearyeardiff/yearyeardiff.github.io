---
title: java--四种引用介绍及使用场景
tags: [java, gc]
categories: java
grammar_cjkRuby: true
---

# Java中的四种引用类型（强、软、弱、虚）

## 为什么需要不同的引用类型

从Java1.2开始，JVM开发团队发现，单一的强引用类型，无法很好的管理对象在JVM里面的生命周期，垃圾回收策略过于简单，无法适用绝大多数场景。为了更好的管理对象的内存，更好的进行垃圾回收，JVM团队扩展了引用类型，从最早的强引用类型增加到**强、软、弱、虚**四个引用类型。

## 引用类图

![enter description here][1]

StrongRerence为JVM内部实现。其他三类引用类型全部继承自Reference父类。

## 强引用（StrongReference）

最常用到的引用类型，StrongRerence这个类并不存在，而是在JVM底层实现。默认的对象都是强引用类型，继承自Rerence、SoftReference、WeakReference、PhantomReference的引用类型非强引用。

最简单的强引用示例:

```
String str = "Misout的博客";

```

强引用类型，如果JVM垃圾回收器GC Roots可达性分析结果为可达，表示引用类型仍然被引用着，这类对象始终不会被垃圾回收器回收，即使JVM发生OOM也不会回收。而如果GC Roots的可达性分析结果为不可达，那么在GC时会被回收。

## 软引用（SoftReference）

软引用是一种比强引用生命周期稍弱的一种引用类型。在JVM内存充足的情况下，软引用并不会被垃圾回收器回收，只有在JVM内存不足的情况下，才会被垃圾回收器回收（严谨的说法是，GC 根据内存使用情况酌情考虑什么时候回收）。所以软引用的这种特性，一般用来实现一些内存敏感的缓存，只要内存空间足够，对象就会保持不被回收掉，比如网页缓存、图片缓存等。

**软引用使用示例**

``` java
SoftReference<String> softReference = new SoftReference<String>(new String("Misout的博客"));
System.out.println(softReference.get());

```

当软引用在 OutOfMemory 之前被回收后，软引用变量不再有存在的价值，但是他们本身还是强引用，太多的软引用变量同样会导致 OutOfMemory 问题。其实，我们可以在创建软引用变量时，指定一个 ReferenceQueue，当软引用变量不再有存在的价值时，会被插入到队列中，我们可以利用此队列回收这些软引用变量。

``` java
Set<SoftReference<MyObject>> cache = new HashSet<>();
cache.add(new SoftReference(aStrongRef, queue));
//...
Reference<? extends MyObject> ref = queue.poll();
while (ref != null) {
    if (cache.remove(ref)) {
        removedSoftRefs++;
    }
    ref = queue.poll();
}
```
软引用可以被用于缓存对象，尤其那些重新实例化的开销很大的对象。

## 弱引用（WeakReference）

弱引用是一种比软引用生命周期更短的引用。他的生命周期很短，不论当前内存是否充足，都只能存活到下一次垃圾收集之前。
**来让我们看一个示例**

```
WeakReference<String> weakReference = new WeakReference<String>(new String("Misout的博客"));
System.gc();
if(weakReference.get() == null) {
    System.out.println("weakReference已经被GC回收");
}

```

输出结果：

```
weakReference已经被GC回收

```

在强度上弱于软引用，通过类WeakReference来表示。它的作用是引用一个对象，但是并不阻止该对象被回收。如果使用一个强引用的话，只要该引用存在，那么被引用的对象是不能被回收的。弱引用则没有这个问题。在垃圾回收器运行的时候，如果一个对象的所有引用都是弱引用的话，该对象会被回收。弱引用的作用在于解决强引用所带来的对象之间在存活时间上的耦合关系。弱引用最常见的用处是在集合类中，尤其在哈希表中。哈希表的接口允许使用任何Java对象作为键来使用。当一个键值对被放入到哈希表中之后，哈希表对象本身就有了对这些键和值对象的引用。如果这种引用是强引用的话，那么只要哈希表对象本身还存活，其中所包含的键和值对象是不会被回收的。如果某个存活时间很长的哈希表中包含的键值对很多，最终就有可能消耗掉JVM中全部的内存。

　　对于这种情况的解决办法就是使用弱引用来引用这些对象，这样哈希表中的键和值对象都能被垃圾回收。Java中提供了WeakHashMap来满足这一常见需求。
详细用法：[十分钟理解Java中的弱引用](http://www.importnew.com/21206.html)

## 虚引用（PhantomReference）

虚引用与前面的几种都不一样，这种引用类型不会影响对象的生命周期，所持有的引用就跟没持有一样，随时都能被GC回收。需要注意的是，在使用虚引用时，必须和引用队列关联使用。在对象的垃圾回收过程中，如果GC发现一个对象还存在虚引用，则会把这个虚引用加入到与之关联的引用队列中。程序可以通过判断引用队列中是否已经加入了虚引用，来了解被引用的对象是否将要被垃圾回收。如果程序发现某个虚引用已经被加入到引用队列，那么就可以在所引用的对象内存被回收之前采取必要的行动防止被回收。虚引用主要用来跟踪对象被垃圾回收器回收的活动。
**示例**

```
PhantomReference<String> phantomReference = new PhantomReference<String>(new String("Misout的博客"), new ReferenceQueue<String>());
System.out.println(phantomReference.get());

```

运行后，发现结果总是null，引用跟没有持有差不多。
## 引用队列
　　在很多场景中，我们的程序需要在一个对象的可达性（GC可达性，判断对象是否需要回收）发生变化的时候得到通知，引用队列就是用于收集这些信息的队列。比如某个对象的强引用都已经不存在了，只剩下软引用或是弱引用。但是还需要对引用本身做一些的处理。典型的情景是在哈希表中。引用对象是作为WeakHashMap中的键对象的，当其引用的实际对象被垃圾回收之后，就需要把该键值对从哈希表中删除。有了引用队列（ReferenceQueue），就可以方便的获取到这些弱引用对象，将它们从表中删除。在软引用和弱引用对象被添加到队列之前，其对实际对象的引用会被自动清空（**当软/弱/虚引用变量不再有存在的价值时，会被插入到队列中，我们可以利用此队列回收这些引用变量**。）。通过引用队列的poll/remove方法就可以分别以非阻塞和阻塞的方式获取队列中的引用对象。
  
  ![enter description here][2]
  
案例如下：
``` java
public class WeakCache {
 
    private void printReferenceQueue(ReferenceQueue<Object> referenceQueue) {
        WeakEntry sv;
        while ((sv = (WeakEntry) referenceQueue.poll()) != null) {
            System.out.println("引用队列中元素的key：" + sv.key);
        }
    }
 
    private static class WeakEntry extends WeakReference<Object> {
        private Object key;
 
        WeakEntry(Object key, Object value, ReferenceQueue<Object> referenceQueue) {
            //调用父类的构造函数，并传入需要进行关联的引用队列
            super(value, referenceQueue);
            this.key = key;
        }
    }
 
    public static void main(String[] args) {
        ReferenceQueue<Object> referenceQueue = new ReferenceQueue<>();
        User user = new User("xuliugen", "123456");
        WeakCache.WeakEntry weakEntry = new WeakCache.WeakEntry("654321", user, referenceQueue);
        System.out.println("还没被回收之前的数据：" + weakEntry.get());
 
        user = null;
        System.gc(); //强制执行GC
        System.runFinalization();
 
        System.out.println("已经被回收之后的数据：" + weakEntry.get());
        new WeakCache().printReferenceQueue(referenceQueue);
    }
}
```

![enter description here][3]
  
其实，上述的代码，是从MyBatis的源码中抽离出来的，MyBatis在缓存的时候也提供了对弱引用和软引用的支持，MyBatis相关的源码如下：

![enter description here][4]

## 总结

| 类型 | 回收时间 | 使用场景 |
| --- | --- | --- |
| 强引用 | 一直存活，除非GC Roots不可达 | 所有程序的场景，基本对象，自定义对象等。 |
| 软引用 | 内存不足时会被回收 | 一般用在对内存非常敏感的资源上，用作缓存的场景比较多，例如：网页缓存、图片缓存 |
| 弱引用 | 只能存活到下一次GC前 | 生命周期很短的对象，例如ThreadLocal中的Key。 |
| 虚引用 | 随时会被回收， 创建了可能很快就会被回收 | 业界暂无使用场景， 可能被JVM团队内部用来跟踪JVM的垃圾回收活动 |

# 参考
1. [Java中的四种引用类型（强、软、弱、虚）](https://www.jianshu.com/p/ca6cbc246d20)
2. [java中四种引用类型](https://www.cnblogs.com/mjorcen/p/3968018.html)
3. [Java 四种引用介绍及使用场景](https://blog.csdn.net/u014532217/article/details/79184412)


  [1]: ./images/1553051826254.jpg "1553051826254.jpg"
  [2]: ./images/1553240699293.jpg "1553240699293.jpg"
  [3]: ./images/1553240745739.jpg "1553240745739.jpg"
  [4]: ./images/1553240780076.jpg "1553240780076.jpg"