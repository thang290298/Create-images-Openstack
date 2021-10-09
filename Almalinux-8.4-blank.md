# Tài liệu đóng Image AlmaLinux 8.4

## Phần I: Trên KVM host tạo máy ảo AlmaLinux 8.4

### Bước 1. Khởi tạo ổ cứng sử dụng cho máy ảo:

<h3 align="center"><img src = "Images\Centos7-app\1.png"></h3>
<h3 align="center"><img src = "Images\Centos7-app\2.png"></h3>
<h3 align="center"><img src = "Images\Centos7-app\3.png"></h3>

<h3 align="center"><img src = "Images\AlmaLinux\2.png"></h3>

### Bước 2. thực hiện khởi tạo VM
-  `Instances` -> `+` sau đó thực hiện các bước khởi tạo sau: 
<h3 align="center"><img src = "Images\Centos7-app\5.png"></h3>
<h3 align="center"><img src = "Images\Centos7-app\6.png"></h3>

  - Lựa chọn `Custom` và điền các thông tin: Name, VCPU, RAM, HDD, Network rồi chọn `Create`:
<h3 align="center"><img src = "Images\AlmaLinux\1.png"></h3>
- Mount ISO tiến hành cài đặt OS
<h3 align="center"><img src = "Images\AlmaLinux\3.png"></h3>
- chỉnh lại thứ tự boot
<h3 align="center"><img src = "Images\AlmaLinux\4.png"></h3>
### Bước 3. Tạo `Snapshots` trước khi cài đặt OS
<h3 align="center"><img src = "Images\AlmaLinux\5.png"></h3>

### Bước 4. Bật máy ảo và Console vào để cài đặt OS

<h3 align="center"><img src = "Images\AlmaLinux\6.png"></h3>
<h3 align="center"><img src = "Images\AlmaLinux\7.png"></h3>

### Bước 5. Cài đặt OS
- Chọn `Install AlmaLinux 8.4` để tiến hành cài đặt 

<h3 align="center"><img src = "Images/AlmaLinux/8.png"></h3>


- Cấu hình ngôn ngữ chọn `English(English)`

<h3 align="center"><img src = "Images/AlmaLinux/9.png"></h3>

- Cấu hình timezone về Ho_Chi_Minh

<h3 align="center"><img src = "Images/AlmaLinux/10.png"></h3>

<h3 align="center"><img src = "Images/AlmaLinux/11.png"></h3>

- Cấu hình disk để cài đặt 

<h3 align="center"><img src = "Images/AlmaLinux/12.png"></h3>

<h3 align="center"><img src = "Images/AlmaLinux/13.png"></h3>

- Chọn `Standard Partition` cho ổ disk 

<h3 align="center"><img src = "Images/AlmaLinux/14.png"></h3>

- Cấu hình mount point `/` cho toàn bộ disk

<h3 align="center"><img src = "Images/AlmaLinux/15.png"></h3>

- Định dạng lại `ext4` cho phân vùng

<h3 align="center"><img src = "Images/AlmaLinux/16.png"></h3>


- Kết thúc quá trình cấu hình disk 

<h3 align="center"><img src = "Images/AlmaLinux/17.png"></h3>


- Cấu hình network 

<h3 align="center"><img src = "Images/AlmaLinux/18.png"></h3>

- Turn on network cho interface và set hostname

<h3 align="center"><img src = "Images/AlmaLinux/19.png"></h3>

- thay đổi Software Selection : ` Minimal Install`

<h3 align="center"><img src = "Images/AlmaLinux/20.png"></h3>
<h3 align="center"><img src = "Images/AlmaLinux/21.png"></h3>

- - Setup passwd cho root

<h3 align="center"><img src = "Images/AlmaLinux/22.png"></h3>


<h3 align="center"><img src = "Images/AlmaLinux/23.png"></h3>

- Kết thúc cấu hình, bắt đầu quá trình cài đặt OS

<h3 align="center"><img src = "Images/AlmaLinux/24.png"></h3>

- Reboot lại VM sau khi cài đặt hoàn tất

<h3 align="center"><img src = "Images/AlmaLinux/25.png"></h3>

### Bước 6. Chỉnh sửa file XML VM Lưu ý:

