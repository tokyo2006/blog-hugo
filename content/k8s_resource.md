---
date: 2023-12-27
title: "kubernetes的资源管理"
description: "kubernetes的资源管理"
Section: post
Slug: kubernetes的资源管理
Topics:
 - Devops
Tags:
 - devops
 - kubernetes

---

    在kubernetes中我们是通过设置pod的CPU和内存来管理pod使用的资源的。kubernetes的调度策略也会根据资源设置的不同而有不同的处理方式。

<!--more-->
## 资源类型

通常在kubernetes中我们是通过以下字段来设置pod的资源的：

- 请求的资源
  - spec.containers[].resources.requests.cpu
  - spec.containers[].resources.requests.memory
- 极限资源
  - spec.containers[].resources.limits.cpu
  - spec.containers[].resources.limits.memory

在kubernetes中，pod不会因为CPU资源资源不足而被摧毁掉，这样的资源称之为可压缩资源，在资源不足的时候只是会pending住。但是对于内存资源，如果超过的limit,这个pod就会立即被杀死并会重新创建一个新的pod调度到合适的节点资源中，这样超过limit被催毁的资源被称之为不可压缩的资源。
而对于一个pod来说，它可能有很多个container组成，所以一个pod所需的资源是由所有的container所需资源的累加而成的。

## requests和limits的区别

requests表示这个pod在启动时候所需的最小资源。
> 不难理解，当requests设置的越小，相比于设置大的requests的pod更容易的分配到资源紧张的节点中，因为kubernetes在调度的时候会根据你的requests的设置来分配所在的节点。  

limits表示这个pod在超过这个资源的时候是否等待资源（CPU）或者是否被内设摧毁掉（Memory）
> 对于服务来说设置多大的limits需要根据一段时间的监控来确定这个数值到底是多少合适，这样既能节约资源，也能保证服务正常运行

## kubernetes的QoS模型（Quality of Service，服务质量）

在Kubernetes中，QoS（Quality of Service，服务质量）模型用于根据容器的资源需求和优先级，为它们分配适当的资源。

Kubernetes的QoS模型根据容器的资源需求和优先级将容器分为三个不同的类别：

- Guaranteed（保证型）：这是最高优先级的类别。容器被标记为Guaranteed，表示它们要求系统提供其声明的所有资源。这些容器将被保证能够使用它们所请求的CPU和内存资源，而不会受到其他容器的影响。如果系统无法满足Guaranteed容器的资源需求，它们可能会被阻止调度或终止，在kubernetes的Eviction策略中是最后被Evict的。
  - 当资源的limits和requests设置为相同的值的时候
  - 当资源仅仅设置了limits的值的时候（因为kubernetes会自动为它设置与limits相同的requests值）
- Burstable（可突发型）：这是中等优先级的类别。容器被标记为Burstable，表示它们对资源有一定的需求，但也可以在需要时使用更多的资源进行突发。这些容器在资源紧张时可能会受到其他高优先级容器的影响，但在大多数情况下会获得它们所请求的资源。在kubernetes的Eviction策略中是比BestEffort类型后Evict的。
  - 当pod中至少有一个container设置了requests,那么这个pod就会被划分为Burstable类型
- BestEffort（尽力型）：这是最低优先级的类别。BestEffort容器被标记为不要求任何特定的资源，并且它们只使用系统中未被其他容器使用的闲置资源。它们在资源紧张时会受到其他两个类别容器的影响，因此不能保证获得任何资源，在kubernetes的Eviction策略中是最优先被Evict的。
  - pod里面没有设置任何的requests和limits的时候

## kubernetes中的cpuset

在kubernetes中可以通过cpuset来使得pod可以和节点的cpu资源进行绑定从而独享那一部分的cpu资源，而不是想cpushare那样共享cpu的计算能力。在产线环境中，我们最好来通过这样的设置来减少cpu上下文的切换次数，从而提升服务的性能。要实现cpuset也非常简单，只需要将cpu的requests和limits设置为同一个相等的数值即可，比如：

```yaml

spec:
  containers:
  - name: backend
    image: my-backend:latest
    resources:
      limits:
        memory: "1Gi"
        cpu: "1"
      requests:
        memory: "1Gi"
        cpu: "1"
```

此时应用就会独占一个核的资源，至于是CPU哪个核，这个就由kubernetes随机分配了。
