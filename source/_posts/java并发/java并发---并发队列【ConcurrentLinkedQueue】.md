---
title: java并发---并发队列【ConcurrentLinkedQueue】
tags: [java,java并发,并发队列,ConcurrentLinkedQueue]
categories: java并发
grammar_cjkRuby: true

---

## 1.简介

ConcurrentLinkedQueue是JUC中的基于链表的无锁队列实现。本文将解读其源码实现。

## 2. 论文

ConcurrentLinkedQueue的实现是以Maged M. Michael和Michael L. Scott的论文[Simple, Fast, and Practical Non-Blocking and Blocking Concurrent Queue Algorithms](http://www.cs.rochester.edu/~scott/papers/1996_PODC_queues.pdf)为原型进行改造的，不妨阅读此篇论文。

## 3. ConcurrentLinkedQueue的实现

### 3.1 数据结构

正如典型的队列设计，内部的节点用如下的Node类表示

```java
/**
 * 仅展示属性，其余略去。
 */
private static class Node<E> {
    volatile E item;
    volatile Node<E> next;
}
```

值得一提的是Node中有一个lazySetNext方法

```java
void lazySetNext(Node<E> val) {
    UNSAFE.putOrderedObject(this, nextOffset, val);
}
```

与AtomicReference类一样，使用了UNSAFE.putOrderedObject方法来实现低延迟的写入。这个方法会插入Store-Store内存屏障，也就是保证写操作不会重排。而不会插入普通volatile写会插入的Store-Load屏障。

ConcurrentLinkedQueue在构造时会初始化head和tail为一个item为null的节点，作为哨兵节点。

```
private transient volatile Node<E> head;

private transient volatile Node<E> tail;
```

### 3.2 设计思想

ConcurrentLinkedQueue的源码还是有些晦涩难懂的，但是doc非常详细，对阅读源码非常有帮助。如果带着从doc中介绍的设计与实现思路去读源码会轻松不少。

ConcurrentLinkedQueue是不允许向其插入空的item的，对于删除元素，会将其item给CAS为null，一旦某个元素的item变为null，就意味着它不再是队列中的有效元素了，并且会将已删除节点的next指针指向自身。
这样可以实现尽可能快地从已删除的元素跳过后面删除的元素，回到队列中。

ConcurrentLinkedQueue具有以下这些性质：

- 队列中任意时刻只有最后一个元素的next为null
- head和tail不会是null（哨兵节点的设计）
- head未必是队列中第一个元素（head指向的可能是一个已经被移除的元素）
- 队列中的有效元素都可以从head通过succ方法遍历到
- tail未必是队列中最后一个元素（tail.next可以不为null）
- 队列中的最后一个元素可以从tail通过succ方法遍历到
- tail甚至可以是head的前驱

这里提到了succ方法，那么先睹为快，看一下succ方法吧。

```java
final Node<E> succ(Node<E> p) {
    Node<E> next = p.next;
    // 如果next就是自身（代表已经不在队列中），则返回head，否则返回next。
    return (p == next) ? head : next;
}
```

因为ConcurrentLinkedQueue中的head和tail都可能会滞后，这其实是一种避免频繁CAS的优化。当然过度的滞后也是会影响操作效率的，所以在具体实现的时候，会尽可能能有机会更新head和tail就去更新它们。

### 3.3 源码解读

#### 3.3.1 offer方法

```java
public boolean offer(E e) {
    checkNotNull(e);
    final Node<E> newNode = new Node<E>(e);

    for (Node<E> t = tail, p = t;;) {
        Node<E> q = p.next;
        // 如果p的next为null，则说明此刻p为队列中最后一个元素。
        if (q == null) {
            /*
             * cas成功则newNode成功入队，只是此刻tail还是老的。
             * 否则说明因为线程竞争的关系没有成功入队，需要重试。
             */
            if (p.casNext(null, newNode)) {
                /*
                 * t是当前线程读到的tail快照，p是上面CAS时队列中最后一个元素。
                 * 这两者不一致说明该更新tail了。
                 * 如果CAS失败则说明tail已经被其它线程更新过了，这没关系。
                 */
                if (p != t) 
                    casTail(t, newNode);
                return true;
            }
        }
        /*
         * ConcurrentLinkedQueue的一个设计就是对于已经移除的元素，
         * 会将next置为本身，用于判断当前元素已经出队，接着从head继续遍历(可以看succ方法)。
         *
         * 在整个offer方法的执行过程中，p一定是等于t或者在t的后面的，
         * 因此如果p已经不在队列中的话，t也一定不在队列中了。
         *
         * 所以重新读取一次tail到快照t，
         * 如果t未发生变化，就从head开始继续下去。
         * 否则让p从新的t开始继续尝试入队是一个更好的选择(此时新的t很可能在head后面)
         */
        else if (p == q)
            p = (t != (t = tail)) ? t : head;
        else
            /*
             * 如果p与t相等，则让p继续向后移动一个节点。
             *
             * 如果p和t不相等，则说明已经经历至少两轮循环(仍然没有入队)，
             * 则重新读取一次tail到t，如果t发生了变化，则从t开始再次尝试入队。
             */
            p = (p != t && t != (t = tail)) ? t : q;
    }
}
```

#### 3.3.2 poll方法

```java
public E poll() {
restartFromHead:
    for (;;) {
        // p初始设置为head。
        for (Node<E> h = head, p = h, q;;) {
            E item = p.item;

            /* 
             * 成功将item给CAS为null则说明成功移除了元素。
             * 这里的item != null判断也是为了尽可能避免无意义的CAS。
             */
            if (item != null && p.casItem(item, null)) {
                /*
                 * p如果与h不相等，则说明head很可能滞后,指向已不在队列中的元素。
                 * 如果此时p有后继，则更新head为p.next，
                 * 否则尽管p已经被移除出去了,也只能更新head为p了。
                 */
                if (p != h)
                    updateHead(h, ((q = p.next) != null) ? q : p);
                return item;
            }
            /*
             * 如果没能成功移除p，且p也没有后继，则说明p为此时队列的最后元素。
             * 所以更新head为p并返回null。
             *
             * 注意这里h和p是可能相等的，updateHead会判断h和p是否相等以避免无意义CAS。
             */
            else if ((q = p.next) == null) {
                updateHead(h, p);
                return null;
            }
            /*
             * p存在后继，需要检查是否p还在队列中。
             * 如果p已经不在队列中(p==q)，则重新读一次head到快照h并让p从h开始再尝试移除元素。
             * 
             * 因为一定有其它线程已经通过updateHead将head从p给CAS为新的head并且令p节点的next指向p自己，
             * 这时再一步步往后面走显然不值得，不如从现在的head开始重新来过。
             */
            else if (p == q)
                continue restartFromHead;
            // 继续向后走一个节点尝试移除元素。
            else
                p = q;
        }
    }
}

final void updateHead(Node<E> h, Node<E> p) {
    if (h != p && casHead(h, p))
        h.lazySetNext(h);
}
```

#### 3.3.3 peek方法

```java
public E peek() {
restartFromHead:
    for (;;) {
        for (Node<E> h = head, p = h, q;;) {
            E item = p.item;
            // 其实这里的if就是将poll中的if前两个分支做了个合并。
            if (item != null || (q = p.next) == null) {
                updateHead(h, p);
                return item;
            }
            else if (p == q)
                continue restartFromHead;
            else
                p = q;
        }
    }
}
```

#### 3.3.4 remove方法

```java
public boolean remove(Object o) {
    if (o != null) {
        Node<E> next, pred = null;
        // p为当前节点，pred为p前驱，next为后继。
        for (Node<E> p = first(); p != null; pred = p, p = next) {
            boolean removed = false;
            E item = p.item;
            // item为null代表元素已经无效（认为不在队列中）
            if (item != null) {
                // 不是要删除的元素。
                if (!o.equals(item)) {
                    next = succ(p);
                    continue;
                }
                removed = p.casItem(item, null);
            }

            next = succ(p);
            if (pred != null && next != null)
                // 前驱与后继连上。
                pred.casNext(p, next);
            if (removed)
                return true;
        }
    }
    return false;
}
```

#### 3.3.5 size方法

```java
/**
 * size方法效率其实挺差的，是一个O(n)的遍历。
 */
public int size() {
    int count = 0;
    for (Node<E> p = first(); p != null; p = succ(p))
        if (p.item != null)
            // 最多只返回Integer.MAX_VALUE
            if (++count == Integer.MAX_VALUE)
                break;
    return count;
}


/**
 * 这个方法和poll/peek方法差不多，只不过返回的是Node而不是元素。
 * 
 * 之所以peek方法没有复用first方法的原因有2点
 * 1. 会增加一次volatile读
 * 2. 有可能会因为和poll方法的竞争，导致出现非期望的结果。
 *    比如first返回的node非null，里面的item也不是null。
 *    但是等到poll方法返回从first方法拿到的node的item的时候，item已经被poll方法CAS为null了。
 *    那这个问题只能再peek中增加重试，这未免代价太高了。
 *
 * 这就是first和peek代码没有复用的原因。
 */
Node<E> first() {
restartFromHead:
    for (;;) {
        for (Node<E> h = head, p = h, q;;) {
            boolean hasItem = (p.item != null);
            if (hasItem || (q = p.next) == null) {
                updateHead(h, p);
                return hasItem ? p : null;
            }
            else if (p == q)
                continue restartFromHead;
            else
                p = q;
        }
    }
}
```

