#!/usr/bin/env bash
#
# report.sh — 每天 8 点和 20 点推送平均负载、平均内存使用率与磁盘使用情况
#             并在超过阈值时立刻告警

set -euo pipefail
IFS=$'\n\t'

# ---------- 配置区 ----------
# 企业微信机器人 Webhook（必填）
WEBHOOK_URL='https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=dc5f18f1-0d51-4f45-831c-810ecf97b994'

# 日志目录（本地保存）
LOGDIR="/var/log/sysinfo"
mkdir -p "$LOGDIR"
LOGFILE="${LOGDIR}/daily-$(date +%F).log"

# 阈值配置
LOAD_ALERT_THRESHOLD=1.00       # 1 分钟平均负载告警阈值
MEM_ALERT_THRESHOLD=80.00      # 平均内存使用率告警阈值（%）
SAMPLE_COUNT=20                # 采样次数，用于计算平均内存

# 系统命令绝对路径
CMD_DATE="/bin/date"
CMD_CUT="/usr/bin/cut"
CMD_FREE="/usr/bin/free"
CMD_AWK="/usr/bin/awk"
CMD_SLEEP="/bin/sleep"
CMD_DF="/bin/df"
CMD_CURL="/usr/bin/curl"
CMD_ECHO="/bin/echo"
CMD_MKDIR="/bin/mkdir"

# ---------- 1. 计算指标 ----------
TIMESTAMP="$($CMD_DATE '+%Y-%m-%d %H:%M:%S')"

# 1.1 平均负载（取 1 分钟平均）
LOAD1=$($CMD_CUT -d ' ' -f1 /proc/loadavg)

# 1.2 平均内存使用率（SAMPLE_COUNT 次采样求平均）
MEM_USED_PCT=$(
  for i in $(seq 1 $SAMPLE_COUNT); do
    $CMD_FREE | $CMD_AWK '/^Mem:/ {printf("%.2f\n",$3/$2*100)}'
    $CMD_SLEEP 1
  done | $CMD_AWK '{sum+=$1} END {printf("%.2f", sum/NR)}'
)

# 1.3 当前磁盘使用情况（根分区）
DISK_USAGE=$($CMD_DF -h / | $CMD_AWK 'NR==2{print $5 " of " $2}')

# ---------- 2. 本地日志写入 ----------
{
  $CMD_ECHO "=== $TIMESTAMP ==="
  $CMD_ECHO "Avg Load(1m): $LOAD1"
  $CMD_ECHO "Avg Mem%: $MEM_USED_PCT%"
  $CMD_ECHO "Disk / : $DISK_USAGE"
  $CMD_ECHO
} >> "$LOGFILE"

# ---------- 3. 构造消息 ----------
MSG=$(
  cat <<EOF
[$TIMESTAMP]
- 平均负载(1m): ${LOAD1}
- 平均内存使用: ${MEM_USED_PCT}%
- 磁盘 / 使用: ${DISK_USAGE}
EOF
)

# ---------- 4. 即时阈值告警（如超出阈值则优先推送） ----------
ALERTS=()
# 比较浮点数需用 awk 或 bc
if awk "BEGIN {exit !($LOAD1 > $LOAD_ALERT_THRESHOLD)}"; then
  ALERTS+=("平均负载 (1m) ${LOAD1} > 阈值 ${LOAD_ALERT_THRESHOLD}")
fi
if awk "BEGIN {exit !($MEM_USED_PCT > $MEM_ALERT_THRESHOLD)}"; then
  ALERTS+=("平均内存使用 ${MEM_USED_PCT}% > 阈值 ${MEM_ALERT_THRESHOLD}%")
fi

# 如果有告警信息，就用 alertMsg 覆盖 MSG
if [ ${#ALERTS[@]} -gt 0 ]; then
  alertMsg="[$TIMESTAMP] 系统告警：
$(printf '%s\n' "${ALERTS[@]}")
"
  MSG="$alertMsg"
fi

# ---------- 5. 企业微信推送 ----------
# JSON 消息内容要转义换行，简单拼接：
MSG_ESCAPED=$("$CMD_ECHO" "$MSG" | sed ':a;N;s/\n/\\n/g;ta' | sed 's/"/\\"/g')
JSON_PAYLOAD="{\"msgtype\":\"text\",\"text\":{\"content\":\"$MSG_ESCAPED\"}}"

# 推送到企业微信
$CMD_CURL -s -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d "$JSON_PAYLOAD" > /dev/null 2>&1

exit 0
