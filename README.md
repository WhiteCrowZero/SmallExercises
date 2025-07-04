根据我学习的这些知识，设计一些小项目、小实验，用于巩固验证我学习到的知识，项目尽量简短，保持在一个小时内的工作量，主要为了知识的巩固和实践。同时注意，给出的项目或实验一定要有一定的实用价值，不做单纯的题目训练。

知识目录
```
1. 目录结构
├── 树状结构
├── 重要目录
└── 万物皆文件（映射）

2. vim 使用
├── 三种模式
└── 常用命令

3. 用户管理
├── 添加用户
├── 设置密码
├── 删除用户
├── 切换用户
├── 用户组
├── 查看用户信息
└── 相关文件

4. 实用命令
├── 运行级别
├── 帮助命令
├── 系统变量
├── 重新关机
├── 文件目录相关命令
├── 搜索与查找
├── 时间日期相关
├── 压缩解压指令
└── 其他指令

5. 组和权限
├── Linux 组
└── 权限

6. 定时任务
├── cron（周期性）
└── at（一次性）

7. 磁盘分区、挂载
├── 硬盘说明
├── 查看硬盘及挂载信息
├── 磁盘挂载
└── 磁盘空间分析

8. 网络配置
├── NAT模式原理
├── 常用命令
├── 指定IP
├── hostname和hosts映射
└── 主机名解析过程

9. 进程管理
├── 进程介绍
├── 查看进程
├── 终止进程
├── 守护进程
├── 服务（service）管理
├── 防火墙
├── 动态监控进程
└── 监控网络状态

10. 网络下载
├── apt
├── rpm（简单了解）
└── 总结

```
练习实验/脚本

下面给出 5 个基于前五章知识的「1 小时内实用小项目／实验」，每个项目都有实际场景意义，不是纯刷题，能够帮助你将所学知识应用起来。

---

## 1. 搭建个人资料存放结构（目录结构）

**场景**：你想为自己搭建一个“学习笔记与项目”统一管理的文件夹体系。
**目标**：用命令一次性创建并验证一个清晰的树状目录。

* **步骤**

  1. 在 `$HOME` 下新建顶层目录 `~/workspace`。
  2. 在其中创建三级目录：

     ```
     ~/workspace/
     ├── notes/       # 笔记
     │   ├── linux/
     │   └── network/
     ├── projects/    # 小项目
     │   ├── project1/
     │   └── project2/
     └── tmp/         # 临时文件
     ```
  3. 用 `tree`（如无则 `apt install tree`）或组合 `find . -type d` 输出目录结构，确认无误。
* **收获**：熟悉常用目录命令、理解“万物皆文件”的思路。

---

## 2. 快速编辑模板配置（Vim 三种模式 + 常用命令）

**场景**：有一个 Nginx 配置模板 `nginx.conf.tpl`，其中有多处 `{{SERVER_NAME}}` 需要批量替换为你的域名。
**目标**：用 Vim 一次性替换、复制多行并保存到新文件。

* **步骤**

  1. `cp nginx.conf.tpl mysite.conf`；
  2. `vim mysite.conf`，进入**普通模式**，用 `:%s/{{SERVER_NAME}}/example.com/g` 完成全局替换；
  3. 在文件顶部插入注释：普通模式 `ggO# Auto-generated by me<ESC>`；
  4. 保存并退出：`:wq`。
  5. 用 `vim -u NONE -N mysite.conf +"1,5y" +"!head -n5"` 演示批量复制粘贴（选作）。
* **收获**：巩固三种模式切换、快速查找与替换、插入与复制。

---

## 3. 批量用户授权脚本（用户管理 + 用户组）

**场景**：公司新来一批实习同学，需要批量建用户、设置初始密码并加入 `interns` 组。
**目标**：写一个小 Bash 脚本，一次性完成新增 3 个用户并打印结果。

* **步骤**

  1. 新建脚本 `add_interns.sh`，在脚本里写：

     ```bash
     #!/usr/bin/env bash
     GROUP=interns
     users=(alice bob charlie)
     [ "$(getent group $GROUP)" ] || sudo groupadd $GROUP
     for u in "${users[@]}"; do
       sudo useradd -m -s /bin/bash -G $GROUP $u
       echo "$u:ChangeMe123" | sudo chpasswd
       echo "Created $u in group $GROUP"
     done
     ```
  2. `chmod +x add_interns.sh && ./add_interns.sh`；
  3. `getent passwd alice bob charlie` 和 `getent group interns` 验证。
