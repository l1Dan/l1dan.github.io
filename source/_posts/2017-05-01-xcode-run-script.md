---
layout: default\_layout
title: 利用Shell和Xcode做些有趣的事
date: 2017-05-01 18:06:56
tags: Shell
categories: 杂谈
---

![image1][image-1]

Shell 在计算机里的作用是用来提供使用

Xcode Run Script 里面的脚本代码的作用时机是在 Build 期间。在这期间我们到底可以做些什么呢？这就需要我们各自发挥自己的想象力了，这里就拿几个实用的例子看下效果。

<!-- more -->

### 动态修改 Bundle 资源

在 Xcode 中经常会看到第三方的 SDK 用中 Bundle 包来对资源进行统一的管理（大多数是对图片的管理）。使用这些第三发库，那么他们的 Bundle 包也是会打包进我们的 App 中的。而这些 Bundle 包我们一般是不做修改的，但是我们需要修改 Bundle 包的话那将是一件比较麻烦的事。一种方法就是手动将我们定制的资源拷贝的别人的 Bundle 包中进行加载。一旦这些库需要更新那么之前手动拷贝的志愿就有可能会存在丢失的情况，如果需要经常更新第三方库那么这种方法是不可取的。Bundle 包的本质就是一个真实存在的文件夹。那么对 Bundle 的操作其实就是跟文件夹的操作一样。这里可以使用 Xcode 自带执行脚本的功能来完成对文件夹操作的麻烦事。

### 添加一个运行脚本的选项

![image2][image-2]

添加完成之后就可以在里面写执行脚本的代码了，这里使用`bash`做演示，其他脚本语言也可以，包括 Swift。我们项目中修改百度地图 SDK 中的 Bundle 图片用的就是这种方式。这种方式的好处就是我们不需要关心第三方库是手动管理还是自动管理，唯一需要关注的就是有没有达到我们想要的效果。实际上我的目的达到了。

![image3][image-3]

### 自动增加版本号

自动增加项目中的版本号我们需要借助 `agvtool：Apple-generic versioning tool`，并做如下设置。
![image4][image-4]
![image5][image-5]

最后我们在 Run Script 中添加一段命令就可以完成版本号自动增加的工作，以后也不需要手动修改版本号了。

```bash
xcrun agvtool new-version -all
```

### 自动打包

先给个链接以后再说：[PPAutoPackageScript][1]

### 友情链接

<a href="/src/cp_img.sh" >cp_img.sh 下载</a>
[agvtool 文档][2]
[PPAutoPackageScript 自动打包][3]

[1]: https://github.com/jkpang/PPAutoPackageScript
[2]: https://developer.apple.com/library/content/qa/qa1827/_index.html
[3]: https://github.com/jkpang/PPAutoPackageScript
[image-1]: /images/2017/xcode-run-script-header.png
[image-2]: /images/2017/xcode-run-script-step.png
[image-3]: /images/2017/xcode-run-script-bash.png
[image-4]: /images/2017/xcode-run-script-version.png
[image-5]: /images/2017/xcode-run-script-info.png
