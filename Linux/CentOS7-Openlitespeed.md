# Tài liệu đóng Image CentOS7 + Openlitespeed

## Các thành phần chính

- Openlitespeed 1.7.13
- Mariadb 10.5.12 OK
- PHP 8.0.9 OK
- phpMyAdmin 5.1.1
- LiteSpeed Cache
- Memcached 3.1.5 ok
- Redis 	5.3.4 ok 
- certbot 1.11.0 ok
- Postfix 2.10.1 ok

***Lưu ý***: Sử dụng version mới nhất

## Phần I: Trên KVM host tạo máy ảo CentOS7

### Bước 1. Khởi tạo ổ cứng sử dụng cho máy ảo:

<img src = "Images\Centos7-app\1.png">
<img src = "Images\Centos7-app\2.png">
<img src = "Images\Centos7-app\3.png">
<img src = "Images\Centos7-app\4.png">

### Bước 2. thực hiện khởi tạo VM
-  `Instances` -> `+` sau đó thực hiện các bước khởi tạo sau: 
<img src = "Images\Centos7-app\5.png">
<img src = "Images\Centos7-app\6.png">

  - Lựa chọn `Custom` và điền các thông tin: Name, VCPU, RAM, HDD, Network rồi chọn `Create`:
<img src = "Images\Centos7-app\7.png">
- Mount ISO tiến hành cài đặt OS
<img src = "Images\Centos7-app\8.png">
- chỉnh lại thứ tự boot
<img src = "Images\Centos7-app\9.png">

### Bước 3. Tạo `Snapshots` trước khi cài đặt OS
<img src = "Images\Centos7-app\12.png">

### Bước 4. Bật máy ảo và Console vào để cài đặt OS

<img src = "Images\Centos7-app\10.png">
<img src = "Images\Centos7-app\11.png">

### Bước 5. Cài đặt OS
- Chọn `Install CentOS7` để tiến hành cài đặt 

![](Images/create-image-Centos7-WP-LAMP/1.png)


- Cấu hình ngôn ngữ chọn `English(English)`

![](Images/create-image-Centos7-WP-LAMP/2.png)

- Cấu hình timezone về Ho_Chi_Minh

![](Images/create-image-Centos7-WP-LAMP/3.png)

![](Images/create-image-Centos7-WP-LAMP/4.png)

- Cấu hình disk để cài đặt 

![](Images/create-image-Centos7-WP-LAMP/5.png)

![](Images/create-image-Centos7-WP-LAMP/6.png)

- Chọn `Standard Partition` cho ổ disk 

![](Images/create-image-Centos7-WP-LAMP/7.png)

- Cấu hình mount point `/` cho toàn bộ disk

![](Images/create-image-Centos7-WP-LAMP/8.png)

- Định dạng lại `ext4` cho phân vùng

![](Images/create-image-Centos7-WP-LAMP/9.png)


- Kết thúc quá trình cấu hình disk 

![](Images/create-image-Centos7-WP-LAMP/11.png)

- Confirm quá trình chia lại partition cho disk 

![](Images/create-image-Centos7-WP-LAMP/12.png)

- Cấu hình network 

![](Images/create-image-Centos7-WP-LAMP/13.png)

- Turn on network cho interface và set hostname

![](Images/create-image-Centos7-WP-LAMP/14.png)

- Kết thúc cấu hình, bắt đầu quá trình cài đặt OS

![](Images/create-image-Centos7-WP-LAMP/15.png)

- Setup passwd cho root

![](Images/create-image-Centos7-WP-LAMP/16.png)


![](Images/create-image-Centos7-WP-LAMP/17.png)


- Reboot lại VM sau khi cài đặt hoàn tất

![](Images/create-image-Centos7-WP-LAMP/18.png)

### Bước 6. Chỉnh sửa file XML VM Lưu ý:

