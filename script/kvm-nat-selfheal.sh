#!/usr/bin/env bash
set -euo pipefail

FWO=/usr/bin/firewall-offline-cmd
FW=/usr/bin/firewall-cmd
IP=/usr/sbin/ip

SUBNET="192.168.122.0/24"
FROM_IP="192.168.122.1"
PREF="1000"

# 1) 确保 libvirt 子网绕开 Clash 的策略路由（重复执行安全）
$IP -4 rule add pref "$PREF" from "$SUBNET" lookup main 2>/dev/null || true

# 2) 计算“FROM 192.168.122.1”去外网时应该走哪个出口接口
UPLINK_DEV="$($IP -4 route get 8.8.8.8 from "$FROM_IP" | sed -n 's/.* dev \([^ ]*\) .*/\1/p' | head -n1)"
if [[ -z "${UPLINK_DEV:-}" ]]; then
  echo "Cannot detect uplink dev for $FROM_IP" >&2
  exit 1
fi

# 3) 删除旧的 direct rules（避免接口变更后残留）
# 注意：这里用 offline-cmd 改永久配置，不依赖 firewalld 当前状态
$FWO --direct --remove-rule ipv4 filter FORWARD 0 -i virbr0 -o wlp4s0 -j ACCEPT 2>/dev/null || true
$FWO --direct --remove-rule ipv4 filter FORWARD 1 -i wlp4s0 -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
$FWO --direct --remove-rule ipv4 nat POSTROUTING 0 -s "$SUBNET" -o wlp4s0 -j MASQUERADE 2>/dev/null || true

# 若你未来有别的 uplink 名字，也可以继续加 remove-rule 模板（可选）
# ...（保持简洁，先不加更多）

# 4) 写入当前 uplink 对应的 direct rules（永久）
$FWO --direct --add-rule ipv4 filter FORWARD 0 -i virbr0 -o "$UPLINK_DEV" -j ACCEPT
$FWO --direct --add-rule ipv4 filter FORWARD 1 -i "$UPLINK_DEV" -o virbr0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
$FWO --direct --add-rule ipv4 nat POSTROUTING 0 -s "$SUBNET" -o "$UPLINK_DEV" -j MASQUERADE

# 5) 如果 firewalld 正在跑，reload 让规则立刻生效
if systemctl is-active --quiet firewalld; then
  $FW --reload || true
fi

echo "kvm-nat-selfheal: uplink=${UPLINK_DEV} ok"
