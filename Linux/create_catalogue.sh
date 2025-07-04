#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# 脚本：创建统一的工作空间目录结构并展示
# 说明：兼容交互式命令行和脚本执行，具备依赖检测与自动安装功能
# ──────────────────────────────────────────────────────────────────────────────

set -euo pipefail
# 设置脚本严格模式
# -e：任意命令出错立即退出
# -u：使用未定义变量时报错退出
# -o pipefail：管道中任一环出错都会触发退出

IFS=$'\n\t'
# 修改字段分隔符，仅用换行和制表符，防止文件名含空格时误拆分

# ─── 配置区 ───────────────────────────────────────────────────────────────────
WORKSPACE="$HOME/workspace"
# 顶层目录，可按需修改；使用 $HOME 保证对任何用户都生效

# ─── 创建目录结构 ────────────────────────────────────────────────────────────
echo "创建目录结构：$WORKSPACE"
mkdir -p "$WORKSPACE"/{notes/{linux,network},projects/{project1,project2}, tmp}

# ─── 检查并安装依赖 ───────────────────────────────────────────────────────────
if ! command -v tree &>/dev/null; then
  # command -v tree：检查 tree 命令是否存在
  # &>/dev/null：屏蔽标准输出与标准错误
  echo "未检测到 tree 命令，正在尝试安装"
  sudo apt-get update           # 更新包索引
  sudo apt-get install -y tree  # 无需交互地安装 tree
fi

# ─── 展示结果 ─────────────────────────────────────────────────────────────────
echo "目录创建完成，当前结构："
tree "$WORKSPACE"
# 用树状图直观展示目录，方便检查

exit 0
