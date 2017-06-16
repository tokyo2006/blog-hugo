---
date: 2017-04-01
title: "在CentOS7中安装Kubernetes"
description: " 一直以来都想尝鲜下Kubernates但是每次看网站都云里雾里的，在google中看到很多博客都写了安装的步骤，于是乎我就参考了Jimmy Song写的在CentOS上安装Kubernetes详细指南"
Topics:
 - docker
Tags: ["docker","linux","shell","kubernetes"]
---

一直以来都想尝鲜下Kubernates但是每次看网站都云里雾里的，在google中看到很多博客都写了安装的步骤，于是乎我就参考了[Jimmy Song](http://rootsongjc.github.io/rootsongjc.github.io/about)写的[在CentOS上安装Kubernetes详细指南](http://rootsongjc.github.io/blogs/kubernetes-installation-on-centos/)。这里写下安装的步骤记录一下。
<!--more-->

![kubernetesincentos](http://onm4sjyr8.bkt.clouddn.com/QQ%E5%9B%BE%E7%89%8720170401144347.png) 
#### 系统环境

- CentOS Linux release 7.3.1611
- Docker 17.03.1-ce
- Etcd 3.1.5
- Kubernetes 1.6.0
- flannel 0.7.0-1



####  一. Master安装

1. 关闭sellinux和防火墙

   ```shell
   echo "SELINUX=disabled
         SELINUXTYPE=targeted" > /etc/sysconfig/selinux
   setenforce 0
   systemctl stop firewalld
   systemctl disable firewalld
   ```

2. 打开文件限制

   ```
   echo "*                -       nofile          65536" >> /etc/security/limits.conf
   ```

3. 安装docker

   ```
   curl -sSL https://get.docker.com/ | sh
   ```

4. 安装配置etcd

   1. 下载安装包并将解压后的文件etcd,etcdctl放入/usr/bin/下

      ```shell
      DOWNLOAD_URL=https://storage.googleapis.com/etcd  
      ETCD_VER=v3.1.5  
      wget ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz
      tar xvf etcd-${ETCD_VER}-linux-amd64.tar.gz
      cd etcd-${ETCD_VER}-linux-amd64/
      mv etcd etcdtl /usr/bin/
      ```

   2. 添加配置文件

      ```shell
      mkdir -p /etc/etcd/
      touch /etc/etcd/etcd.conf
      cat << ETCD_CONF >/etc/etcd/etcd.conf
      # [member]
      ETCD_NAME=default
      ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
      # ETCD_WAL_DIR=""
      # ETCD_SNAPSHOT_COUNT="10000"
      # ETCD_HEARTBEAT_INTERVAL="100"
      # ETCD_ELECTION_TIMEOUT="1000"
      # ETCD_LISTEN_PEER_URLS="http://localhost:2380"
      ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
      # ETCD_MAX_SNAPSHOTS="5"
      # ETCD_MAX_WALS="5"
      # ETCD_CORS=""
      #
      # [cluster]
      # ETCD_INITIAL_ADVERTISE_PEER_URLS="http://localhost:2380"
      # if you use different ETCD_NAME (e.g. test), set ETCD_INITIAL_CLUSTER value for this name, i.e. "test=http://..."
      # ETCD_INITIAL_CLUSTER="default=http://localhost:2380"
      # ETCD_INITIAL_CLUSTER_STATE="new"
      # ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
      ETCD_ADVERTISE_CLIENT_URLS="http://0.0.0.0:2379"
      # ETCD_DISCOVERY=""
      # ETCD_DISCOVERY_SRV=""
      # ETCD_DISCOVERY_FALLBACK="proxy"
      # ETCD_DISCOVERY_PROXY=""
      #
      # [proxy]
      # ETCD_PROXY="off"
      # ETCD_PROXY_FAILURE_WAIT="5000"
      # ETCD_PROXY_REFRESH_INTERVAL="30000"
      # ETCD_PROXY_DIAL_TIMEOUT="1000"
      # ETCD_PROXY_WRITE_TIMEOUT="5000"
      # ETCD_PROXY_READ_TIMEOUT="0"
      #
      # [security]
      # ETCD_CERT_FILE=""
      # ETCD_KEY_FILE=""
      # ETCD_CLIENT_CERT_AUTH="false"
      # ETCD_TRUSTED_CA_FILE=""
      # ETCD_PEER_CERT_FILE=""
      # ETCD_PEER_KEY_FILE=""
      # ETCD_PEER_CLIENT_CERT_AUTH="false"
      # ETCD_PEER_TRUSTED_CA_FILE=""
      # [logging]
      # ETCD_DEBUG="false"
      # examples for -log-package-levels etcdserver=WARNING,security=DEBUG
      # ETCD_LOG_PACKAGE_LEVELS=""
      ETCD_CONF
      ```

   3. 创建etcd.service

      ```shell
      mkdir -p /var/lib/etcd
      cat << ETCD_SERVICE > /usr/lib/systemd/system/etcd.service
      [Unit]
      Description=Etcd Server
      After=network.target
      After=network-online.target
      Wants=network-online.target

      [Service]
      Type=notify
      WorkingDirectory=/var/lib/etcd/
      EnvironmentFile=/etc/etcd/etcd.conf
      # set GOMAXPROCS to number of processors
      ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /usr/bin/etcd --name=\"${ETCD_NAME}\" --data-dir=\"${ETCD_DATA_DIR}\" --listen-client-urls=\"${ETCD_LISTEN_CLIENT_URLS}\""
      Restart=on-failure

      [Install]
      WantedBy=multi-user.target
      ETCD_SERVICE
      ```

5. 安装flannel

   ```shell
   yum install flannel -y
   ```

6. 安装kubernetes

   1. 下载kubernetes并安装

      ```shell
      wget https://github.com/kubernetes/kubernetes/releases/download/v1.6.0/kubernetes.tar.gz
      tar -zxvf kubernetes.tar.gz
      cd kubernetes
      ./cluster/get-kube-binaries.sh
      cd server
      tar -xvf kubernetes-server-linux-amd64.tar.gz
      cd kubernetes/bin
      rm -f *_tag *.tar
      chmod 755 *
      mv * /usr/bin
      ```

   2. 配置kubernates

      Master节点需要配置的kubernetes的组件有:

      - kube-apiserver
      - kube-controller-manager
      - kube-scheduler
      - kube-proxy
      - kubectl

      1.   配置kube-apiserver

         ```shell
         #创建kube-apiserver的配置文件
         touch /etc/kubernetes/apiserver
         cat << KUBE_APISERVER > /etc/kubernetes/apiserver
         ###
         ## kubernetes system config
         ##
         ## The following values are used to configure the kube-apiserver
         ##
         #
         ## The address on the local server to listen to.
         KUBE_API_ADDRESS="--insecure-bind-address=${your_master_api_address}"
         #
         ## The port on the local server to listen on.
         KUBE_API_PORT="--insecure-port=8080"
         #
         ## Port minions listen on
         KUBELET_PORT="--kubelet_port=10250"
         #
         ## Comma separated list of nodes in the etcd cluster
         KUBE_ETCD_SERVERS="--etcd_servers=http://127.0.0.1:2379"
         #
         ## Address range to use for services
         KUBE_SERVICE_ADDREKUBELET_POD_INFRA_CONTAINERSSES="--service-cluster-ip-range=10.254.0.0/16"
         #
         ## default admission control policies
         KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota"
         #
         ## Add your own!
         KUBE_API_ARGS=""
         KUBE_APISERVER

         #创建kube-apiserver的service文件
         touch /usr/lib/systemd/system/kube-apiserver.service
         cat << KUBE_APISERVER_SERVICE > /usr/lib/systemd/system/kube-apiserver.service
         [Unit]
         Description=Kubernetes API Service
         Documentation=https://github.com/GoogleCloudPlatform/kubernetes
         After=network.target
         After=etcd.service

         [Service]
         EnvironmentFile=/etc/kubernetes/config
         EnvironmentFile=/etc/kubernetes/apiserver
         ExecStart=/usr/bin/kube-apiserver \
         	    $KUBE_LOGTOSTDERR \
         	    $KUBE_LOG_LEVEL \
         	    $KUBE_ETCD_SERVERS \
         	    $KUBE_API_ADDRESS \
         	    $KUBE_API_PORT \
         	    $KUBE_ALLOW_PRIV \
         	    $KUBE_SERVICE_ADDRESSES \
         	    $KUBE_ADMISSION_CONTROL \
         	    $KUBE_API_ARGS \
         		$KUBE_SERVICE_ADDREKUBELET_POD_INFRA_CONTAINERSSES
         Restart=on-failure
         Type=notify

         [Install]
         WantedBy=multi-user.target
         KUBE_APISERVER_SERVICE
         ```

      2. 配置kube-controller-manager

         ```shell
         # 创建kube-controller-manager配置文件
         touch /etc/kubernetes/config
         cat << KUBE_CONFIG > /etc/kubernetes
         ###
         # kubernetes system config
         #
         # The following values are used to configure various aspects of all
         # kubernetes services, including
         #
         #   kube-apiserver.service
         #   kube-controller-manager.service
         #   kube-scheduler.service
         #   kubelet.service
         #   kube-proxy.service
         # logging to stderr means we get it in the systemd journal
         KUBE_LOGTOSTDERR="--logtostderr=true"

         # journal message level, 0 is debug
         KUBE_LOG_LEVEL="--v=0"

         # Should this cluster be allowed to run privileged docker containers
         KUBE_ALLOW_PRIV="--allow_privileged=false"

         # How the controller-manager, scheduler, and proxy find the apiserver
         KUBE_MASTER="--master=http://${your_master_api_address}:8080"
         KUBE_CONFIG
         touch /etc/kubernetes/controller-manager
         cat << KUBE_CONTROLLER > /etc/kubernetes/controller-manmger
         ###
         # The following values are used to configure the kubernetes controller-manager
         # defaults from config and apiserver should be adequate
         # Add your own!
         KUBE_CONTROLLER_MANAGER_ARGS=""
         KUBE_CONTROLLER
         #创建kube-controller-manmger的service文件
         touch /usr/lib/systemd/system/kube-controller-manmger.service
         cat KUBE_CONTROLLER_SERVICE > /usr/lib/systemd/system/kube-controller-manmger.service
         [unit]
         Description=Kubernetes Controller Manager
         Documentation=https://github.com/GoogleCloudPlatform/kubernetes

         [Service]
         EnvironmentFile=/etc/kubernetes/config
         EnvironmentFile=/etc/kubernetes/controller-manager
         ExecStart=/usr/bin/kube-controller-manager \
         	    $KUBE_LOGTOSTDERR \
         	    $KUBE_LOG_LEVEL \
         	    $KUBE_MASTER \
         	    $KUBE_CONTROLLER_MANAGER_ARGS
         Restart=on-failure
         [Install]
         WantedBy=multi-user.target
         KUBE_CONTROLLER_SERVICE
         ```

      3. 配置kube-scheduler

         ```shell
         #创建kube-scheduler的配置文件
         touch /etc/kubernetes/scheduler
         cat << KUBE_SCHEDULER > /etc/kubernetes/scheduler
         ###
         # kubernetes scheduler config
         # default config should be adequate
         # Add your own!
         KUBE_SCHEDULER_ARGS=""
         KUBE_SCHEDULER
          
         #创建kube-scheduler的service文件
         touch /usr/lib/systemd/system/kube-scheduler.service
         cat << KUBE_SCHEDULER_SERVICE > /usr/lib/systemd/system/kube-scheduler.service
         [Unit]
         Description=Kubernetes Scheduler Plugin
         Documentation=https://github.com/GoogleCloudPlatform/kubernetes

         [Service]
         EnvironmentFile=/etc/kubernetes/config
         EnvironmentFile=/etc/kubernetes/scheduler
         ExecStart=/usr/bin/kube-scheduler \
                 $KUBE_LOGTOSTDERR \
                 $KUBE_LOG_LEVEL \
                 $KUBE_MASTER \
                 $KUBE_SCHEDULER_ARGS
         Restart=on-failure

         [Install]
         WantedBy=multi-user.target
         KUBE_SCHEDULER_SERVICE
         ```

      4. 配置kube-proxy

         ```shell
         #创建kube-proxy的配置文件
         touch /etc/kubernetes/proxy
         cat << KUBE_PROXY > /etc/kubernetes/proxy
         ###
         # kubernetes proxy config
         # default config should be adequate
         # Add your own!
         KUBE_PROXY_ARGS=""
         KUBE_PROXY
         #创建kube-proxy的service文件
         touch /usr/lib/systemd/system/kube-proxy.service
         cat << KUBE_PROXY_SERVICE > /usr/lib/systemd/system/kube-proxy.service
         [Unit]
         Description=Kubernetes Kube-Proxy Server
         Documentation=https://github.com/GoogleCloudPlatform/kubernetes
         After=network.target

         [Service]
         EnvironmentFile=/etc/kubernetes/config
         EnvironmentFile=/etc/kubernetes/proxy
         ExecStart=/usr/bin/kube-proxy \
         	    $KUBE_LOGTOSTDERR \
         	    $KUBE_LOG_LEVEL \
         	    $KUBE_MASTER \
         	    $KUBE_PROXY_ARGS
         Restart=on-failure

         [Install]
         WantedBy=multi-user.target
         KUBE_PROXY_SERVICE
         ```

      5. 配置kubelet

         ```shell
         #创建kubelet的配置文件
         touch /etc/kubernetes/kubelet
         cat << KUBELET > /etc/kubernetes/kubelet
         ###
         ## kubernetes kubelet (minion) config
         #
         ## The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
         KUBELET_ADDRESS="--address=0.0.0.0"
         #
         ## The port for the info server to serve on
         KUBELET_PORT="--port=10250"
         #
         ## You may leave this blank to use the actual hostname
         KUBELET_HOSTNAME="--hostname_override=${your_master_api_address}"
         #
         ## location of the api-server
         KUBELET_API_SERVER="--api_servers=http://${your_master_api_address}:8080"
         #
         ## pod infrastructure container
         KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest"
         #
         ## Add your own!
         KUBELET_ARGS=""
         KUBELET

         #创建kubelet的service文件
         touch /usr/lib/systemd/system/kubelet.service
         cat << KUBELET_SERVICE > /usr/lib/systemd/system/kubelet.service
         [Unit]
         Description=Kubernetes Kubelet Server
         Documentation=https://github.com/GoogleCloudPlatform/kubernetes
         After=docker.service
         Requires=docker.service

         [Service]
         WorkingDirectory=/var/lib/kubelet
         EnvironmentFile=/etc/kubernetes/config
         EnvironmentFile=/etc/kubernetes/kubelet
         ExecStart=/usr/bin/kubelet \
         	    $KUBE_LOGTOSTDERR \
         	    $KUBE_LOG_LEVEL \
         	    $KUBELET_API_SERVER \
         	    $KUBELET_ADDRESS \
         	    $KUBELET_PORT \
         	    $KUBELET_HOSTNAME \
         	    $KUBE_ALLOW_PRIV \
         	    $KUBELET_POD_INFRA_CONTAINER \
         	    $KUBELET_ARGS
         Restart=on-failure

         [Install]
         WantedBy=multi-user.target
         KUBELET_SERVICE
         ```

   3. 启动kubernetes master

      ```shell
      for SERVICES in etcd kube-apiserver kube-controller-manager kube-scheduler kube-proxy kubelet flanneld; do
          systemctl restart $SERVICES
          systemctl enable $SERVICES
          systemctl status $SERVICES
      done
      ```

   4. 在master上验证kubernetes

      ```shell
      #如果你的master用的是IP，那就得先运行
      alias kubectl=" kubectl -s http://${your_master_api_address}:8080"
      #然后就可以运行
      kubectl get all
      #运行后一般会有这样的结果
      NAME             CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
      svc/kubernetes   10.254.0.1   <none>        443/TCP   2h

      ```
