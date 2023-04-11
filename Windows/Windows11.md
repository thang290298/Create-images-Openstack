# Tài liệu đóng Image Windows 11 Blank
> **Do tại thời điểm đóng Template này Windows 11 chưa phát hành bản chính thức dẫn đến KVM,virtIO chưa hỗ trợ đối với HĐH Windows 11 nên sẽ sử dụng các bản hỗ trợ đổi với Windows 10.**
# Phần I. Khởi tạo Host
## Bước 1: Trên KVM host tạo máy ảo Windows 11
### 1. Khởi tạo ổ cứng sử dụng cho máy ảo:
- Login vào Node KVM thực hiện lệnh tạo phân vùng Disk cho máy ảo
```sh
qemu-img create -f qcow2 /var/lib/libvirt/images/OPS_Template_W11.qcow2 25G
```
### 2. thực hiện khởi tạo VM
- Trên host KVM, bật giao diện virt-manager, và khởi tạo máy ảo. Khai báo tên máy ảo.

<h3 align="center"><img src = "..\Images\Windows11\1.png"></h3>
- thực hiện chọn đường dẫn phân vùng disk và loại OS hỗ trợ cài đặt
<h3 align="center"><img src = "..\Images\Windows11\2.png"></h3>
<h3 align="center"><img src = "..\Images\Windows11\3.png"></h3>

- Chỉnh mode CPU: `Hypervisor Default`
<h3 align="center"><img src = "..\Images\Windows11\4.png"></h3>
- Thực hiện muont IOS cài đặt Windown 11
<h3 align="center"><img src = "..\Images\Windows11\5.png"></h3>
sử dụng các Options:
  - Device Type: CDROM Device
  - Bus Type: IDE
- thực hiện mount VirtIO để thực hiện cài đặt các Driver cần thiết
<h3 align="center"><img src = "..\Images\Windows11\6.png"></h3>
<h3 align="center"><img src = "..\Images\Windows11\7.png"></h3>

- Điều chình `Boot Options`
<h3 align="center"><img src = "..\Images\Windows11\8.png"></h3>

- Thay đổi `Device model` Virtual Network interface về dạng : **Virtio**
<h3 align="center"><img src = "..\Images\Windows11\9.png"></h3>


- Add `Display`: VNC
<h3 align="center"><img src = "..\Images\Windows11\10.png"></h3>

- Add `Chanel qemu-ga`
<h3 align="center"><img src = "..\Images\Windows11\10.png"></h3>

- thực hiện cài đặt 

```
[DEFAULT]
username=Administrator
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