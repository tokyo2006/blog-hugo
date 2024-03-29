---
date: 2023-11-23
title: "运维眼中的源代码版本管理"
description: "源代码的版本管理"
Section: post
Slug: 运维眼中的源代码版本管理
Topics:
 - Devops
Tags:
 - devops
 - lifecycle
 - shell 
 - sourcecode
 - git
---

    源代码的管理可以说是所有软件应用的基石，它也是生命周期的开始。我会从这里开始详细的回顾整个软件生命周期的每一个流程
<!--more-->

# 源代码版本管理

源代码版本管理是一种系统化的方法，用于跟踪和管理软件开发过程中的源代码的变化。它允许开发团队记录、控制和协调不同版本的代码，以便更好地进行协作和追踪变更历史。

源代码版本管理系统的主要功能包括：

- 版本控制：源代码版本管理系统可以跟踪和记录源代码的每个版本的变化。开发人员可以创建新的版本、回滚到先前的版本，以及在不同版本之间进行比较和合并。

- 协作与并行开发：多个开发人员可以同时在同一代码库上工作，而不会相互冲突。每个开发人员可以在自己的本地副本上进行更改，并将其推送到共享的代码库中。版本管理系统会协调并合并这些更改，以确保不会发生冲突。

- 历史记录和追踪：版本管理系统可以记录每个代码更改的详细信息，包括何时进行的更改、由谁进行的更改以及更改的具体内容。这样，开发人员可以追溯代码的演变历史，查找引入问题的更改，并快速恢复到之前的稳定状态。

- 分支与合并：版本管理系统允许开发人员创建分支，这是源代码的独立副本，可以在不影响主线开发的情况下进行实验、修复错误或开展其他工作。分支之间的更改可以合并到主线或其他分支中，以保持代码的一致性。

- 标签和发布：版本管理系统支持给代码库的特定版本打上标签，以便将其标识为发布版或重要的里程碑。这有助于团队追踪和记录软件的版本，并在需要时方便地回滚到特定版本。

常见的源代码版本管理系统包括Git、Subversion（SVN）、Mercurial等。这些工具提供了各种功能和工作流选项，以满足不同团队和项目的需求。通过使用源代码版本管理系统，开发团队可以更好地组织和管理代码，提高协作效率，减少错误，并更好地控制软件开发过程。我在工作中大部分都是使用Git和Mercurial,以及和同学一起做网站时短暂的用过Subversion(svn)。

## 源代码仓库

    通常源代码仓库有两种管理方式，一个是Polyrepo（多个代码库存储库），一个是Monorepo（单一代码库存储库）。 我恰好两种仓库的方式都经历过，我个人觉得可以根据公司的情况合理的使用这两种管理方式。

### Polyrepo

Polyrepo的特点可能包括：

- 组件分离：Polyrepo将项目的不同组件或模块分离到独立的代码库中，每个代码库专注于特定的功能或模块。
- 独立管理：每个代码库都有自己的版本控制和发布流程，可以独立地更新、测试和部署。
- 代码复用：Polyrepo鼓励代码的重用，通过将常用的组件或库作为依赖项引入项目。
- 独立协作：不同组件的开发人员可以在各自的代码库中进行协作，实现分布式开发。
- 精细化控制：Polyrepo允许对不同组件的代码库进行独立的管理和控制，包括权限控制、CI/CD流程和依赖管理等。

使用Polyrepo管理服务代码还是会面临这些问题：

- 每个服务都是单独的仓库，导致企业的整个仓库数量非常多。
- 对于开发人员可能只了解自己开发的服务，在解决服务依赖的问题的时候往往不知道从哪儿去查看源代码。
- 对于Devops和SRE对于部署的需要做更多的适配以便灵活的应对各个独立服务的部署。

### Monorepo

Monorepo的主要特点如下：

- 单一存储库：Monorepo将整个项目的代码存储在一个代码库中，无论是核心应用程序代码、库、模块还是其他组件。这种集中存储的方式使得跨项目的代码共享和复用更加便利。
- 共享和复用：在Monorepo中，不同的组件可以方便地共享代码。这意味着可以在项目中的不同部分之间共享通用功能、工具库和模块，减少代码的重复编写，并提高开发效率。
- 版本控制：Monorepo使用统一的版本控制系统（如Git）来管理整个项目的代码。这使得可以对整个项目进行统一的版本控制，轻松记录和管理代码的变更历史。
- 跨组件协作：Monorepo促进了不同组件之间的协作和集成。开发人员可以在同一个代码库中进行代码审查、讨论和协同开发，更好地管理代码的依赖关系和版本兼容性。
- 构建和部署：Monorepo可以集成构建工具和部署流程，以支持整个项目的构建和部署。这有助于确保不同组件之间的一致性，并简化构建和部署的流程。