- Chỉnh sửa file .xml của máy ảo, bổ sung thêm channel trong (để máy host giao tiếp với máy ảo sử dụng qemu-guest-agent), sau đó save lại

Truy cập Settings > XML > EDIT SETTINGS

<h3 align="center"><img src = "Images\AlmaLinux\26.png"></h3>

Nếu đã tồn tại channel đổi port channel này về port='2' và add channel bình thường

<h3 align="center"><img src = "Images/create-image-ubuntu20.04/29.png"></h3>

Định dạng
```shsh
<h3 align="center"><devices>
<h3 align="center"><channel type='unix'>
    <h3 align="center"><target type='virtio' name='org.qemu.guest_agent.0'/>
    <h3 align="center"><address type='virtio-serial' controller='0' bus='0' port='1'/>
<h3 align="center"></channel>
<h3 align="center"></devices>
```
## Phần II: Cài đặt môi trường
### Bước 1. Cấu hình và cài đặt các gói
Cài đặt `epel-release` và update
```sh
dnf install epel-release -y
dnf update -y
sudo dnf  install zip unzip wget -y
```

### 2. Disable firewalld, SElinux
```sh
systemctl disable firewalld
systemctl stop firewalld

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config
```

Reboot kiểm tra lại firewalld và SElinux

### Bước 3. Cấu hình Network


Disable IPv6:
```sh
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
```

Kiểm tra
```sh
cat /proc/sys/net/ipv6/conf/all/disable_ipv6
```

Lưu ý: Kết quả ra `1` => Tắt thành công, `0` tức IPv6 vẫn bật

### Bước 4. Cấu hình SSH
```sh
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/g' /etc/ssh/sshd_config 
sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/g' /etc/ssh/sshd_config 
systemctl restart sshd
```

### Bước 5. Điều chỉnh timezone
Đổi timezone về `Asia/Ho_Chi_Minh`
```sh
timedatectl set-timezone Asia/Ho_Chi_Minh
```
### Bước 6. Cài đặt chronyd
```sh
dnf install chrony -y
sed -i 's|server 1.vn.pool.ntp.org iburst|server 162.159.200.123 iburst|g' /etc/chrony.conf
systemctl enable --now chronyd 
hwclock --systohc
```
### Bước 7. Thay đổi nameserver
`vi /etc/resolv.conf`
```sh
# Generated by NetworkManager
search localdomain
nameserver 8.8.8.8
```
`chattr +i /etc/resolv.conf`
### Bước 8. Tạo Snapshot Begin

## Phần II: Cài đặt một số dịch vụ cần thiết cho Template

- Cài đặt acpid nhằm cho phép hypervisor có thể reboot hoặc shutdown instance.

``` sh 
dnf install acpid -y
systemctl enable acpid
```

- Cài đặt qemu guest agent, kích hoạt và khởi động qemu-guest-agent service

``` sh 
dnf install -y qemu-guest-agent
systemctl enable qemu-guest-agent.service
systemctl start qemu-guest-agent.service
```


> **Lưu ý:**
> 
> Để sử sụng qemu-agent, phiên bản selinux phải > 3.12
> 
> `rpm -qa | grep -i selinux-policy`
> 
> Để có thể thay đổi password máy ảo thì phiên bản qemu-guest-agent phải >= 2.5.0
> 
> `qemu-ga --version`

- Cấu hình console

Để sử dụng nova console-log, bạn cần thay đổi option cho `GRUB_CMDLINE_LINUX` và lưu lại 

``` sh
sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto"/GRUB_CMDLINE_LINUX="crashkernel=auto console=tty0 console=ttyS0,115200n8"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```
- Disable Default routing

``` sh
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
```

- Xóa thông tin card mạng
``` sh
rm -f /etc/sysconfig/network-scripts/ifcfg-ens3
```

- Để sau khi boot máy ảo, có thể nhận đủ các NIC gắn vào:

