---
layout: default_layout
title: 利用 Xcode Run Script 做一些有趣的事
date: 2017-05-01 18:06:56
tags: Shell
categories: 杂谈
---

![image1](/images/xcode-run-script-header.jpg)

Xcode Run Script 里面的脚本代码的作用时机是在Build期间。在这期间我们到底可以做些什么呢？这就需要我们各自发挥自己的想象力了，这里就拿几个实用的例子看下效果。
<!-- more -->

### 动态修改Bundle资源
在Xcode中经常会看到第三方的SDK用中Bundle包来对资源进行统一的管理（大多数是对图片的管理）。使用这些第三发库，那么他们的Bundle包也是会打包进我们的App中的。而这些Bundle包我们一般是不做修改的，但是我们需要修改Bundle包的话那将是一件比较麻烦的事。一种方法就是手动将我们定制的资源拷贝的别人的Bundle包中进行加载。一旦这些库需要更新那么之前手动拷贝的志愿就有可能会存在丢失的情况，如果需要经常更新第三方库那么这种方法是不可取的。Bundle包的本质就是一个真实存在的文件夹。那么对Bundle的操作其实就是跟文件夹的操作一样。这里可以使用 Xcode 自带执行脚本的功能来完成对文件夹操作的麻烦事。

### 添加一个运行脚本的选项
![image2](/images/xcode-run-script-step.png)

添加完成之后就可以在里面写执行脚本的代码了，这里使用`bash`做演示，其他脚本语言也可以，包括Swift。我们项目中修改百度地图SDK中的Bundle图片用的就是这种方式。这种方式的好处就是我们不需要关心第三方库是手动管理还是自动管理，唯一需要关注的就是有没有达到我们想要的效果。实际上我的目的达到了。
![image3](/images/xcode-run-script-bash.png)

### 自动增加版本号
自动增加项目中的版本号我们需要借助 [agvtool](https://developer.apple.com/library/content/qa/qa1827/_index.html)：`Apple-generic versioning tool`，并做如下设置。
![image4](https://developer.apple.com/library/content/qa/qa1827/Art/QA1827_Versioning.png)
![image5](https://developer.apple.com/library/content/qa/qa1827/Art/QA1827_InfoPaneInXcode.png)

最后我们在 Run Script 中添加一段命令就可以完成版本号自动增加的工作，以后也不需要手动修改版本号了。
```bash
xcrun agvtool new-version -all
```

### 自动打包
先给个链接以后再说：[PPAutoPackageScript](https://github.com/jkpang/PPAutoPackageScript)
