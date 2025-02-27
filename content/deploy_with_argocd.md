---
date: 2025-02-25
title: "使用ArgoCD部署应用"
description: "使用ArgoCD部署应用"
Section: post
Draft: false
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
    path: helm-guestbook
    repoURL: https://github.com/tokyo2006/argocd-example-apps.git
    targetRevision: HEAD
    helm:
      releaseName: guestbook
      parameters:
      - name: 'image.repository'
        value: 'tokyo2006/gutstbook'
      - name: 'image.tag'
        value: '01c967739b75eb5736449158fba1bac1b18dc3b3'
  destination:
    server: "https://kubernetes.default.svc"
    namespace: default
```

## 部署应用程序

```bash
kubectl apply -f applications.yml
```

部署以后就可以在argocd的界面中看到guestbook的部署状态。

![argocd-guestbook](https://res.cloudinary.com/xinta/image/upload/v1740624363/blogimage/argocd_application.jpg)

## 关于application.yaml,下面是一个详细的参数说明

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-helm-app
  namespace: argocd # 如果不是默认的 argocd 命名空间，请更改为相应的命名空间
  labels:
    app.kubernetes.io/name: my-helm-app
    app.kubernetes.io/part-of: my-system
spec:
  project: default # 指定应用属于哪个项目，默认是 'default'
  source:
    repoURL: 'https://github.com/my-org/my-repo.git' # Git 仓库 URL
    targetRevision: HEAD # 可以是分支、标签或提交 ID
    path: charts/my-chart # Git 仓库中的路径
    helm:
      valueFiles:
        - values.yaml
      parameters:
        - name: image.tag
          value: "latest"
  destination:
    server: 'https://kubernetes.default.svc' # 目标 Kubernetes API 服务器地址
    namespace: default # 部署的目标命名空间
  syncPolicy:
    automated: # 启用自动同步
      prune: true # 删除不再存在的资源
      selfHeal: true # 自动修复与期望状态不符的情况
    syncOptions:
      - CreateNamespace=true # 如果目标命名空间不存在则创建
      - ApplyOutOfSyncOnly=true # 只对不同步的对象进行 apply 操作
  ignoreDifferences: # 忽略某些字段的变化，避免不必要的同步
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/template/spec/containers/0/imagePullPolicy
  info:
    - name: Documentation
      value: https://my-docs.example.com/
```