- Chỉnh sửa file .xml của máy ảo, bổ sung thêm channel trong (để máy host giao tiếp với máy ảo sử dụng qemu-guest-agent), sau đó save lại

Truy cập Settings > XML > EDIT SETTINGS

<img src = "Images\Centos7-app\13.png">

Nếu đã tồn tại channel đổi port channel này về port='2' và add channel bình thường

![](Images/create-image-ubuntu20.04/29.png)

Định dạng
```shsh
<devices>
<channel type='unix'>
    <target type='virtio' name='org.qemu.guest_agent.0'/>
    <address type='virtio-serial' controller='0' bus='0' port='1'/>
</channel>
</devices>
```
## Phần II: Cài đặt môi trường

### Bước 1. Cấu hình và cài đặt các gói
Cài đặt `epel-release` và update
```sh
yum install epel-release -y
yum update -y
yum install -y wget
sudo yum  install zip unzip -y
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
Disable NetworkManager, sử dụng network service
```sh
systemctl disable NetworkManager
systemctl stop NetworkManager
systemctl enable network
systemctl start network
```

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
yum install chrony -y
sed -i 's|server 1.vn.pool.ntp.org iburst|server 162.159.200.123 iburst|g' /etc/chrony.conf
systemctl enable --now chronyd 
hwclock --systohc
```

### Bước 7. Cấu hình console và network

Để sử dụng nova console-log, bạn cần thay đổi option cho `GRUB_CMDLINE_LINUX` và lưu lại 

```sh sh
sed -i 's/GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet"/GRUB_CMDLINE_LINUX="crashkernel=auto console=tty0 console=ttyS0,115200n8"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
```


- Disable Default routing

```sh sh
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
```

- Xóa thông tin card mạng
```sh sh
rm -f /etc/sysconfig/network-scripts/ifcfg-eth0
```

- Để sau khi boot máy ảo, có thể nhận đủ các NIC gắn vào:

```shsh 
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

```sh sh
rm -f /etc/hostname
```

### Bước 8. Tạo Snapshot Begin

## Bước 3: Cài đặt APP
### Bước 1. Cài đăt OpenLiteSpeed + PHP 8.0 + Mariadb + PhpMyAdmin
#### Cách 1: Cài đặt từng thành phần 
##### 1.1 OpenLiteSpeed
- Add the Repository
```sh
rpm -Uvh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
```
- Install OpenLiteSpeed
```sh
yum install openlitespeed
```
- khởi động OpenLiteSpeed
```sh
systemctl start lsws
systemctl enable lsws
systemctl status lsws
```
##### 1.2. Cài đăt PHP 8.0

- Add Remi Repository
```sh
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
```
- Install PHP 8.0
```sh
yum install -y --enablerepo=remi-php80 php php-cli
sudo yum install lsphp80 lsphp80-mysql lsphp80-common lsphp80-opcache lsphp80-curl
```

- Install PHP Extensions

```sh
yum -y install lsphp80-mysqlnd lsphp80-gd lsphp80-process lsphp80-mbstring lsphp80-xml lsphp80-pdo lsphp80-imap lsphp80-soap lsphp80-bcmath lsphp80-zip lsphp80-iconv lsphp80-mysqli
```

- check version
```sh
[root@localhost ~]# php -v
PHP 8.0.10 (cli) (built: Aug 24 2021 15:40:40) ( NTS gcc x86_64 )
Copyright (c) The PHP Group
Zend Engine v4.0.10, Copyright (c) Zend Technologies
```
##### 1.3 Install MariaDB 10.5.12
- update packages
```
yum install upgrade -y
```
Mặc định, repo cài đặt MariaDB trên CentOS-7 là phiên bản 5.x. Vì vậy, để cài đặt bản mới cần chỉnh sửa repo cài MariaDB (phiên bản 10.6.4 - Stable)
```sh
vi /etc/yum.repos.d/MariaDB.repo
```
- Nội dung
```
# MariaDB 10.5 CentOS repository list - created 2021-08-04 11:35 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```
- Cài đặt MariaDB:
```
yum install MariaDB-server MariaDB-client -y
```
- Khởi động Mariadb service:
```
systemctl start mariadb
systemctl enable mariadb
```
- Disable unix_socket authentication: Thêm đoạn sau vào file /etc/my.cnf
```
[mariadb]
unix_socket=OFF
```
- Cài đặt 1 số thông tin ban đầu:
```
sudo mysql_secure_installation

```
  - Tiến hành lựa chọn giống như sau
