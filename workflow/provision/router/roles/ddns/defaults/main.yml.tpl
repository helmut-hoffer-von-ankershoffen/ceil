---
# defaults file for ansible.ddclient
ddclient_period: 60         # seconds between run
ddclient_syslog_enable: yes # true/false to log update to syslog
ddclient_mail: 'YOUR_EMAIL' # mail all message to this user
ddclient_mail_failure: root # mail failed update to this user
ddclient_ssl_support: yes   # if need ssl support to connect to a service

ddclient_method: 'web'      # can be either web or if or ip
ddclient_use_ip:  ''        # which static ip, required if ddclient_method is ip
ddclient_web_url: ''        # web url to get the ip, optional
ddclient_use_if:  ''        # which interface used to get the ip, required if ddclient_method is if

# this is an option in case ddclient_use_web is used
ddclient_use_web_skip: ''   # if defined, skip this string to get the ip

ddclient_protocol: 'cloudflare'                             # which dydns protocol, MUST BE DEFINED !!
ddclient_login: 'YOUR_CLOUDFLARE_EMAIL'                  # user used to connect, MUST BE DEFINED !!
ddclient_password: 'YOUR_CLOUDFLARE_API_KEY'  # password used to connect, MUST BE DEFINED !!
ddclient_server: ''                       # server on which to connect to do ddns operation, MUST BE DEFINED !!
ddclient_hosts:
  - 'YOUR_VPN_FQDN'              # which records to update, i.e. your subdomains, MUST BE DEFINED !!
ddclient_zone: 'YOUR_VPN_ZONE'   # your domain
ddclient_mx: ''             # if defined ,use it as mx for the host
ddclient_backup_mx: no      # yes or no, if ddclient_mx is a backup mx or not
ddclient_postscript: ''     # run script after updating
ddclient_wildcard: no       # yes or no, if enabled add a  * CNAME to your host

ddclient_pid: '/var/run/ddclient.pid'
ddclient_config: '/etc/ddclient/ddclient.conf'
ddclient_mode: '/etc/default/ddclient'
ddclient_service_name: 'ddclient'
ddclient_group: 'root'
ddclient_user: 'root'