* **收获**：脚本化用户管理、理解用户／组的概念和相关文件。

---

## 4. 一键系统快照与查找（实用命令合集）

**场景**：定期备份你的项目并能快速定位其中 `.log` 文件。
**目标**：写一个命令链，打包当前项目并列出其中所有 `.log` 文件。

* **步骤**

  1. 进入项目根：`cd ~/workspace/projects/project1`；
  2. 一行命令打包并列出：

     ```bash
     tar czf ~/tmp/project1_$(date +%Y%m%d_%H%M).tar.gz . \
       && tar tf ~/tmp/project1_*.tar.gz | grep '\.log$'
     ```
  3. 如果想查看打包后每个文件大小：

     ```bash
     tar tzvf ~/tmp/project1_*.tar.gz | less
     ```
* **收获**：熟悉 `tar` 的创建、列表、搜索操作，以及管道／逻辑与命令联用。

---

## 5. 细粒度权限管理（组和权限）

**场景**：你与同学协作编辑同一文档，需要既共享又防止误删。
**目标**：用用户组和 ACL（Access Control Lists）保证“组内可写、组外只读”。

* **步骤**

  1. 假设用户组 `team` 已存在，文件在 `~/workspace/shared/report.doc`；
  2. `sudo chgrp team report.doc`；
  3. `chmod 640 report.doc`（owner 可读写，组可读，其他无权限）；
  4. 若需更细粒度，用 ACL：

     ```bash
     sudo setfacl -m g:team:rw report.doc
     sudo setfacl -m o::r report.doc
     getfacl report.doc
     ```
* **收获**：掌握 Linux 传统权限与 ACL 应用场景，提升协作安全性。

---

> 每个实验都控制在 ~~1 小时内完成，涵盖目录、编辑、用户、命令和权限五大模块，又都符合「实用场景」。如果需要脚本模板或深入讲解，随时告诉我~~


下面给出 5 个基于后面五章（6–10）的「1 小时内实用小项目／脚本实验」，每个实验都围绕真实场景，综合运用定时任务、磁盘挂载、网络配置、进程管理和包管理等知识。

---

## 实验 6.1：定时增量备份与一次性恢复

**场景**：你想每天凌晨增量备份家目录，并在需要时用 `at` 安排一次性恢复任务。
**目标**：写两段脚本／命令，一段放到 `cron`，一段用 `at` 恢复备份。

1. **准备**

   * 创建备份目录：`mkdir -p ~/backups/{daily,restore}`
2. **增量备份脚本** `/usr/local/bin/inc_backup.sh`

   ```bash
   #!/usr/bin/env bash
   SRC=~/workspace
   DST=~/backups/daily/$(date +%F)
   mkdir -p "$DST"
   rsync -a --delete --link-dest=~/backups/daily/$(date -d 'yesterday' +%F) "$SRC"/ "$DST"/
   ```

   * `chmod +x` 并测试一次。
3. **部署到 Cron**

   * `crontab -e` 添加：

     ```
     0 2 * * * /usr/local/bin/inc_backup.sh
     ```
4. **一次性恢复命令**

   * 写一个小脚本 `/usr/local/bin/restore_backup.sh`，参数是日期：

     ```bash
     #!/usr/bin/env bash
     SRC=~/backups/daily/$1
     DST=~/backups/restore
     rm -rf "$DST" && mkdir -p "$DST"
     rsync -a "$SRC"/ "$DST"/
     echo "Restore of $1 done at $(date)"
     ```
   * 测试：`echo "/usr/local/bin/restore_backup.sh 2025-05-13" | at now +1 minute`
5. **验证**

   * 查看 `~/backups/restore` 内容，确认文件恢复。

> **收获**：掌握 `cron` 的周期任务与 `at` 的一次性任务，学会用 `rsync` 做增量备份。

---

## 实验 7.1：模拟硬盘分区与挂载

