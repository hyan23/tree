# tree
A toy multi-tasking, GUI Operating System

## 如何编译

这个项目暂时只能在 Windows 平台编译, 不过稍作修改在你也能在 Linux 编译它,<br/>
要编译, 打开项目文件夹 /make, 运行 make.cmd 即可。

## 如何运行

事实上你不需要自己编译这些文件, 打开项目文件夹 /TREE, 双击 TREE.vbox 即可,<br/>
前提是你的电脑已经安装好最新版本的 VirtualBox 软件。

## 待办

1. LDT
2. 进程的堆

## 以下是笔记

### 异常中断

在用户控制块新增两个字段:<br/>

1. 已分配的内存(链接表)
2. 窗口句柄(字)

在 loader.ss 创建这两个数据结构,<br/>
在 agent.ss 维护这两个数据结构,<br/>
在 task0.ss 销毁这两个数据结构。

### 如何处理

1. 销毁异常进程, 回收已分配资源,
2. 创建可视化进程, 传递必要信息。
