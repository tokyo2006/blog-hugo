---
date: 2024-03-20
title: "kubernetes的最佳实践"
description: "kubernetes的最佳实践"
Draft: true
Section: post
Slug: kubernetes的最佳实践
Topics:
 - Devops
Tags:
 - devops
 - kubernetes

---

## 对于大规模集群的最佳实践

> kubernetes(v1.29)支持最多5000个节点的集群。对于每个节点有相应的限制

- 每个节点不要超过110个pods
- 整个集群不要超过总共15000个pods
- 整个集群不要超过300000个容器

### 云计算提供商的资源配额

> 如果在云服务商要部署kubernetes，为了能正常的迅速启动新节点部署新应用，应该向云供应商申请足够的资源，这些资源包含以下内容：

- Computer instances
- CPUs
- Storage volumes
- In-use IP addresses
- Packet filtering rule sets
- Number of load balancers
- Network subnets
- Log streams

### 控制面板组件

> 如果使用云供应商提供的kubernetes服务，控制面板是由云供应商进行维护的，我们只需要定期的进行版本升级即可。

对于大型集群，需要一个具有足够计算资源和其他资源的控制平面。通常情况下，最好在每个故障区域运行一个或两个控制平面实例，首先垂直扩展这些实例，然后在到达下降点后水平扩展到(垂直)规模。每个故障区至少应该运行一个实例，以提供容错性。Kubernetes节点不会自动将流量引导到位于同一故障区域的控制平面端点。

### 资源分配

Kubernetes的资源限制有助于最小化内存泄漏的影响，以及pod和容器对其他组件的影响。这些资源限制适用于插件资源，就像它们适用于应用程序工作负载一样。

## 在多个可用区运行

> Kubernetes的设计使单个Kubernetes集群可以跨多个故障区域运行，通常这些区域适合一个称为区域的逻辑分组。主要云提供商将区域定义为一组提供一致功能的故障区域(也称为可用性区域):在一个区域内，每个区域提供相同的api和服务。典型的云架构旨在最大限度地减少一个区域的故障对另一个区域服务的影响。

### 多可用区节点

> 我们可以将节点部署在多个可用节点以保证服务的高可用性，当然也包括控制面板，如果使用云服务商提供的kubernetes服务，比如AWS的EKS，控制面板由云供应商维护，如果是自建kuberntes,则需要多个可用区部署多个kubernetes master。

### 跨域访问存储

> 当创建持久卷时，Kubernetes会自动将区域标签添加到链接到特定区域的任何PersistentVolumes。然后，调度器通过其novolumezoneconconflict谓词确保声明给定PersistentVolume的pod只被放置在与该卷相同的区域中。

### 网络
 
> Kubernetes本身不包括区域感知网络。可以使用网络插件来配置集群网络，并且该网络解决方案可能具有特定于区域的元素。例如，如果您的云提供商支持type=LoadBalancer的服务，那么负载平衡器可能只会将流量发送到与处理给定连接的负载平衡器元素在同一区域运行的pod。查看云提供商的文档以了解详细信息。对于自定义或本地部署，也需要考虑类似的问题。服务和入口行为，包括处理不同的故障区域。

### 故障恢复

> 在设置集群时，您可能还需要考虑如果一个区域中的所有故障区域同时脱机，那么您的设置是否以及如何恢复服务。
> 确保任何对集群至关重要的修复工作不依赖于集群中至少有一个健康节点。

## 验证节点

### 节点一致性测试

### 节点先决条件

### 运行节点一致性测试

### 运行其他架构的节点一致性测试

### 运行节点分配测试

## 强制pod执行安全标准

## PKI证书和要求

参考[PKI certificates and requirement](https://kubernetes.io/docs/setup/best-practices/certificates/)