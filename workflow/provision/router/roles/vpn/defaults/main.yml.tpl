---

certificate:
  key_size: 1024 # If you are paranoid you can change for 2048
  key_country: "DE" # Country Name (2 letter code)
  key_province: "Berlin" # State or Province Name (full name)
  key_city: "Berlin" # Locality Name (eg, city)
  key_org: "Maxxx" # Organization Name (eg, company)
  key_email: "YOUR_EMAIL" # Email Address
  key_ou: "Tech" # Organizational Unit Name (eg, section)

openvpn:
  protocol: udp # UDP is recommended. You can change fot TCP.
  port: 1194 # This is the default OpenVPN port. Remember open this port in your router to allow the VPN connection from Internet.
  server_subnet: 10.8.0.0 # The subnet you want to use for the OpenVPN clients
  server_netmask: 255.255.255.0 # The netmask for the OpenVPN client subnet
  server_tun0: 10.8.0.1 # The IP for the OpenVPN tunnel interface
  server_tun0_ptp: 10.8.0.2 # The IP for the OpenVPN tunnel point-to-point alias
  local_subnet: 192.168.0.0 # The local subnet where the router is connected
  local_netmask: 255.255.255.0 # The local netmask for the router subnet
  dns_ip: 127.0.0.1 # If your router does not do DNS, you can use Google DNS 8.8.8.8
  host_public: YOUR_VPN_FQDN

easyrsa:
  directory: /etc/openvpn/easy-rsa
