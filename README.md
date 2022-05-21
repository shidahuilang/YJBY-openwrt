- 为防止个别系统没安装curl，使用一键编译命令之前选执行一次安装curl命令:
```sh
sudo apt-get update && sudo apt-get install -y curl
```
---
- ubuntu一键编译openwrt命令
```sh
bash <(curl -fsSL https://raw.githubusercontent.com/shidahuilang/YJBY-openwrt/main/local.sh)
```
---
- 制作config配置文件

```sh
bash <(curl -fsSL https://raw.githubusercontent.com/shidahuilang/YJBY-openwrt/main/makeconfig.sh)
```

- WSL报错：Error: 0x800701bc  执行更新命令
```
wsl --update
```

- (WSL)修改安装目录
- 首先查看所有分发版本
wsl -l -v
出分发版为tar文件到i盘
wsl --export Ubuntu-20.04 i:\Ubuntu-20.04.tar
注销当前分发版
wsl --unregister Ubuntu-20.04
重新导入并安装分发版在i:\ubuntu
wsl --import Ubuntu-20.04 i:\ubuntu i:\Ubuntu-20.04.tar --version 2
设置默认登陆用户为安装时用户名
ubuntu2004 config --default-user shuai
删除tar文件(可选)
del i:\Ubuntu-20.04.tar
```
