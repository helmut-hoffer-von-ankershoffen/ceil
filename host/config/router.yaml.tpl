#cloud-config

hostname: CONFIGURED_ON_CALL
manage_etc_hosts: false

locale: "en_US.UTF-8"
timezone: "Europe/Berlin"

users:
- name: admin
  groups: users,docker,adm,dialout,audio,plugdev,netdev,video
  gecos: "Admin"
  shell: /bin/bash
  sudo: ALL=(ALL) NOPASSWD:ALL
  lock_passwd: true
  chpasswd: { expire: false }
  ssh_pwauth: true
  ssh-import-id: None
  ssh-authorized-keys:
  - YOUR_SSH_PUBLIC_KEY

package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
- ntp
- telnet
- ca-certificates
- curl
- gnupg2
- software-properties-common

write_files:
- path: /etc/network/interfaces.d/wlan0
  content: |
    allow-hotplug wlan0
    iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
    iface default inet dhcp
- path: /etc/wpa_supplicant/wpa_supplicant.conf
  content: |
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    country=DE
    network={
      ssid="YOUR_WIFI_SID"
      psk="YOUR_WIFI_PASSWORD"
      proto=RSN
      key_mgmt=WPA-PSK
      pairwise=CCMP
      auth_alg=OPEN
    }
- path: "/etc/docker/daemon.json"
  owner: "root:root"
  content: |
    {
      "labels": [ "os=linux", "arch=arm64" ],
      "experimental": true
    }

runcmd:
- 'mkdir -p /var/volumes'
- 'setfacl -m "u:admin:rwx" /var/volumes'
- 'systemctl restart avahi-daemon'
- 'ifup wlan0'
- 'systemctl restart docker'