```
Enter current password for root (enter for none): Nhấn phím Enter
Switch to unix_socket authentication [Y/n]: n
Change the root password? [Y/n]: Y
New password: Nhập password root các bạn muốn tạo
Re-enter new password: Nhập lại password root
Remove anonymous users? [Y/n] : Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n] : Y
Reload privilege tables now? [Y/n]: Y
```
##### 1.4 Cài đặt PhpMyAdmin

- truy cập thư mục `/usr/local/lsws/Example/html` tiến hành download và cài đặt
```
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip
unzip phpMyAdmin-5.1.1-all-languages.zip
mv phpMyAdmin-5.1.1-all-languages phpmyadmin
cd phpmyadmin
mkdir tmp && chmod 777 tmp
```
- Cấu hình mật khẩu blowfish vào tệp cấu hình của phpMyAdmin:
  - truy cập thư mục: `/usr/local/lsws/Example/html/phpmyadmin/` 
  - mở file `config.sample.inc.php` va thay đổi nội dung dòng thứ 16
```
  # trước:
$cfg['blowfish_secret'] = ; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */  

  # sau:
$cfg['blowfish_secret'] = 'qtdRoGmbc9{8IZr323xYcSN]0s)r$9b_JUnb{~Xz'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
```
  - thay đổi tên file

```
mv config.sample.inc.php config.inc.php
```

##### 1.5 Configuretion OpenliteSpeed

- trang quản trị OpenliteSpeed hoạt động trên port **7080** tiến hành allow port firewalld
```
firewall-cmd --add-port=7080/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload
```
- thay đổi port truy cập website từ **8088** sang port **80**. sửa file: `/usr/local/lsws/conf/httpd_config.conf`

<img src = "Images\Centos7-app\15.png">

- Set admin console password :
```
cd /usr/local/lsws/admin/misc
sh admpass.sh
```
<img src = "Images\Centos7-app\14.png">

- Thay đổi PHP version in openlitespeed
  - chỉnh sửa file `httpd_config.conf`
```
thay thế: `$SERVER_ROOT/lsphp73/bin/lsphp`
bằng: `$SERVER_ROOT/lsphp80/bin/lsphp`
```
truy cập kiểm tra:
  - giao diện WebAdmin: http://IPserver:7080/
  account: admin
  pass: 0435626533aA
<img src = "Images\Centos7-app\16.png">
  - truy cập trang web: http://IPserver

<img src = "Images\Centos7-app\17.png">

  - kiểm tra phiển bản php8.0

<img src = "Images\Centos7-app\18.png">

  - login phpmyadmin

<img src = "Images\Centos7-app\19.png">

#### Cách 2: Sử dụng script cài đặt ( one click )

##### 2.1: Cài đặt Openlitespeed + php8.0 + config port

- Download script cài đặt và tiến hành cài đặt
```
wget https://raw.githubusercontent.com/litespeedtech/ols1clk/master/ols1clk.sh
chmod +X ols1clk.sh
chmod +X ols1clk.sh
bash ./ols1clk.sh --lsphp 80 -A 0435626533aA -e admin@example.com --listenport 80 --ssllistenport 443
```
trong đó: 
  - **./ols1clk.sh -A 0435626533aA -e admin@example.com**: cài đặt Openlitespeed với mật khẩu tài khoản `Webadmin` là `0435626533aA` và email `admin@example.com`
  - **--lsphp 80**: cài đặt phiên bản PHP 8.0
  - **--listenport 80**: cấu hình http server sử dụng Port`80` ( default: 8088)
  - **--ssllistenport 443**: cấu hình https server sử dụng Port`443`

