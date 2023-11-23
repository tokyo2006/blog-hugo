---
date: 2017-07-30
title: "搭建Nomad服务与Consul集成"
description: "本文主要描述如何搭建Nomad服务，以及如何与Consul集成"
Section: post
Slug: 搭建Nomad服务与Consul集成
Topics:
 - Nomad
 - Devops
 - Consul
Tags:
 - Nomad
 - Devops
 - Consul
---


    Nomad是HashCorp的一款开源的编排工具,同样身为HashCorp的服务发现工具consul能够很好的与Nomad进行集成，2个轻量级别的工具可以很好的支持微服务的快速发布。这里会简单的说一下nomad的集群以及consul集群的集成

  <!--more-->
  <figure class="half">
    <img src="https://cdn.rawgit.com/hashicorp/nomad/master/website/source/assets/images/logo-text.svg" width="300">
    <img src="https://res.cloudinary.com/xinta/image/upload/v1523925276/blogimage/consul_1.png" width="80">
  </figure>



# 系统环境

- Ubuntu 17.04
- Docker 17.03.1-ce
- Consul 0.9
- Nomad 0.5.6
- Nomad master  192.168.99.100
- Nomad node1   192.168.99.101
- Nomad node2   192.168.99.103
- Consul master 192.168.99.102
> 本文中的Nomad都是基于docker安装的.

## 一. Nomad master 安装（Nomad master)

1. 安装Nomad agent
    1. 准备好配置文件 config.hcl 并将它放在/opt/nomad/config目录中

        ```
        name = "master"

        bind_addr = "192.168.99.100" # the default

        server_service_name="nomad-server"
        client_service_name="nomad-client"

        data_dir  = "/nomad/data"

        advertise {
          # Defaults to the node's hostname. If the hostname resolves to a loopback
          # address you must manually configure advertise addresses.
          http = "192.168.99.100:4646"
          rpc  = "192.168.99.100:4647"
          serf = "192.168.99.100:4648" # non-default ports may be specified
        }
        disable_update_check = true
        server {
          enabled          = true
          bootstrap_expect = 3
        }

        client {
          enabled       = true
          network_speed = 10
          options {
            "driver.raw_exec.enable" = "1"
          }
        }

        consul {
          address = "192.168.99.102:8500"
        }

        atlas {
          infrastructure = "hashicorp/mars"
          token          = "atlas.v1.AFE84330943"
        }
        ```

    1. 执行以下docker 命令来创建nomad master实例
        ```
        docker run -d --name nomad --net host  \
        -v "/opt/nomad/data:/data" \
        -v "/opt/nomad/config:/config" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -v "/tmp:/tmp" makeomatic/nomad
        ```

1. 安装Counsul agent
    1. 安装consul
        
        1. 下载安装文件[consul.zip](https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip?_ga=2.263591564.1830874971.1502669774-161034209.1500947169)
1. 准备好配置文件config.hcl并将文件放在/opt/consul/config目录中
    
        ```
        {
            "datacenter": "global",
            "data_dir": "/data/consul", #确保有/data/consul目录
            "log_level": "INFO",
            "node_name": "nomadmaster.local",
            "server": false,
            "advertise_addr": "192.168.99.100",
            "addresses": {
              "http": "0.0.0.0"
            },
            "ui":true,
            "ports": {
              "https": -1
            },
            "check": {
              "id": "c1-check",
              "name": "http on port 8500",
              "http": "http://172.16.30.100:8500/",
              "interval": "5s",
              "timeout": "1s"
            },
            "start_join": ["192.168.99.102"],
            #"retry_join":["172.16.30.102", "172.16.30.103"],
            "bootstrap_expect":1,
            "retry_interval": "30s"
        }
        ```
        
    1. 启动consul agent
        ```
            consul agent -config-dir=/opt/consul/config
        ```

## 二. Node 安装(Nomad node1和Nomad node2)
> node2的安装请参考node1

