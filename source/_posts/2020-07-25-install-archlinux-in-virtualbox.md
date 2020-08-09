---
layout: default\_layout
title: VirtualBox 安装最新 Arch Linux
date: 2020-07-25 10:06:56
tags: ArchLinux
categories: 系统
---

![][image_0]
---

# 安装系统篇
## 一、准备安装环境
   - Wi-Fi 或 有线网络（保证 VritualBox 可以正常联网）
   - macOS 10.15.6
   - [下载 VirtualBox 和 Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)
   - [下载 Arch Linux ISO 文件](https://www.archlinux.org/download/)

**注意**：在 VirtualBox 新建虚拟机需要打开 EFI 选项
   `Settings -> System -> Motherboard 勾选 Extended Features Enable EFI (special OSes only)`
   ![][image_1]

## 二、预备安装
### 验证启动模式
Archiso 使用 systemd-boot 和 syslinux 分别在 UEFI模式 和 BIOS 模式下启动。
要验证启动模式，可以使用下列命令列出 efivars 目录：

`ls /sys/firmware/efi/efivars`

如果没有出错且显示了目录，则系统以 UEFI 模式启动。反之，则系统可以是以 BIOS 模式或其他模式启动。

*提示：在 (Like) Linux 或 (Like) Unix 系统下 SHELL 环境的命令可以使用 `Tab` 按键补全。*
**注意**：这里是选择 UEFI 启动模式安装的，如果上述命令出错，请检查虚拟机 EFI 设置是否有问题。

### 连接到网络
1. 使用 `ip link` 命令检查系统是否启用了网络接口。
2. 有线网络插上网线就可以（VritualBox 可以跳过）。
3. Wi-Fi 网络使用 `iwctl` 验证无线网络（VritualBox 可以跳过）。
4. 使用 Ping 检查网络连接 `ping -c 3 archlinux.org`。

**注意：** Archiso 安装镜像默认是已经启用 `systemd-network.service`、`systemd-resolved.service` 和 `iwd.service`。所以这里的网络设置可以跳过，但是后面安装好的系统这些工具是没有的，需要自己安装和配置。

### 更新系统时间
`timedatectl set-ntp true`
检查服务状态 `timedatectl status`。

### 建立硬盘分区
这里采用 `parted` 命令分区和 UEFI 分区方案。
查看当前磁盘信息有几种方式：
1. `lsblk` 2. `parted /dev/sda print` 3. `fdisk -l /dev/sda`

### 开始分区
分区方案是：boot = 200Mib，swap ～= 8G，root ～= 22G，剩下的分给 home 分区。下面是分区步骤：
1. `parted /dev/sda` 进入分区模式。
2. `mktable gpt` 采用 `gpt` 分区表（存放引导文件）。
3. `mkpart boot fat32 1M 200M` 建立 `boot` 分区。
4. `mkpart swap linux-swap 200M 8G` 建立 `swap` 分区（如果实体机采用固态硬盘+ >= 8G RAM 方式可以不用建立 swap 分区）。
5. `mkpart root ext4 8G 30G` 建立 `root` 分区。
6. `mkpart home ext4 30G 100%` 建立 `home` 分区（100% 表示使用所有剩下的可用空间）。
7. `print` 查看分区信息是否正确。
8. `quit` 退出分区模式。

### 格式化分区
1. `mkfs.fat -F32 /dev/sda1` 格式化 boot 分区。
2. `mkswap /dev/sda2` 格式化 swap 分区。
3. `mkfs.ext4 /dev/sda3` 格式化 root 分区。
4. `mkfs.ext4 /dev/sda4` 格式化 home 分区。

### 挂在分区
1. `mount /dev/sda3 /mnt` 首先挂载 root 分区。
2. `mkdir /mnt/efi && mount /dev/sda1 /mnt/efi` 创建 efi 文件夹并挂载 boot 分区。
3. `mkdir /mnt/home && mount /dev/sda4 /mnt/home` 创建 home 文件夹并挂载 home 分区。

## 三、系统安装
### 选择镜像源
Archiso Live 系统会自动执行 `reflector` 命令来帮你选择镜像源，所以选择镜像源这一步可以直接跳过。
刷新源 `pacman -Syy`

### 安装必须软件包
`pacstrap /mnt base linux linux-firmware` 使用 `pacstrap` 脚本安装基础软件包和硬件固件。

### 配置系统
使用以下命令生成 fstab 文件。

`genfstab -U /mnt >> /mnt/etc/fstab`

查看配置是否正确。

`cat /mnt/etc/fstab`

### 进入刚刚安装的系统
`arch-chroot /mnt`

### 时区
1. `ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime` 设置时区。
2. `hwclock --systohc` 设置硬件时间。
3. `date` 查看日期时间是否正确。

### 安装文本编辑器（新系统默认没有任何编辑器）
pacman -S vim

*提示：Vim 基本操作。*
`vim /path/file.ext`  进入编辑指定文件。
查找操作：normal 模式下输入 `/` 后面输入查找字符。
删除光标所在的字符或单词：`dw`。
进入编辑模式：`i`。
退出编辑模式：`esc`。
撤销上一步操作：`u`。
退出 Vim 并保存文件：`wq`。
强制退出，不做任何操作：`q!`。

### 本地化设置
1. 使用 `vim /etc/locale.gen`，将 `/etc/locale.gen` 中 `en_US.UTF-8` 和 `zh_CN.UTF-8` 的注释去掉。
2. `locale-gen` 生成 locale 信息。
3. 使用 `vim /etc/locale.conf`，在文件 `/etc/locale.conf ` 中写入 `LANG=en_US.UTF-8` 配置

**注意：** 
1. 不要在 `/etc/locale.conf` 文件中配置为中文 locale，会导致 TTY 乱码。
2. 可以在 `/etc/locale.conf` 中添加 `LANGUAGE=en_US:en_GB:en` 配置。


### 网络配置
创建 hostname 文件并设置主机名
`echo myhostname > /etc/hostname`

配置 hosts 文件
```code
vim /etc/hosts

# 输入以下内容
127.0.0.1	localhost
::1			localhost
127.0.1.1	myhostname.localdomain.myhostname
```

**注意**：`myhostname` 设置为你喜欢的名字。

### 设置 Root 密码
`password` 设置 root 用户密码。

### 创建新用户
添加用户 useradd -m -g "初始组" -G "附加组" -s "登陆shell" "用户"
将新建用户移入wheel组并指定shell为zsh (以后可修改)

1. `pacman -S zsh` 安装 zsh (Arch Linux 默认就是使用 zsh)。
2. useradd -m -G wheel -s /bin/bash username 创建一个名为 username 的新用户。
3. password username 设置用户名为 username 的密码。

### 添加管理员权限
1. `pacman -S sudo` 安装 sudo 命令，会自动生成 sudoers 文件。
2. 将文 件/etc/sudoers 中的 `%wheel ALL=(ALL) ALL` 前面的注释去掉。

*提示：* 如果 `/etc/sudoers` 文件为只读默认，无法修改的话可以做以下操作：
1. `chmod +w /etc/sudoers` 将文件添加一个可写的权限。
2. `vim /etc/sudoers` 修改文件。
3. `chmod 0440 /etc/sudoers` 还原会原来的自读权限。

### 安装和配置 UEFI 引导系统
1. `pacman -S grub efibootmgr`
2. 执行以下命令：
`grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ArchLinux`
3. 使用生成grub配置文件：
`grub-mkconfig -o /boot/grub/grub.cfg`

*其实到这里就可以进入系统了，但是为了避免后面麻烦，还需要安装一些额外的软件工具。*

## 四、配置桌面环境
### 安装网络相关工具
1. `pacman -S iwd wpa_supplicant dialog networkmanager dhcpcd`
2. 启动服务 `systemctl enable NetworkManager && systemctl enable dhcpcd`

### 安装声音相关软件包
`pacman -S alsa-utils pulseaudio pulseaudio-alsa`

### 安装字体
`pacman -S ttf-dejavu wqy-microhei`

### 安装桌面套件
1. `pacman -S xorg` 安装 Xorg
2. `pacman -S plasma` 安装桌面（不要安装 kde-applications，太多不需要的软件，后面可以自己选装。）
3. `systemctl enable sddm` 激活登陆窗口 sddm。

### 重启系统，进入桌面环境
1. `exit` 退出到 Archiso 镜像安装 SHELL 界面。
2. `umount -R /mnt` 卸载 /mnt
3. `reboot` 重启系统

## 完结
Arch Linux 系统的安装基本就完成了，接下来就是系统基本配置和常用软件的安装了，可以看下一篇，常用软件的安装。

[image_0]:	/images/2020/13-archlinux-logo.png
[image_1]:	/images/2020/01-settings-uefi.png




















