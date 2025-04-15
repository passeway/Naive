#!/bin/sh

echo "⚠️ 本操作将清空剩余空间，请确保没有重要数据，继续请按回车，退出请 Ctrl+C"
read

# 卸载现有 TF 卡挂载
umount /dev/mmcblk1p1 2>/dev/null
umount /dev/mmcblk1p2 2>/dev/null

echo "🧹 删除原有分区并创建新分区..."

# 删除旧的 /dev/mmcblk1p2
echo -e "d\n2\nn\np\n2\n\n\nw\n" | fdisk /dev/mmcblk1

# 等待系统刷新分区
sleep 3
echo "✅ 新分区完成，开始格式化为 f2fs..."
mkfs.f2fs -f /dev/mmcblk1p2

# 创建挂载目录并挂载
mkdir -p /mnt/new_overlay
mount -t f2fs /dev/mmcblk1p2 /mnt/new_overlay

echo "📦 复制原有 overlay 数据..."
cp -a /overlay/* /mnt/new_overlay/

# 添加 rc.local 自动挂载逻辑（去重防止重复执行）
grep -q "mount.*mmcblk1p2.*overlay" /etc/rc.local || {
  sed -i "/exit 0/i\\
mkdir -p /mnt/new_overlay\n\
mount -t f2fs /dev/mmcblk1p2 /mnt/new_overlay\n\
mount --move /mnt/new_overlay /overlay\n" /etc/rc.local
}

echo "✅ 所有步骤完成，请重启设备..."
