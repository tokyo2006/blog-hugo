---
date: 2024-01-11
title: "尝试AutoGen创建自己的AI团队"
description: "尝试AutoGen创建自己的AI团队"
Section: post
Slug: 尝试Autogen创建自己的AI团队
Topics:
 - AI
Tags:
 - AI
 - AutoGen
 - LM Studio

---


    我们来尝试用微软的Autogen创建自己的AI小团队来实现完成一些简单的任务
<!--more-->

## 什么是AutoGen

[AutoGen](https://microsoft.github.io/autogen/)是一个微软开源的AI框架，它允许使用多个代理开发LLM应用程序，这些代理可以相互交谈以解决任务。AutoGen代理是可定制的、可对话的，并且无缝地允许人类参与。它们可以在各种模式下运行，这些模式结合了LLM、人工输入和工具。  
以下是AutoGen的简单介绍：

- AutoGen支持以最小的工作量构建基于多代理对话的下一代LLM应用程序。它简化了复杂LLM工作流的编排、自动化和优化。它最大限度地提高了LLM模型的性能，克服了它们的缺点。
- 它支持复杂工作流的多种对话模式。有了可定制和可对话的代理，开发人员可以使用AutoGen来构建关于对话自治、代理数量和代理对话拓扑的广泛对话模式。
- 它提供了一组具有不同复杂性的工作系统。这些系统涵盖了来自不同领域和复杂性的广泛应用。这演示了AutoGen如何轻松支持各种对话模式。
- AutoGen提供了openai的直接替代品。完成或打开。ChatCompletion作为一个增强的推理API。它支持简单的性能调优、API统一和缓存等实用程序以及高级使用模式，如错误处理、多配置推理、上下文编程等。

## 打造自己的AI小团队

### 系统需求

- 你需要在自己的本地安装python（>=3.8）环境，具体安装步骤请参考[官网](https://www.python.org/)
- 科学上网（懂的都懂）
- 【可选】安装[LM Studio](https://lmstudio.ai/)(这个工具能够帮助我们下载所需要的大模型并可以选择大模型暴露类openai的API服务，如果你有钱用ChatGPT-4就不需要安装这个)。

### 安装AutoGen

通过pip安装

```bash
pip install pyautogen
```

### 启动LM Studio并下载一份大模型【可选】

在这里我们使用Mistral 7B大模型来替代OpenAI的GPT-4,毕竟用那个要钱，但是效果肯定是那个最好了。有钱就直接用，可以忽略LM Studio

1. 下载大模型
![lm_studio](https://res.cloudinary.com/xinta/image/upload/v1705027986/blogimage/lm_studio.png)
启动以此大模型的API服务器
1. 启动API服务
   1. 选择模型
   2. 设置端口
   3. 根据机器是否开启GPU加速
![start_server](https://res.cloudinary.com/xinta/image/upload/v1705027998/blogimage/start_server.png)

如果启动成功可以看到下面的输出
![server_log](https://res.cloudinary.com/xinta/image/upload/v1705027991/blogimage/server_log.png)

### 编写代码

这里我们来编写一份一个让AI团队来根据你的描述完成一个简单的工作，我们这里设置的是：在工作目录中使用[cars.csv](https://blog.lkjxblog.tech/resource/cars.csv)中的数据，绘制一个可视化图，告诉我们重量和“每加仑城市英里数”之间的关系。将绘图保存到文件中。在可视化数据集之前打印数据集中的字段。  

我们创建一个目录结构如下：

```
autogen
│
├── groupchat
│   └── cars.csv
└── analyze_cars.py
```

在analyze_cars.py里面添加我们的代码

```python

import autogen

# 这里添加我们使用的大模型，如果你使用chatgpt-4,可以改成下面的方式
# config_list = [
#     {
#         "model": "gpt-4",
#         "api_key": "<your OpenAI API key here>"
#     },
# ]
config_list = [
        {
            "model": "chatglm2-6b",
            "api_base": "http://localhost:1234/v1", #这里添加我们开启的本地API服务地址
            "api_type": "open_ai",
            "api_key": "NULL", # 这里仅仅是一个占位，因为我们本地的服务没有设置认证
        }
]

llm_config = {
    "request_timeout": 600,
    "seed": 42,
    "config_list": config_list,
    "temperature":0
}

# 创建一个用户代理，我们通过这个代理来作为输入我们需求的入口
user_proxy = autogen.UserProxyAgent(
   name="User_proxy",
   system_message="A human admin.",
   code_execution_config={"last_n_messages": 3, "work_dir": "groupchat","use_docker":False},
   human_input_mode="NEVER",
)

# 创建一个开发的助理，AutoGen通过这个AI助理来根据评判助理的建议来写代码
coder = autogen.AssistantAgent(
    name="Coder",  
    llm_config=llm_config,
)

# 创建一个评判助理，能够分析用户代理提出的需求，并对开发助理写的代码进行评估并提出意见
critic = autogen.AssistantAgent(
    name="Critic",
    system_message="""Critic. You are a helpful assistant highly skilled in evaluating the quality of a given visualization code by providing a score from 1 (bad) - 10 (good) while providing clear rationale. YOU MUST CONSIDER VISUALIZATION BEST PRACTICES for each evaluation. Specifically, you can carefully evaluate the code across the following dimensions
- bugs (bugs):  are there bugs, logic errors, syntax error or typos? Are there any reasons why the code may fail to compile? How should it be fixed? If ANY bug exists, the bug score MUST be less than 5.
- Data transformation (transformation): Is the data transformed appropriately for the visualization type? E.g., is the dataset appropriated filtered, aggregated, or grouped  if needed? If a date field is used, is the date field first converted to a date object etc?
- Goal compliance (compliance): how well the code meets the specified visualization goals?
- Visualization type (type): CONSIDERING BEST PRACTICES, is the visualization type appropriate for the data and intent? Is there a visualization type that would be more effective in conveying insights? If a different visualization type is more appropriate, the score MUST BE LESS THAN 5.
- Data encoding (encoding): Is the data encoded appropriately for the visualization type?
- aesthetics (aesthetics): Are the aesthetics of the visualization appropriate for the visualization type and the data?

YOU MUST PROVIDE A SCORE for each of the above dimensions.
{bugs: 0, transformation: 0, compliance: 0, type: 0, encoding: 0, aesthetics: 0}
Do not suggest code. 
Finally, based on the critique above, suggest a concrete list of actions that the coder should take to improve the code.
""",
    llm_config=llm_config,
)

# 讲用户代理，开发助理以及评判助理组成一个团队并讲需求输入让开发处理和评判助理共同解决用户提出的问题
groupchat = autogen.GroupChat(agents=[user_proxy, coder, critic], messages=[], max_round=20)
manager = autogen.GroupChatManager(groupchat=groupchat, llm_config=llm_config)

user_proxy.initiate_chat(manager, message="use data from cars.csv in work dir and plot a visualization that tells us about the relationship between weight and horsepower. Save the plot to a file. Print the fields in a dataset before visualizing it.")
# type exit to terminate the chat
```

执行这段代码

```
python analyze_cars.py
```

你就可以看到整个AI助理的输出了

## 结论

通过使用多个AI助理的方式可以完成更加复杂的工作，这也是一种趋势，我相信在不久的将来，通过这种方式，能极大的提高人类在各个行业中的效率，就我自己使用本地的大模型来说还是有一些问题，例如生成的代码就算被评判助理认为可执行，实际执行过程还是会出错，但是基于chatgpt-4的模型，是能够正确的运行需求并生成响应的图片的。
![result](https://res.cloudinary.com/xinta/image/upload/v1705028527/blogimage/cars_plot.png)