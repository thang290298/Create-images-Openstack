# Tài liệu đóng Image CentOS7 + Openlitespeed + Wordpress

# Phần I. Khởi tạo VM, cài đặt Openlitespeed và các thành phần 

- Thực hiện cài đặt theo tài liệu cài đặt [CentOS7 + Openlitespeed](https://github.com/thang290298/Create-images-Openstack/blob/main/CentOS7-Openlitespeed.md)



# Phần II. Setup môi trường Wordpress

## Bước 1: cài đặt Openlitespeed và Wordpress ( sử dụng mode 1-click)

- Thực hiện cài đặt với các nội dung:
```sh
WebAdmin password:        0435626533aA
WebAdmin email:           admin@example.com
LSPHP version:            80
MariaDB version:          10.5
Install WordPress:        Yes
WordPress HTTP port:      80
WordPress HTTPS port:     443
WordPress language:       en_US
Web site domain:          wordpress.nhanhoa
MySQL root Password:      Nhanhoa20211
Database name:            wp_db
Database username:        wp_user
Database password:        Nhanhoa20212
WordPress plus:           Yes
WordPress site title:     wordpress.nhanhoa
WordPress username:       admin
WordPress password:       Nhanhoa20213
WordPress location:       /usr/local/lsws/wordpress (New install)
Your password will be written to file:  /usr/local/lsws/password
```
- thực hiện lệnh
```sh
wget https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh
chmod +X ols1clk.sh
chmod +X ols1clk.sh
bash ./ols1clk.sh --lsphp 80 -A 0435626533aA -e admin@example.com --listenport 80 --ssllistenport 443 --mariadbver 10.5 -R Nhanhoa20211 --dbname wp_db --dbuser wp_user --dbpassword Nhanhoa20212 --wordpressplus wordpress.nhanhoa --wpuser admin --wppassword Nhanhoa20213 --sitetitle wordpress.nhanhoa
```


- trong đó:
  - ./ols1clk.sh: Cài đặt Openliet 






## Bước 2: cài đặt phpmyadmin
- Tiến hành download và cài đặt
```sh
cd /usr/local/lsws/Example/html
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip
unzip phpMyAdmin-5.1.1-all-languages.zip
mv phpMyAdmin-5.1.1-all-languages phpmyadmin
cd phpmyadmin
mkdir tmp && chmod 777 tmp
sed -i "s|''|'qtdRoGmbc9{8IZr323xYcSN]0s)r$9b_JUnb{~Xz'|g" /usr/local/lsws/Example/html/phpmyadmin/config.sample.inc.php
mv config.sample.inc.php config.inc.php

```
## Bước 3: Cài đặt Memcached
```sh
cd /usr/local/lsws/
yum -y install memcached
yum install lsphp80-pecl-memcached -y
cd ~
yum -y groupinstall "Development Tools" 
yum -y install autoconf automake zlib-devel openssl-devel expat-devel pcre-devel libmemcached-devel cyrus-sasl*
git clone https://github.com/litespeedtech/lsmcd.git
cd lsmcd
./fixtimestamp.sh
./configure CFLAGS=" -O3" CXXFLAGS=" -O3"
make
sudo make install
```
- Sau khi hoàn thành cài đặt tiến hành thay đổi toàn bộ nội dung file: `/usr/local/lsmcd/conf/node.conf`, nội dung sau khi thay đổi:
```
Repl.HeartBeatReq=30
Repl.HeartBeatRetry=3000
Repl.MaxTidPacket=2048000
Repl.GzipStream=YES
Repl.LbAddrs=127.0.0.1:12340
Repl.ListenSvrAddr=127.0.0.1:12340
REPL.DispatchAddr=127.0.0.1:5501
RepldSockPath=/tmp/repld.usock
CACHED.PRIADDR=127.0.0.1:11000

CACHED.ADDR=127.0.0.1:11211
CACHED.ADDR=UDS:///tmp/lsmcd.sock
#default is 8, it can be bigger depending on cache data amount
Cached.Slices=8
Cached.Slice.Priority.0=100
Cached.Slice.Priority.1=100
Cached.Slice.Priority.2=100
Cached.Slice.Priority.3=100
Cached.Slice.Priority.4=100
Cached.Slice.Priority.5=100
Cached.Slice.Priority.6=100
Cached.Slice.Priority.7=100

Cached.ShmDir=/dev/shm/lsmcd
#If you change the UseSasl or DataByUser configuration options you need to remove the ShmDir folder and contents.
#Cached.UseSasl=true
#Cached.DataByUser=true
#Cached.Anonymous=false
#Cached.UserSize=1000
#Cached.HashSize=500000
#CACHED.MEMMAXSZ=0
#CACHED.NOMEMFAIL=false

##this is the global setting, no need to have per slice configuration. 
User=nobody
Group=nobody
#depends CPU core
CachedProcCnt=4
CachedSockPath=/tmp/cached.usock.
#TmpDir=/tmp/lsmcd
LogLevel=notice
#LogLevel=dbg_medium
LogFile=/tmp/lsmcd.log
```

- Cấu hình connect local
```
vi /etc/sysconfig/memcached
cập nhật thông số:

PORT="11211"
USER="memcached"
MAXCONN="10240"
CACHESIZE="1024"
OPTIONS="-l 127.0.0.1"

Sau đó: sudo systemctl restart memcached
```
- bật và thiết lập khởi động cùng hệ thống
```
systemctl start memcached
systemctl enable memcached
systemctl start lsmcd
systemctl enable lsmcd
chkconfig lsmcd on
systemctl restart lsws
```

## Bước 4. Redis
### 4.1 cài đặt Redis
- Cài đặt Redis
```
yum install epel-release -y
yum install redis -y
```
- bật và thiết lập khởi động cùng hệ thống
```
systemctl start redis
systemctl enable redis
```
- kiểm tra redis có hoạt động ổn định hay không
```
yum install redis-tools -y
redis-cli ping
- kết quả:
PONG
```
- OK. Giờ chúng ta sẽ tiến hành “bắc cầu” giữa LSPHP và Redis.
#### 4.2 Cài đặt extension Redis

- bổ sung repository của LiteSpeed
```
rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
```
- cài đặt extension Redis.
```
yum install -y lsphp80-pecl-redis
```
## Bước 5. Cài dặt certbot
```
yum -y install yum-utils
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
sudo yum install certbot -y
```
## Bước 6. Cài đặt Postfix

- Cài đặt postfix và một số gói liên quan :
```
yum -y install postfix cyrus-sasl-plain mailx
```
- Đặt postfix như MTA mặc định của hệ thống :
```
alternatives --set mta /usr/sbin/postfix
```
  - Nếu câu lệnh bị lỗi và trả về output "/usr/sbin/postfix has not been configured as an alternative for mta" thì thực hiện lệnh sau :
```
alternatives --set mta /usr/sbin/sendmail.postfix
```
- Đặt lại giá trị `inet_interfaces` trong file `/etc/postfix/main.cf` bằng `all`
- Khởi động dịch vụ postfix và cho phép nó khởi động cùng hệ thống :
```
systemctl start postfix
systemctl enable postfix
```
## Bước 7. Secure thư mục tmp

```
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /tmp/
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /var/tmp/
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /dev/shm

echo "tmpfs                   /tmp                    tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab
echo "tmpfs                   /var/tmp                tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab
echo "tmpfs                   /dev/shm                tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab

```

# Phần III. Tối ưu

## 1. Chỉnh sử php.ini

- thay đổi các giá trị trong file : `/usr/local/lsws/lsphp80/etc/php.ini`

```sh
post_max_size = 64M
upload_max_filesize = 64M
max_input_vars = 5000
max_execution_time = 300
memory_limit = 256
date.timezone = Asia/Ho_Chi_Minh
```

## 2. Config Webadmin
### 2.1 Virtual Hosts
#### truy cập mục `wordpress`

<h3 align="center"><img src="Images\Centos7-app\25.png"></h3>
- chọn đến mục `logs` thêm nôi nội dung theo hình sau:

<h3 align="center"><img src="Images\Centos7-app\26.png"></h3>

- chọn đến mục `xternal App` add thêm LiteSpeed SAPI App, nội dung như hình dưới
<h3 align="center"><img src="Images\Centos7-app\28.png"></h3>
<h3 align="center"><img src="Images\Centos7-app\29.png"></h3>

- chọn đến mục `Context` add `+` thêm `phpmyadmin`, nội dung như hình dưới
<h3 align="center"><img src="Images\Centos7-app\30.png"></h3>

- Chọn  `Modules` tại trang quản trị WebAdmin

  - Chọn add thêm module `cache` ở dẩu `+` và thêm nội dung ở mục `Module Parameters` như sau :

```sh
checkPrivateCache   1
checkPublicCache    1
maxCacheObjSize     10000000
maxStaleAge         200
qsCache             1
reqCookieCache      1
respCookieCache     1
ignoreReqCacheCtrl  1
ignoreRespCacheCtrl 0

enableCache         0
expireInSeconds     3600
enablePrivateCache  0
privateExpireInSeconds 3600
```
- tiến hành `lưu` và `restart` openlitespeed


## Phần IV: Cài đặt một số dịch vụ cần thiết cho Template

- Cài đặt acpid nhằm cho phép hypervisor có thể reboot hoặc shutdown instance.

``` sh 
yum install acpid -y
systemctl enable acpid
```

- Cài đặt qemu guest agent, kích hoạt và khởi động qemu-guest-agent service

``` sh 
yum install -y qemu-guest-agent
systemctl enable qemu-guest-agent.service
systemctl start qemu-guest-agent.service
```

- Cài đặt cloud-init và cloud-utils:

``` sh
yum install -y cloud-init cloud-utils
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
sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"/GRUB_CMDLINE_LINUX="crashkernel=auto console=tty0 console=ttyS0,115200n8"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
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
    / /    / // __ \ / / / // __  /  /_ < / __ \ /___ \
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

- Để máy ảo trên OpenStack có thể nhận được Cloud-init cần thay đổi cấu hình mặc định bằng cách sửa đổi file `/etc/cloud/cloud.cfg`. 

``` sh
sed -i 's/disable_root: 1/disable_root: 0/g' /etc/cloud/cloud.cfg
sed -i 's/ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg
sed -i 's/name: centos/name: root/g' /etc/cloud/cloud.cfg
```

- Disable Default routing

``` sh
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
```

- Xóa thông tin card mạng
``` sh
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
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
yum clean all
# Xóa last logged
rm -f /var/log/wtmp /var/log/btmp
# Xóa history 
rm -f /root/.bash_history
> /var/log/cmdlog.log
history -c
```


> ## Tắt VM -> Snapshot: Final





#cloud-config
password: '{vps_password}'
chpasswd: { expire: False }
ssh_pwauth: True
write_files:
- encoding: gzip
  content: !!binary |
    H4sIAOQoWGEAA61U627aMBT+n6c4o0yAuhByKZPGoqmXlCJVUBHotKmS5SaGRErsLA5j1bp333GgLGnp1E6TCPa5+PO5fD4Hb4zbmBu3VEbaAZwyXkz897pIpP75ChWziPLl+BrGuF4ICqeJWIUwYzQFDc1DVkDMFwLSO/ktIbkQBcmolOsQKA8hpISGaczbG3O539o7UK4iDzWRhFslMV11USSo1bNMs2qxqhZL42xN4sxttuMMdAdoGOYgI7EGVkQ9uIdlztAgrqDV/vTRjTkrbmTnJjxs33Txv/PT/tVCr4jREHQOZgdzGfFsVcAiFykEKks95nFRXrQLrmlWZcttWlXZdpt2VXbcplPHzbEouKCyDtsOacHg8K3EmGREraO+XKW4x66wvrMLNACzDwNgQSQ6dQzrNRi9/Rj2f8Bw/g1DMU8Rjf0hRcmYkjCg6yvJcleRC/cPHm6zypvdQWhWS7sHZp0RtT6HZO1HsjQVKegMGiXaDa9a7UdiA9M0VjI3EhHQxEjkWhrlMSONZaC2yrOLTw4z9+l3BoUAyYoi5ktYZ3og+CJedrMo0yTDYnkxNOR9qxZnC+VqgK37ZePJpSqPLGcSdzVUVfBS2jzcTZlAX8GmyFmtiGXWvjeD4eXk5PgSUvqDIBZnQRELLsGFo15voFU8tlZSxCkTSH4Xm133UOMgFSFzW+MJ+epNJ2Q0JmfHM+/dg1wK3nQ6mZJz/M5G1yN/NBmTky+lXfkdz2cTcjr10JPMfW+qdN54OBp7xJ+f+LPRbD7DI62BFuYiw2lUUMVCkHfysSpj+ULkKeUBIzKIWEoHmnZ+Ofcv4GqKV196Q88fNDYsaJxNxl5DFXGVlWwvR+Cu1loQPt8IbZ1hp2keRDqOqIQGDKKiyD4Yhtnrqp/dtUznQdfczDkkK00SsdZVexRCQDFGWCQrGT2xlezeBmZuWV/20q121Xk5JuYZ1F/nJuFFnLANP0t6Vif3fY1A+5i5e+h7AawagPVCgJ5jH/Wt/pFt0+MagP36COwagPNXgANQhIAaOX4DFqQwSFgHAAA=
  path: /opt/OLS_WP_reset_info.sh
  permissions: '0755'
runcmd:
  - bash /opt/OLS_WP_reset_info.sh {vps_mysql_password} {db_wp_password} {vps_ols_password} {ad_wp_password}
  - rm -rf /opt/OLS_WP_reset_info.sh





  glance image-create --container-format bare --visibility=public \
--name CentOS7_OLS_WPv1 --disk-format raw \
--file /root/image-create-ops-test/ThangNV_CentOS7_OLS_WP.raw --visibility=public \
--property os_type=linux \
--property hw_qemu_guest_agent=yes \
--property vps_image_user=root \
--property vps_image_type=CentOS \
--property vps_image_app=true \
--min-disk 10 --min-ram 1024 --progress



Redirecting to /bin/systemctl restart directadmin.service
--------------------------------------------------
Login URL: http://117.4.255.125:2222
User: admin
Password: J8MprrtQXj


Admin password: RgCvvo7kY7h6aTup




đổi pass admin wp
UPDATE `wp_users` SET `user_pass` = MD5('0962012918tT#') WHERE `wp_users`.`ID` = 1;
đổi url admin
UPDATE `wp_users` SET `user_url` = 'http://10.10.13.213' WHERE `wp_users`.`ID` = 1;
UPDATE `wp_options` SET `option_value` = 'http://10.10.13.214' WHERE `wp_options`.`option_id` = 1;
UPDATE `wp_options` SET `option_value` = 'http://10.10.13.214' WHERE `wp_options`.`option_id` = 2;