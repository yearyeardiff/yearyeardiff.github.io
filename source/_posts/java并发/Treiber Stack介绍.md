---
title: Treiber Stack
tags: [java,java并发,Treiber Stack]
categories: java并发
grammar_cjkRuby: true


---

## 简介

Treiber Stack在 R. Kent Treiber在1986年的论文[Systems Programming: Coping with Parallelism](https://domino.research.ibm.com/library/cyberdig.nsf/papers/58319A2ED2B1078985257003004617EF/$File/rj5118.pdf)中首次出现。它是一种无锁并发栈，其无锁的特性是基于CAS原子操作实现的。

## 实现

下面给出的Java语言实现为《Java并发编程实战》一书的15.4.1小结中的实现。Treiber Stack的实现套路很简单，就是CAS+重试，不需要任何注释就能轻松的看懂代码。

```java
@ThreadSafe
public class ConcurrentStack <E> {
    AtomicReference<Node<E>> top = new AtomicReference<Node<E>>();

    public void push(E item) {
        Node<E> newHead = new Node<E>(item);
        Node<E> oldHead;
        do {
            oldHead = top.get();
            newHead.next = oldHead;
        } while (!top.compareAndSet(oldHead, newHead));
    }

    public E pop() {
        Node<E> oldHead;
        Node<E> newHead;
        do {
            oldHead = top.get();
            if (oldHead == null)
                return null;
            newHead = oldHead.next;
        } while (!top.compareAndSet(oldHead, newHead));
        return oldHead.item;
    }

    private static class Node <E> {
        public final E item;
        public Node<E> next;

        public Node(E item) {
            this.item = item;
        }
    }
}
```

## JDK中的使用

JDK中的FutureTask使用了Treiber Stack。FutureTask用了Treiber Stack来维护等待任务完成的线程，在FutureTask的任务完成/取消/异常后在finishCompletion钩子方法中会唤醒栈中等待的线程。

## 参考

- 原文：[Treiber Stack介绍](https://www.cnblogs.com/micrari/p/7719408.html)
- 《Java并发编程实战》
- [Treiber Stack](https://en.wikipedia.org/wiki/Treiber_Stack)