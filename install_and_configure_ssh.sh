#!/bin/sh

# 更新软件包数据库
echo "更新软件包数据库..."
apk update

# 安装 OpenSSH
echo "安装 OpenSSH..."
apk add openssh

# 定义 SSH 配置文件的路径
SSHD_CONFIG="/etc/ssh/sshd_config"

# 检查 sshd_config 文件是否存在
if [ ! -f "$SSHD_CONFIG" ]; then
  echo "SSH 配置文件 $SSHD_CONFIG 不存在！"
  exit 1
fi

# 如果文件中有 #PermitRootLogin，则去掉注释并修改为 PermitRootLogin yes
if grep -q "^#PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
  echo "已将 #PermitRootLogin 修改为 PermitRootLogin yes"
fi

# 如果文件中有 PermitRootLogin 但值不是 yes，则将其修改为 yes
if grep -q "^PermitRootLogin" "$SSHD_CONFIG"; then
  sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/' "$SSHD_CONFIG"
  echo "已将 PermitRootLogin 修改为 yes"
else
  # 如果不存在该行，直接添加到文件末尾
  echo "PermitRootLogin yes" >> "$SSHD_CONFIG"
  echo "PermitRootLogin yes 已添加到配置文件"
fi

# 启动并设置 SSH 服务为开机自启动
echo "启动 SSH 服务并设置开机自启动..."
rc-service sshd start
rc-update add sshd

# 重启 SSH 服务以应用更改
echo "重启 SSH 服务..."
rc-service sshd restart

echo "SSH 服务已重启，PermitRootLogin 已设置为 yes"