1. 安装Nomad agent
    1. 准备好配置文件 config.hcl 并将它放在/opt/nomad/config目录中

        ```
        name = "node01"

        bind_addr = "192.168.99.101" # the default

        server_service_name="nomad-server"
        client_service_name="nomad-client"

        data_dir  = "/nomad/data"

        advertise {
          # Defaults to the node's hostname. If the hostname resolves to a loopback
          # address you must manually configure advertise addresses.
          http = "192.168.99.101:4646"
          rpc  = "192.168.99.101:4647"
          serf = "192.168.99.101:4648" # non-default ports may be specified
        }
        disable_update_check = true
        server {
          enabled          = true
          bootstrap_expect = 3
        }

        client {
          enabled       = true
          network_speed = 10
          options {
            "driver.raw_exec.enable" = "1"
          }
        }

        consul {
          address = "192.168.99.102:8500"
        }

        atlas {
          infrastructure = "hashicorp/mars"
          token          = "atlas.v1.AFE84330943"
        }
        ```

    1. 执行以下docker 命令来创建nomad master实例
        ```
        docker run -d --name nomad --net host  \
        -v "/opt/nomad/data:/data" \
        -v "/opt/nomad/config:/config" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -v "/tmp:/tmp" makeomatic/nomad
        ```

1. 安装Counsul agent
    1. 安装consul
        
        1. 下载安装文件[consul.zip](https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip?_ga=2.263591564.1830874971.1502669774-161034209.1500947169)
1. 准备好配置文件config.hcl并将文件放在/opt/consul/config目录中
    
        ```
        {
            "datacenter": "global",
            "data_dir": "/data/consul", #确保有/data/consul目录
            "log_level": "INFO",
            "node_name": "nomad01.local",
            "server": false,
            "advertise_addr": "192.168.99.101",
            "addresses": {
              "http": "0.0.0.0"
            },
            "ui":true,
            "ports": {
              "https": -1
            },
            "check": {
              "id": "c1-check",
              "name": "http on port 8500",
              "http": "http://172.16.30.101:8500/",
              "interval": "5s",
              "timeout": "1s"
            },
            "start_join": ["192.168.99.102"],
            #"retry_join":["172.16.30.102", "172.16.30.103"],
            "bootstrap_expect":1,
            "retry_interval": "30s"
        }
    ```
    
    1. 启动consul agent
        ```
            consul agent -config-dir=/opt/consul/config
        ```
## 三. Consul Server安装
1. 安装Counsul agent
    1. 安装consul
        
        1. 下载安装文件[consul.zip](https://releases.hashicorp.com/consul/0.9.2/consul_0.9.2_linux_amd64.zip?_ga=2.263591564.1830874971.1502669774-161034209.1500947169)
1. 准备好配置文件config.hcl并将文件放在/opt/consul/config目录中
    
        ```
        {
            "datacenter": "global",
            "data_dir": "/data/consul", #确保有/data/consul目录
            "log_level": "INFO",
            "node_name": "consul.local",
            "server": true,
            "advertise_addr": "192.168.99.102",
            "addresses": {
              "http": "0.0.0.0"
            },
            "ui":true,
            "ports": {
              "https": -1
            },
            "check": {
              "id": "c1-check",
              "name": "http on port 8500",
              "http": "http://192.168.99.102:8500/",
              "interval": "5s",
              "timeout": "1s"
            },
            "start_join": ["192.168.99.102"],
            #"retry_join":["172.16.30.102", "172.16.30.103"],
            "bootstrap_expect":1,
            "retry_interval": "30s"
        }
    ```
    
    1. 启动consul agent
        ```
            consul agent -config-dir=/opt/consul/config
        ```
## 四.验证

1. nomad验证

    执行 nomad node-staus 可以看到类似的信息
    ```
    $ nomad server-members
    ID        Datacenter  Name   Class   Drain  Status
    fca62612  dc1         nomad  <none>  false  ready
    c887deef  dc1         nomad  <none>  false  ready
    c887deef  dc1         nomad  <none>  false  ready
    ```
    可以看到3个节点的信息

1. 查看consul

   打开http://192.168.99.102:8500 可以看到所有的consul节点的服务信息，每个节点包含的nomad服务信息也可以看到


自此所有的服务都搭建完毕，我们可以通过nomad与consul的集群服务来快速的发布相应的微服务。