```sh 
cat << EOF >> /etc/rc.local
for iface in \$(ip -o link | cut -d: -f2 | tr -d ' ' | grep ^eth)
do
   test -f /etc/sysconfig/network-scripts/ifcfg-\$iface
   if [ \$? -ne 0 ]
   then
       touch /etc/sysconfig/network-scripts/ifcfg-\$iface
       echo -e "DEVICE=\$iface\nBOOTPROTO=dhcp\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-\$iface
       ifup \$iface
   fi
done
EOF
```
- Cài đặt CMDlog và  welcome Display
```
curl -Lso- https://raw.githubusercontent.com/thang290298/CMD-Log/main/cmdlog.sh | bash
wget https://raw.githubusercontent.com/thang290298/Create-images-Openstack/main/Linux-Login.sh -O /etc/profile.d/linux-login.sh && chmod +x /etc/profile.d/linux-login.sh

```
Log out rồi login lại kiểm tra:
  - Log cmd: /var/log/cmdlog.log
  - Giao diện sau khi login:
      ```
    Welcome to Cloud365 | nhanhoa.com

    Tue 23 Mar 2021 03:04:17 PM +07

    ______ __                   __ _____  _____  ______
    / ____// /____   __  __ ____/ /|__  / / ___/ / ____/
    / /    / // __ \ / / / // __  /  /_ <h3 align="center">< / __ \ /___ \
    / /___ / // /_/ // /_/ // /_/ / ___/ // /_/ /____/ /
    \____//_/ \____/ \__,_/ \__,_/ /____/ \____//_____/

    * Trang chu NhanHoa : https://nhanhoa.com/
    * Cloud365          : https://cloud365.vn/
    * Portal            : https://portal.cloud365.vn/
    * Huong dan su dung : https://support.cloud365.vn/
    * Email ho tro      : support@nhanhoa.com

    *----------------------------------------------------*

    root@cloud:~# 
    ```
Kiểm tra lỗ hổng CVE-2021 và dọn dẹp
```
sudoedit -s /
```
- Kết quả trả ra như sau:
```
TH1: "sudoedit: /: not a regular file" -> sudo có lỗ hổng
TH2:  "usage: sudoedit [-AknS] [-r role] [-t type] [-C num] [-g group] [-h host] [-p prompt] [-T timeout] [-u user] file" -> sudo đã được vá.
```
- Cài đặt cloud-init và cloud-utils:

``` sh
dnf -y install cloud-utils-growpart cloud-init 
```
- Để máy ảo trên OpenStack có thể nhận được Cloud-init cần thay đổi cấu hình mặc định bằng cách sửa đổi file `/etc/cloud/cloud.cfg`. 

``` sh
sed -i 's/disable_root: 1/disable_root: 0/g' /etc/cloud/cloud.cfg
sed -i 's/ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg
sed -i 's/name: cloud-user/name: root/g' /etc/cloud/cloud.cfg
```


- Thêm quyền thực thi cho file `/etc/rc.local`
```sh
chmod +x /etc/rc.local 
```

- Xóa file hostname

``` sh
rm -f /etc/hostname
```

- Clean all 
``` sh 
dnf clean all
# Xóa last logged
rm -f /var/log/wtmp /var/log/btmp
# Xóa history 
rm -f /root/.bash_history
> /var/log/cmdlog.log
history -c
```


> ## Tắt VM -> Snapshot: Final
# Phần III. Tổi ưu và dẩy images

### Bước 1: Sử dụng lệnh virt-sysprep để xóa toàn bộ các thông tin máy ảo

```
virt-sysprep -d OPS_AlmaLinux_8.4
```

### Bước 2: Tối ưu kích thước image:
```
virt-sparsify --compress --convert qcow2 /var/lib/libvirt/images/OPS_AlmaLinux8.4_Template.qcow2 OPS_AlmaLinux_Template
```

### Bước 3: Upload image lên glance và sử dụng
- trước tiên cần Coppy file images sang note Controller
- Convert images về định dạng raw
```
qemu-img convert -O raw OPS_AlmaLinux_Template OPS_AlmaLinux_Template.raw
```
- Đẩy image lên hệ thống và sử dụng
```
glance image-create --name OPS_AlmaLinux_Template \
--file /root/image-create-ops-test/OPS_AlmaLinux_Template.raw \
--disk-format raw \
--container-format bare \
--visibility=public \
--property hw_qemu_guest_agent=yes \
--min-disk 10 --min-ram 1024 --progress
```


### Bước 4: Nội dung cloud-init
```
#cloud-config
password: '{vps_password}'
chpasswd: { expire: False }
ssh_pwauth: True
```