恰好在上家公司的所有服务都是以monorepo来管理的，让我体验到了从未有过的灾难

- 所有的CICD都绑定在了一起，当发布其中一个服务的时候，会经历很长的时间。
- 由于使用统一的服务更新命令，当更新命令中模板或者相关逻辑发生变化，执行服务更新命令通常会导致服务CICD流程的失败。
- 所有服务都在一个仓库中，导致代码仓库及其庞大，对于CICD的工具来说，网络流量是个不小的负载。
- 所有的更新都必须小心翼翼。

### 如何选择

对于我来说，我更喜欢把两种仓库的管理方式结合起来。下面是我认为比较好的代码管理方式：

- 业务服务使用Polyrepo的方式管理。开发只关注业务逻辑的代码。
- 运维服务使用Monorepo的方式管理，比如基础设施代码，部署代码，配置管理代码。

对于服务开发团队来说他们可以尽可能的保证服务代码仓库的简洁并只关注服务本身，并通过Devops团队提供的可视化工具来掌控服务的部署及其状态,对于Devops和SRE团队来说，拥有统一的基础设施代码仓库为管理整个公司的基础设施资源都提高的可维护性。

![repo_management](https://res.cloudinary.com/xinta/image/upload/v1700708261/blogimage/oidimjbp0xmwrvwmvsta.png)

## 源代码的版本管理流程

通常在使用代码版本管理软件的时候如果使用的方式不对经常会遇到我在[运维眼中的软件生命周期](https://blog.lkjxblog.site/post/%E8%BF%90%E7%BB%B4%E7%9C%BC%E4%B8%AD%E7%9A%84%E8%BD%AF%E4%BB%B6%E7%94%9F%E5%91%BD%E5%91%A8%E6%9C%9F/)提到的提交代码的时候常常会遇到代码冲突的情况，也遇到自己把别人代码覆盖亦或是自己代码被别人覆盖。

现在大部分都是采用Git Flow的代码提交流程来规范团队的代码提交。我个人也比较偏好这样的提交流程来保证代码的安全以及提高团队开发协作的效率。我们可以参考下面的流程图来了解Git Flow的代码提交管理流程.

![git_flow](https://res.cloudinary.com/xinta/image/upload/v1700724761/blogimage/jj30rfjoyh0mdmyuuz7f.png)

在这个图里面我们有2种类型的分支，一个是固定分支，还有一个是临时分支，固定分支就是用来记录代码历史版本的，临时分支都是用来作为辅助分支使用，这些分支在使用完成后就会被删除

对于固定分支：

- master 这是一个稳定的分支, 又称为保护分支， 表示正式发布的历史, 所有对外正式版本发布都会合并到这里, 并打上版本标签。
- development 开发分支用来整合功能分支， 表示最新的开发状态。等价于功能分支工作流的master分支。

对于临时分支：

- feature 这是从development分支中签出的，当开发一个新功能的时候签出，当开发完毕后合并回development分支并删除。
- release 当需要发布的时候会从development分支中签出一个release分支，并在其中添加各种发布文档和记录信息，并进入发布循环，此分支只包含需要发布的内容，新功能都不会再此分支中提交，如果有需要修复的会再此分支中提交并修复，当一切准备就绪就将此分支合并到master分支并打上相应的tag,并将合并后的master分支合并回development分支，然后就可以删掉此分支了
- hotfix  紧急修复分支，当产线服务出现需要紧急修复的情况，hotfix分支将从master分支签出，并完成修复工作后合并回master分支和development分支并打上tag

这套工作流只是一个流程模型，我们应该根据团队的大小灵活的定义适合自己的代码提交流程，就我而言对于一个大的团队，这样的工作流程是和有必要的，这会减少很多代码提交中的痛点，当然对于三四个人的小团队，可以用更加简单的代码提交流程。

