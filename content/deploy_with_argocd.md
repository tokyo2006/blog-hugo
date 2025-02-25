---
date: 2025-02-25
title: "使用ArgoCD部署应用"
description: "使用ArgoCD部署应用"
Section: post
Draft: true
Slug: 使用ArgoCD部署应用
Topics:
 - Devops
Tags:
 - devops
 - ArgoCD
---

## 准备一个应用程序

我使用的是官方的应用程序，地址是这里：[argocd-example-apps](https://github.com/tokyo2006/argocd-example-apps)
以[helm-guestbook](https://github.com/tokyo2006/argocd-example-apps/tree/master/helm-guestbook "helm-guestbook") 作为演示的helm仓库

## 创建applications.yml

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook-application
  namespace: argocd
spec:
  project: default
  source:
    chart: helm-guestbook
    repoURL: https://github.com/tokyo2006/argocd-example-apps
    targetRevision: master
    helm:
      releaseName: guestbook
  destination:
    server: "https://kubernetes.default.svc"
    namespace: default
```

## 部署应用程序

```bash
kubectl apply -f applications.yml
```
