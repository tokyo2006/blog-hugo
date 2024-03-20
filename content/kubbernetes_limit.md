---
date: 2024-03-13
title: "kubernetes的限制"
description: "kubernetes的限制"
Draft: true
Section: post
Slug: kubernetes的限制
Topics:
 - Devops
Tags:
 - devops
 - kubernetes

---

    在kubernetes中很多资源在部署的时候都会有不同程度的限制，在看了官方文档以后，在这里做一个总结

<!--more-->

## Node

一定要确保节点名称的唯一性，这样才能让kubernetes正常的调度pod部署在节点上。

## 