##### 2.2: cài đặt MariaDB
- update packages
```
yum install upgrade -y
```
Mặc định, repo cài đặt MariaDB trên CentOS-7 là phiên bản 5.x. Vì vậy, để cài đặt bản mới cần chỉnh sửa repo cài MariaDB (phiên bản 10.6.4 - Stable)
```sh
vi /etc/yum.repos.d/MariaDB.repo
```
- Nội dung
```
# MariaDB 10.5 CentOS repository list - created 2021-08-04 11:35 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.5/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```
- Cài đặt MariaDB:
```
yum install MariaDB-server MariaDB-client -y
```
- Khởi động Mariadb service:
```
systemctl start mariadb
systemctl enable mariadb
```
- Disable unix_socket authentication: Thêm đoạn sau vào file /etc/my.cnf
```
[mariadb]
unix_socket=OFF
```
- Cài đặt 1 số thông tin ban đầu:
```
sudo mysql_secure_installation

```
  - Tiến hành lựa chọn giống như sau
```
Enter current password for root (enter for none): Nhấn phím Enter
Switch to unix_socket authentication [Y/n]: n
Change the root password? [Y/n]: Y
New password: Nhập password root các bạn muốn tạo
Re-enter new password: Nhập lại password root
Remove anonymous users? [Y/n] : Y
Disallow root login remotely? [Y/n]: Y
Remove test database and access to it? [Y/n] : Y
Reload privilege tables now? [Y/n]: Y
```
##### 2.2 Cài đặt PhpMyAdmin

- truy cập thư mục `/usr/local/lsws/Example/html` tiến hành download và cài đặt
```
wget https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip
unzip phpMyAdmin-5.1.1-all-languages.zip
mv phpMyAdmin-5.1.1-all-languages phpmyadmin
cd phpmyadmin
mkdir tmp && chmod 777 tmp
```
- cấu hình `mật khẩu blowfish` vào tệp cấu hình của phpMyAdmin.
```
vi /usr/local/lsws/Example/html/phpmyadmin/config.sample.inc.php
# thay thế : $cfg['blowfish_secret'] = ''; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */
# Bằng : $cfg['blowfish_secret'] = 'qtdRoGmbc9{8IZr323xYcSN]0s)r$9b_JUnb{~Xz'; /* YOU MUST FILL IN THIS FOR COOKIE AUTH! */

mv config.sample.inc.php config.inc.php
```

```
firewall-cmd --add-port=7080/tcp --permanent
firewall-cmd --add-port=80/tcp --permanent
firewall-cmd --add-port=443/tcp --permanent
firewall-cmd --reload
``` 

### Bước 2. LiteSpeed Cache
#### 2.1 Cache Module Configuration

- Chọn `Server Configuration` -> `Modules` tại trang quản trị WebAdmin

- Chọn chỉnh chỉnh sửa 

- thay đổi nội dung ở mục `Module Parameters` :
```
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

#### 2.2 Rewrite Configuration and Read From .htaccess File

- Chọn `Virtual Hosts` tại trang quản trị WebAdmin
- Tại `Rewrite` thay đổi cấu hình seting:
```
Enable Rewrite: Yes
Auto Load from .htaccess: Yes
```
### Bước 3. Memcached
- Truy cập SSh VPS
- Sau khi SSH thành công vào VPS, các bạn cài đặt mã nguồn **LSMemcached** bằng lệnh sau:
```
yum -y install memcached
yum install lsphp80-pecl-memcached -y
cd ~
yum groupinstall "Development Tools" 
yum install autoconf automake zlib-devel openssl-devel expat-devel pcre-devel libmemcached-devel cyrus-sasl*
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

