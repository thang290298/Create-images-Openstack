# Tài liệu đóng Image Win2k19 Standard Blank
# Phần I. Khởi tạo HostWin2k19 Standard
## Bước 1: Trên KVM host tạo máy ảo Win2k19 Standard
### 1. Khởi tạo ổ cứng sử dụng cho máy ảo:
- Login vào Node KVM thực hiện lệnh tạo phân vùng Disk cho máy ảo
```sh
qemu-img create -f qcow2 /kvm/win2019_x64_standard.img 25G
```
### 2. thực hiện khởi tạo VM
- Trên host KVM, bật giao diện virt-manager, và khởi tạo máy ảo. Khai báo tên máy ảo.

<h3 align="center"><img src = "..\Images\Windows11\1.png"></h3>
- thực hiện chọn đường dẫn phân vùng disk và loại OS hỗ trợ cài đặt
<h3 align="center"><img src = "..\Images\Windows2019standard\2.png"></h3>

- Chọn cấu hình Ram và CPU
<h3 align="center"><img src = "..\Images\Windows2019standard\3.png"></h3>

- Đặt tên máy ảo và chọn network

<h3 align="center"><img src = "..\Images\Windows2019standard\4.png"></h3>
- Chỉnh sủa `disk bus` và `disk format`

<h3 align="center"><img src = "..\Images\Windows2019standard\5.png"></h3>

- Thực hiện add ISO cài đặt `Windows server 2019`

<h3 align="center"><img src = "..\Images\Windows2019standard\6.png"></h3>

- Thực hiện add ISO cài đặt `Virtio`
<h3 align="center"><img src = "..\Images\Windows2019standard\7.png"></h3>


- Trong phần `NIC` chỉnh `Device model` về `Virtio`
<h3 align="center"><img src = "..\Images\Windows2019standard\8.png"></h3>

- Trong phần "Boot Options", chỉnh lại thứ tự boot, sau đó chọn "Begin
Installation" để bắt đầu chạy máy ảo
<h3 align="center"><img src = "..\Images\Windows2019standard\9.png"></h3>


- Cài đặt **`OS`**
<h3 align="center"><img src = "..\Images\Windows2019standard\10.png"></h3>

- Chọn load driver để cài đặt driver storage
<h3 align="center"><img src = "..\Images\Windows2019standard\11.png"></h3>

- Chọn `Brower` trỏ đến thư mục `viostor/2k19/amd64` và bấm oke và tiếp tục bấm `next`
<h3 align="center"><img src = "..\Images\Windows2019standard\12.png"></h3>

- Lựa chọn disk cài đặt `OS`
<h3 align="center"><img src = "..\Images\Windows2019standard\13.png"></h3>

<h3 align="center"><img src = "..\Images\Windows2019standard\14.png"></h3>



<h3 align="center"><img src = "..\Images\Windows2019standard\15.png"></h3>
<h3 align="center"><img src = "..\Images\Windows2019standard\16.png"></h3>

```
[DEFAULT]
username=Administrators
groups=Administrators
inject_user_password=true
first_logon_behaviour=no
config_drive_raw_hhd=true
config_drive_cdrom=true
config_drive_vfat=true
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
logging_serial_port_settings=COM1,115200,N,8
mtu_use_dhcp_config=true
ntp_use_dhcp_config=true
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
```
```
C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\
```