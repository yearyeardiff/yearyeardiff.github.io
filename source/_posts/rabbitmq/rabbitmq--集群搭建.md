---
title: rabbitmq--集群搭建
tags: rabbitmq
grammar_cjkRuby: true
---

# 版本
- rabbitmq-server-3.7.6-1.el7
- centOS 7

# 单机集群搭建

- 为每个RabbitMQ服务节点设置不同的端口号和节点名称来启动相应服务

```
[root@localhost rabbitmq]# RABBITMQ_NODE_PORT=5672 RABBITMQ_NODENAME=rabbit1 rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
[root@localhost rabbitmq]# RABBITMQ_NODE_PORT=5673 RABBITMQ_NODENAME=rabbit2 rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
[root@localhost rabbitmq]# RABBITMQ_NODE_PORT=5674 RABBITMQ_NODENAME=rabbit3 rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
```

or


若开启了rabbitmq管理服务,执行下面的命令
```
[root@172 rabbitmq]# RABBITMQ_NODE_PORT=5672 RABBITMQ_NODENAME=rabbit1 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15672}]" rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
[root@172 rabbitmq]# RABBITMQ_NODE_PORT=5673 RABBITMQ_NODENAME=rabbit2 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15673}]" rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
[root@172 rabbitmq]# RABBITMQ_NODE_PORT=5674 RABBITMQ_NODENAME=rabbit3 RABBITMQ_SERVER_START_ARGS="-rabbitmq_management listener [{port,15674}]" rabbitmq-server -detached
Warning: PID file not written; -detached was passed.
```

- 启动各节点的服务后，将rabbit2@localhost节点加入rabbit1@localhost

```
[root@localhost rabbitmq]# rabbitmqctl -n rabbit2@localhost stop_app
Stopping rabbit application on node rabbit2@localhost ...
[root@localhost rabbitmq]# rabbitmqctl -n rabbit2@localhost reset
Resetting node rabbit2@localhost ...
[root@localhost rabbitmq]# rabbitmqctl -n rabbit2@localhost join_cluster rabbit1@localhost
Clustering node rabbit2@localhost with rabbit1@localhost
[root@localhost rabbitmq]# rabbitmqctl -n rabbit2@localhost start_app
Starting node rabbit2@localhost ...
 completed with 0 plugins.
```

- rabbit3@localhost也加入集群

```
[root@localhost rabbitmq]# rabbitmqctl -n rabbit3@localhost stop_app
Stopping rabbit application on node rabbit3@localhost ...
[root@localhost rabbitmq]# rabbitmqctl -n rabbit3@localhost reset
Resetting node rabbit3@localhost ...
[root@localhost rabbitmq]# rabbitmqctl -n rabbit3@localhost join_cluster rabbit1@localhost
Clustering node rabbit3@localhost with rabbit1@localhost
[root@localhost rabbitmq]# rabbitmqctl -n rabbit3@localhost start_app
Starting node rabbit3@localhost ...
```

- rabbitmqctl cluster_status查看各服务节点的集群状态

```
[root@localhost rabbitmq]# rabbitmqctl -n rabbit1@localhost cluster_status
Cluster status of node rabbit1@localhost ...
[{nodes,[{disc,[rabbit1@localhost,rabbit2@localhost,rabbit3@localhost]}]},
 {running_nodes,[rabbit2@localhost,rabbit3@localhost,rabbit1@localhost]},
 {cluster_name,<<"rabbit1@localhost">>},
 {partitions,[]},
 {alarms,[{rabbit2@localhost,[]},
          {rabbit3@localhost,[]},
          {rabbit1@localhost,[]}]}]
[root@localhost rabbitmq]# rabbitmqctl -n rabbit2@localhost cluster_status
Cluster status of node rabbit2@localhost ...
[{nodes,[{disc,[rabbit1@localhost,rabbit2@localhost,rabbit3@localhost]}]},
 {running_nodes,[rabbit1@localhost,rabbit3@localhost,rabbit2@localhost]},
 {cluster_name,<<"rabbit1@localhost">>},
 {partitions,[]},
 {alarms,[{rabbit1@localhost,[]},
          {rabbit3@localhost,[]},
          {rabbit2@localhost,[]}]}]
```

- 设置镜像
```
[root@172 rabbitmq]# rabbitmqctl -n rabbit1@localhost set_policy ha-all "^" '{"ha-mode":"all"}'
Setting policy "ha-all" for pattern "^" to "{"ha-mode":"all"}" with priority "0" for vhost "/" ...
[root@172 rabbitmq]# rabbitmqctl -n rabbit2@localhost set_policy ha-all "^" '{"ha-mode":"all"}'
Setting policy "ha-all" for pattern "^" to "{"ha-mode":"all"}" with priority "0" for vhost "/" ...
[root@172 rabbitmq]# rabbitmqctl -n rabbit3@localhost set_policy ha-all "^" '{"ha-mode":"all"}'
Setting policy "ha-all" for pattern "^" to "{"ha-mode":"all"}" with priority "0" for vhost "/" ...
```
## 参考文档
[mq系列rabbitmq-02集群+高可用配置](https://blog.csdn.net/liaomin416100569/article/details/78507200)