- Allow Firewall
```
sudo firewall-cmd --new-zone=memcached --permanent
sudo firewall-cmd --zone=memcached --add-port=11211/udp --permanent
sudo firewall-cmd --zone=memcached --add-port=11211/tcp --permanent
sudo firewall-cmd --reload
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
### Bước 4. Redis
#### 4.1 cài đặt Redis
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

#### Bước 5. Cài dặt certbot
```
yum -y install yum-utils
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
sudo yum install certbot -y
```

#### Bước 6. Cài đặt Postfix

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
#### Bước 7. Secure thư mục tmp

```
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /tmp/
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /var/tmp/
mount -t tmpfs -o defaults,nodev,nosuid,noexec tmpfs /dev/shm

echo "tmpfs                   /tmp                    tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab
echo "tmpfs                   /var/tmp                tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab
echo "tmpfs                   /dev/shm                tmpfs   defaults,nodev,nosuid,noexec        0 0" >> /etc/fstab

```
## Phần III: Cài đặt một số dịch vụ cần thiết cho Template

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
## Phần IV: Xử lý image và upload
### Bước 1. Sử dụng lệnh virt-sysprep để xóa toàn bộ các thông tin máy ảo
```
virt-sysprep -d ThangNV_CentOS7_OLS
```
### Bước 2. Tối ưu kích thước image:
```
virt-sparsify --compress --convert qcow2 /var/lib/libvirt/images/ThangNV_CentOS7_OLS.qcow2 ThangNV_CentOS7_OLS
```
### Bước 3: Upload image lên glance và sử dụng
- trước tiên cần Coppy file images sang note Controller
- Convert images về định dạng raw
```
qemu-img convert -O raw ThangNV_CentOS7_OLS ThangNV_CentOS7_OLS.raw
```
- Đẩy image lên hệ thống và sử dụng
```
glance image-create --container-format bare --visibility=public \
--name OPS_OLS_Template --disk-format raw \
--file /root/image-create-ops-test/OPS_OLS_Template.raw --visibility=public \
--property os_type=linux \
--property hw_qemu_guest_agent=yes \
--property vps_image_user=root \
--property vps_image_type=CentOS \
--property vps_image_app=true \
--min-disk 10 --min-ram 1024 --progress
```
### Bước 4: Nội dung cloud-init
```
#cloud-config
password: '{vps_password}'
chpasswd: { expire: False }
ssh_pwauth: True
write_files:
- encoding: gzip
  content: !!binary |
    H4sIABdjNmEAA4VSwUrDQBC95yvGNIIiMTZtc5EcpIr2koIURRHKNjttopvdmNkQCv14d0NrkyJ42rd5817m7czgLFjlMlgxypwBzEuUItdIJSKHCgk1lIyoURU39CJjcpO8QGLOJ8VgKlTNYYGsMOSjqc3lWkGxpW+xrJTSy1bLHSX4Hi4NKeKb8WgShdFkNGJ3RjmTZa1hXakCUuvo5zLXjsTmIBrG3rB7D2Mv7OsqJrmyXfRVF5xphKtzgh1QxsJJRHVhsImL0diADBkHP4VhBLeAaaYujcfUxsRj8DYQ40Uuwfdrwiq24Qw+VMTeScJfLXjdhhz7B/AR3NbtQ3bZ8OTqmvaCmqpAqJSJQFBDQSsLipxSC23ltZkbmVn5Obi0Sz7fv95eZ82u57TbuH877cdz1HcH879HZzOekTSrdH+BHNqSxiLVwq5Sy1vdH5/bF7Y+9/PkwfkBJEinApQCAAA=
  path: /opt/OLS_reset_passwd.sh
  permissions: '0755'
runcmd:
  - bash /opt/OLS_reset_passwd.sh {vps_mysql_password} {vps_ols_password}
  - rm -rf /opt/OLS_reset_passwd.sh
```