**场景**：没有额外物理盘，想用文件模拟一个分区、格式化并挂载后测试读写。
**目标**：用一个 100 MB 的文件当“虚拟盘”，分区、格式化、挂载并做空间分析。

1. **创建文件并关联 loop 设备**

   ```bash
   fallocate -l 100M ~/vdisk.img
   sudo losetup -fP ~/vdisk.img     # 自动分配 /dev/loopX 和 loopXp1
   losetup -l | grep vdisk.img
   ```
2. **分区（使用 parted）**

   ```bash
   sudo parted /dev/loopX --script mklabel msdos mkpart primary ext4 1MiB 100%
   ```
3. **格式化并挂载**

   ```bash
   sudo mkfs.ext4 /dev/loopXp1
   mkdir -p ~/mnt/vdisk
   sudo mount /dev/loopXp1 ~/mnt/vdisk
   ```
4. **测试读写与空间分析**

   ```bash
   dd if=/dev/zero of=~/mnt/vdisk/test.bin bs=1M count=10
   df -h ~/mnt/vdisk
   sudo umount ~/mnt/vdisk
   losetup -d /dev/loopX
   ```

> **收获**：实践 `losetup`、`parted`、`mkfs`、`mount` 与 `df`，理解“万物皆文件”的分区挂载过程。

---

## 实验 8.1：搭建简单 NAT 网络共享

**场景**：你的笔记本连到公司有线网，没有独立公网 IP，想在虚拟机（或另一台机器）上共享网络。
**目标**：给虚拟网卡设定静态 IP，开 `iptables` 做 NAT，测试能否上网。

1. **网络接口配置**

   * 假设宿主机 `eth0` 通外网，虚拟机用 `eth1`。
   * 编辑 `/etc/network/interfaces`（或用 `nmcli`）给 `eth1` 配：

     ```
     iface eth1 inet static
       address 192.168.50.1
       netmask 255.255.255.0
     ```
   * `sudo ifup eth1`。
2. **启用 IP 转发**

   ```bash
   echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
   ```
3. **配置 iptables NAT**

   ```bash
   sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
   sudo iptables -A FORWARD -i eth1 -j ACCEPT
   ```
4. **虚拟机端设置**

   * 在虚拟机里设网关 `192.168.50.1`，DNS 用 8.8.8.8。
   * 测试 `ping 8.8.8.8`，`curl http://example.com`。
5. **持久化**（选做）

   * 把 sysctl 和 iptables 规则写到 `/etc/rc.local` 或者创建 Systemd 单元。

> **收获**：理解 NAT 原理、常用命令、IP 转发及网络地址映射。

---

## 实验 9.1：自定义守护进程与服务管理

**场景**：写一个简单的日志守护脚本，每隔 10 秒钟记录一次系统负载到文件，并作为服务管理。
**目标**：用 `while true` + `sleep` 实现守护进程，写 Systemd unit 启动/停止/重启。

1. **守护脚本** `/usr/local/bin/load_logger.sh`

   ```bash
   #!/usr/bin/env bash
   LOG=/var/log/load_logger.log
   while true; do
     echo "$(date +'%F %T') load: $(awk '{print $1}' /proc/loadavg)" >> $LOG
     sleep 10
   done
   ```

   `chmod +x` 并手动运行测试。
