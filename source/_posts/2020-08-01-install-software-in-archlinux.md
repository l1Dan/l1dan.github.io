---
layout: default\_layout
title: Arch Linux 软件安装
date: 2020-08-01 18:06:56
tags: ArchLinux
categories: 系统
---

# 安装软件篇
## 一、安装系统软件
进入之后会发现两个问题：
1. 终端模拟器没有，通过 `sudo pacmam -S Konsole` 安装
2. 桌面无法正常缩放（VirtualBox 需要），通过 `sudo pacman -S virtualbox-guest-utils` 安装。

这个时候还会发现，要执行命令，就需终端模拟器，要安装终端模拟器就需要执行安装`sudo pacmam -S Konsole`命令，这就陷入死循环了，那么怎么办？
办法1：在安装桌面套件是随便把终端模拟器安装了，但是现在已经没办法安装了。
办法2：重新安装一边系统，记得把终端模拟器安装了（不可取）。
办法3：使用 Archiso 镜像进入安装系统流程，挂载 /mnt 之后安装终端模拟器（费劲）。
办法4：UEFI启动界面时进入字符界面安装终端模拟器（也费劲）。
办法5：
	1. 在现在启动的图形桌面环境下按 `Ctrl+Alt+F3` 组合安装进入字符终端。
	2. 执行 `sudo pacman -Syyu` 更新
	2. 执行 `sudo pacmam -S Konsole` 命令。
	3. 按下 Ctrl+Alt+F1 回到图形界面。完成安装。

### 记得安装 vbox 工具（VirtualBox 需要）
`sudo pacman -S virtualbox-guest-utils`

查看 boxservice.service 服务是否启动
`systemctl list-unit-files | grep vbox` 如果第一项为 disable 则执行如下命令：
	1. `sudo systemctl enable vboxservice.service` 启用 vbox 服务
	2. `reboot` 重启就可以使用了。

### 一个很重要的软件！！！
接下来我们安装一个很重要的软件执行如下命令：
	1. `sudo pacman -S screenfetch`
	2. screenfetch

相信你们看到什么了，没错就是下面这样的，没别的意思，就是想显摆下，满足下虚荣心。好了，装逼装完了，继续安装软件。

### 文件管理器
如果你一步一步跟到这里了，可能还没发现一个问题，就是竟然没找到文件管理器。安装Dolphin文件管理：
`sudo pacman -S dolphin`

### 文件夹
进入 Dolphin 会发现很多默认文件夹都没有，需要自己生成默认文件夹：
	1. `sudo pacman -S xdg-user-dirs`
	2. `sudo xdg-user-dirs-update`
	3. `reboot` 重启之后打开 Dolphin 就可以看到默认文件夹了

### 安装软件图标主题（可选安装）
如果看腻了原生的图标，也可以安装一套自己喜欢的图标，配合 KDE 的深色模式食用更佳。
`sudo pacman -S papirus-icon-theme`


## 二、安装常用桌面软件
### 配置国内源