2. **Systemd 服务单元** `/etc/systemd/system/load-logger.service`

   ```ini
   [Unit]
   Description=Load Logger Service

   [Service]
   ExecStart=/usr/local/bin/load_logger.sh
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```
3. **管理与监控**

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now load-logger
   journalctl -u load-logger -f    # 实时查看
   sudo systemctl status load-logger
   sudo systemctl stop load-logger
   ```
4. **验证**

   * 查看 `/var/log/load_logger.log`，确认日志写入；
   * 停止服务，确认日志停止。

> **收获**：掌握守护进程模式、Systemd service 管理、日志监控。

---

## 实验 10.1：离线包镜像与多源下载脚本

**场景**：你在离线环境要安装常用软件，想提前把 `apt` 或 `rpm` 包离线下载并管理仓库。
**目标**：写脚本批量下载一组包到本地目录，并生成一个简单的本地仓库索引。

1. **列出要下载的软件**

   ```bash
   pkgs=(vim git curl htop)
   mkdir -p ~/pkgs/apt
   ```
2. **批量下载 `.deb`**

   ```bash
   for p in "${pkgs[@]}"; do
     apt-get download "$p"
     mv *.deb ~/pkgs/apt/
   done
   ```
3. **生成本地仓库**

   ```bash
   cd ~/pkgs/apt
   dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
   ```
4. **本地源配置**（选做）

   * 在 `/etc/apt/sources.list.d/local.list` 写：

     ```
     deb [trusted=yes] file:/home/you/pkgs/apt ./
     ```
   * `sudo apt update && apt install vim`（从本地源）。
5. **RPM 简易镜像**（辅助）

   ```bash
   mkdir -p ~/pkgs/rpm
   for p in "${pkgs[@]}"; do
     yumdownloader --destdir=~/pkgs/rpm "$p"
   done
   createrepo ~/pkgs/rpm
   ```

> **收获**：熟练 `apt-get download`、`dpkg-scanpackages`、`yumdownloader`、`createrepo`，掌握本地仓库搭建与包管理。

---

以上 5 个实验综合运用了后五章的核心知识，每个都控制在 1 小时内完成，且贴近真实场景，助你快速巩固并形成可复用脚本。祝你练习顺利！


下面再给出 5 个**综合性强、实用性强**的中型项目/实验，每个耗时约 2–3 小时，可用于最终巩固与验收。每个项目都尽量涵盖多章内容，生成可复用脚本或配置。

---

## 项目 1：家庭/实验室“全栈”网络共享与监控平台

**目标**

* 搭建一台 Linux 机器，既做上网网关（NAT/FW），又做流量/进程监控，并通过 Web 界面查看。

**涉及知识**

* 网络配置（NAT、iptables、静态 IP）
* 进程管理（守护进程、Systemd）
* 定时任务（Cron + 日志轮转）
* 磁盘挂载与空间分析
* 用户与权限（为监控用户创建专门账号）

**大纲**

1. **网络共享**

   * 给内网接口（如 eth1）分配静态 IP
   * 配置 iptables 做 MASQUERADE
   * 编写脚本 `/usr/local/bin/netshare.sh` 并用 Systemd 启动
2. **流量与进程监控**

   * 编写守护脚本 `/usr/local/bin/monitor.sh`：每分钟采集 `vnstat`/`iftop` 数据、`ps` 列表，写入日志
   * 写 Systemd 单元并启用
3. **Web 可视化**

   * 用最简单的 Python Flask（或 Node.js）读取日志并展示图表（可用 ASCII 表格）
   * 配置 Nginx 反向代理
4. **定时任务与日志轮转**

   * 用 Cron 调度每晚清理 7 天前的日志
   * 用 `logrotate` 做日志切割
5. **验证**

   * 外网设备通过内网接入上网
   * 在 Web 页面查看实时/历史流量和进程

---

## 项目 2：可扩展的备份与恢复管理系统

**目标**

* 实现一个支持多用户、可挂载多个备份磁盘的“备份管理”平台，并能一键恢复。

**涉及知识**

* 磁盘分区、挂载（Loop or LVM）
* 目录结构、万物皆文件
* 脚本化（Bash + 参数解析）
* 用户与权限（组、ACL）
* 定时任务（Cron）

**大纲**

1. **准备备份介质**

   * 用 `fallocate`+`losetup` 创建两个 1 GB 的虚拟磁盘
   * 分区、格式化为 ext4，并挂载到 `/mnt/backup1`、`/mnt/backup2`
2. **脚本 `/usr/local/bin/bkp_mgr.sh`**

   * 子命令 `init`: 初始化目录 `/mnt/backupX/<用户>` 并设置 ACL
   * 子命令 `backup <user>`：rsync 家目录到每个挂载点
   * 子命令 `restore <user> <date>`：从指定日期目录恢复
3. **权限管理**

   * 每个用户属于备份组 `bkpgrp`，只有组内读写自己的备份目录
4. **定时任务**

   * Cron 安排每天凌晨自动备份所有用户
   * Cron 安排每月一日清理 6 个月前的老备份
5. **验证**

   * 模拟两个用户，测试初始化、备份、恢复、清理功能

---

## 项目 3：本地软件仓库 + 离线部署脚本

**目标**

* 在一台服务器上搭建本地 APT/RPM 仓库，并写脚本自动同步指定软件包，其他机器通过本地源安装。

**涉及知识**

* 网络配置（内部网络、文件协议）
* 磁盘挂载
* 包管理（apt、dpkg-scanpackages、yumdownloader、createrepo）
* 服务管理（Nginx/HTTPd）
* 用户管理（repo 用户、权限）

**大纲**

1. **准备**

   * 挂载大容量存储到 `/srv/repos`
   * 新建系统用户 `repo` 属于 `www-data` 组
2. **脚本 `/usr/local/bin/sync_repo.sh`**

   * APT 部分：`apt-get download` 指定包、`dpkg-scanpackages` 更新 `Packages.gz`
   * RPM 部分：`yumdownloader` + `createrepo`
   * 每次运行生成日志
3. **Web 服务**

   * 配置 Nginx：`location /repo/apt` 和 `/repo/rpm`
   * 静态文件服务，权限仅限 `repo` 用户可写
4. **客户端配置**

   * 生成示例 `/etc/apt/sources.list.d/local.list`
   * RPM 客户端配置 `.repo` 文件
5. **定时自动同步**

   * Cron 每天/每周运行
6. **验证**

   * 客户端通过内网 URL 成功安装或更新软件

---

## 项目 4：轻量级 CI/CD 管道原型

**目标**

* 为一个简单的 GitHub/My Git 仓库实现“自动拉取→测试→部署”流程。

**涉及知识**

* 用户与权限（为 CI 创建专用用户）
* 目录结构（workspace、build、release）
* Vim 脚本（可选，用于编辑配置）
* Systemd +守护进程
* 网络（SSH key、HostKeyMapping）
* 定时任务或 inotify

**大纲**

1. **环境准备**

   * 新用户 `ci`，SSH 公钥部署
   * 在 `/home/ci/workspace` 配置 bare Git 仓库
2. **Webhook 或轮询脚本**

   * 简单脚本 `/usr/local/bin/ci_runner.sh`：

     1. `git fetch` + `git reset --hard origin/master`
     2. 进入项目，执行测试脚本
     3. 构建产物复制到 `/var/www/html/app`
   * 用 inotifywait 或 Cron 每分钟检查更新
3. **服务管理**

   * Systemd unit 管理 `ci_runner.sh`
   * 部署失败/成功发送邮件或写日志
4. **Nginx 配置**

   * 部署目录做静态站点或反向代理到 Node.js/Flask 服务
5. **验证**

   * 向 Git 仓库推一次 commit，观察自动构建与部署

---

## 项目 5：容器化网络实验平台（Docker + 自定义桥接网络）

**目标**

* 利用 Docker 容器模拟一个小型企业网络：内网、DMZ、FW，多容器协同工作。

**涉及知识**

* 网络配置（bridge、macvlan、iptables）
* 磁盘卷挂载
* 用户管理（容器内用户与宿主用户映射）
* 定时任务（容器健康检查）
* 进程/服务管理（在容器内运行 Systemd 或 supervisord）

**大纲**

1. **Docker 网络**

   * 创建三张网桥：`lan_net`、`dmz_net`、`fw_net`
   * 容器 c1(corp)、c2(web)、c3(fw) 分别连到不同网桥
2. **容器配置**

   * c3 作为防火墙，运行轻量级 Linux 镜像，配置 iptables 做 NAT/过滤
   * c2 部署简单 Web 服务，挂载宿主目录 `/srv/web`
   * c1 测试内网访问 DMZ 的 Web 服务
3. **健康检查与日志**

   * 在宿主机写脚本定时 `docker exec fw iptables -L`、`curl http://c3:80`
   * 将结果写到宿主日志并做轮转
4. **权限与卷管理**

   * 挂载宿主卷到 Web 容器并设置 UID/GID 对应
5. **验证**

   * c1 访问 c2 成功，c2 访问外网失败，c1 访问外网通过 c3
   * 容器重启后，网络和卷自动恢复

---

以上 5 个项目综合了**网络、存储、进程、服务、脚本和权限**等多重知识点，每项耗时 2–3 小时，可作为你最后的整合练习与效果验收。祝练习愉快！



