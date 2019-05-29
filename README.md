# `ceil`: Auto-provisioned RPi cluster running K8S on bare-metal

Enter `make help` to see available commands.

Why the name? `intval(ceil(M_PI)) === 4` which is the number of k8s nodes of the ceil cluster - flowers to mlande for gifting the name.

## Goals

* Setup auto-provisioned RPi cluster running K8S on bare-metal behind a RPi acting as a router
* Educate myself on Ansible + RPi + K8S + GitOps for CI/CD/PD from bottom to top
* Refresh knowledge regarding networking and Python
* Enhanced PHP/SF4 stack for K8S supporting HPA, progressive deployments and a/b testing

## Tasks

### Phase 0: Hardware

![alt text](https://raw.githubusercontent.com/helmuthva/ceil/master/doc/assets/ceil.jpg "Ceil Rack")

- [x] Wire up RPi rack and accessories

### Phase 1: Foundation

- [x] Central CloudOps entrypoint is `make`
- [x] Flashing of RPis and automatic provisioning with pre-configured base OS
- [x] Setup and teardown of all steps individually
- [x] Setup and teardown in one step
- [x] Setup of k8s cluster on RPis using Ansible inc. weave networking and k8s dashboard
- [x] Helm/tiller for additional deployments
- [x] Traefik as ingress inc. Traefik dashboard
- [x] busybox-http using Traefik as ingress for demos
- [x] Grafana and prometheus

### Phase 2: Storage and Loadbalancing

- [x] Dynamic volume provisioning using Heketi + GlusterFS spanning thumb drives
- [x] Enabled persistence for grafana and prometheus
- [x] MetalLB as LoadBalancer service

### Phase 3: Router

- [x] Act as DHCP client using dhcpcd
- [x] Act as DHCP & DNS server for K8S subnet using dnsmasq
- [x] Act as gateway from wlan0 (WiFi) to eth0 (K8S subnet) using iptables
- [x] Act as VPN server using OpenVPN
- [x] Dynamically update domain vpn.ceil.pro (or similar) using ddclient and Cloudflare v4 API
- [x] Raise Firewall using ufw
- [x] Act as Docker registry mirror using official docker image `registry:2`
- [x] Act as private Docker registry
- [ ] ngrok

### Phase 4: PiWatch

- [x] Play with [PiTraffic Lights](https://sb-components.co.uk/pi-traffic.html) mounted on top of `ceil-router`
- [x] Deploy kubewatch to push K8S events to arbitrary webhook
- [x] Build dockerized Python/FastAPI (ASGI) based webapp [PiWatch](https://github.com/helmuthva/piwatch) triggering PiTraffic as audiovisual event handler for K8S by providing webhook for kubewatch
- [ ] Refine `PiWatch` to react more fine granular to specific K8S events

### Phase 5: PiPHP

- [x] Deploy custom built base image [arm32v7-docker-php-apache](https://github.com/helmuthva/arm32v7-docker-php-apache) to k8s from private registry provided by router // Further progress of base image tracked there
- [ ] Prepare simple SF4 based app using said base image
- [ ] Enhance app for K8S (introspection, healthz, metrics etc.) with podinfo as a blueprint

### Phase 6: Auto-Scaling
- [ ] Autoscaling using HPA and custom metrics
- [ ] Zero-Scaling using Osiris
- [ ] Relevant dashboards in grafana

### Phase 7: Mesh-Networking (waiting for ARM images from CNCF et al)
- [ ] Istio for Mesh-Networking
- [ ] Visibility tools
- [ ] Additional tools

### Phase 8: GitOps and Progressive Delivery (waiting for ARM images from CNCF et al)

- [ ] Flagger for Helm using mesh network
- [ ] Canary deployments using mesh network
- [ ] ...

### Phase 9: CI and emphemeral test environments (waiting for ARM images from CNCF et al)
- [ ] Setup CI using JenkinsX
- [ ] ...


### Phase 10: A/B testing (waiting for ARM images from CNCF et al)

- [ ] Using mesh network
- [ ] ...

### Phase 11: Sharing is caring

- [x] Open source under GPlv3
- [x] Links to useful material for further studies
- [ ] Prepare interactive install script automating the step to manually copy and edit `.tpl` files
- [ ] Write a series of blog posts
- [ ] Prepare a workshop presentation
- [ ] Educate peers in meetups

## Layers and tools

* CloudOps
  * Workstation: MacBook Pro
  * Package manager: Homebrew
  * Flash-Tool for OS of RPis: Hypriot Flash
  * Entrypoints: `make` and `kubectl` (GitOps in second step)
* Hardware
  * SBCs: 5x Raspberry Pi 3B+
  * Storage: 5x 128GiB SD cards (containers), 5x 128GiB USB ThumbDrives (volumes)
  * Rack: transparent
  * Networking: 5-port GBit/s switch + WiFi router connected to router
  * Power: 6-port USB charger powering switch and RPIs
  * 4-dir traffic lights with beeper and button: [PiTraffic](https://sb-components.co.uk/pi-traffic.html)
* Software
  * OS: Debian, Hypriot distribution
  * Networking for router: iptables, dhcpcd, dnsmasq, OpenVPN, ddclient, CloudFlare
  * Configuration management: Ansible
  * Orchestration: Kubernetes (K8S)
  * K8S installation: `kadm`
  * Networking: weave
  * Persistence: GlusterFS + Heketi for dynamic volume provisioning
  * Ingresss: Traefik
  * Loadbalancer: MetaLB
  * Deployments: helm
  * Monitoring and Dashboarding: prometheus, grafana
  * Traffic lights: kubewatch, Python, Flask, PiTraffic, RPi.GPIO

## Install this repository

1) Fork this repository and clone to your workstation
2) Walk all files with suffix `.tpl`, create a copy in the same directory without said suffix and enter specifics where invited by capital letters

## Provision RPIs

1) Prepare you workstation by installing Ansible, kubectl, helm etc. using homebrew: `make prepare-mac`
2) Pull the hypriot image (which is not stored  in GitHub): `make pull-image`
3) Flash RPIs (insert SD cards in your workstation): `make {router,one,two,three,four}-provision`
4) Insert SD cards into slots of respective RPIs
5) Insert thumb drives into USB ports of RPIs
6) Start RPIs by plugging in the USB charger

## Setup router

1) Make a DHCP reservation for `ceil-router` on your home or company WiFi router with IP address `192.168.0.100` -  it will register as `ceil-router` at your WiFi router
2) Reboot `ceil-router` to pickup its IP address via `make router-reboot` - it will register via ZeroConf/Avahi on your workstation as `ceil-router.local`
3) Check via `make router-check-ip` if the IP address has been picked up
4) Setup networking services on router using `make router-setup`
5) Add `192.168.0.100` as the first nameserver for the (WiFi) connection of your workstation using system settings
6) Wait for 1 minute than check if the k8s nodes (`ceil-{one,two,three,four}.dev`) have picked up their designated IP addresses from the router in the range `11.0.0.101` to `11.0.0.104`:  `make k8s-check-ip` 

Notes:
- Danger: wipes thumb drive in router
- It might take some time until the Zeroconf/Avahi distributed the name `ceil-router.local` in your network. You can check by ssh'ing into the router via `make router-ssh`
- The router will manage / route to the subnet `11.0.0.[0-128]` (`11/25`) the K8S nodes will life in and act as their DHCP and DNS server
- Furthermore the router acts as an OpenVPN server and updates the IP address of `vpn.ceil.pro` via DDNS
- Setting up services on the router triggers adding a route on our workstation to use `192.168.0.100` as gatewway for the subnet `11.0.0.[0-128]`
- After setting up services on the router wait for a minute to check if the k8s nodes have picked up the designated IPs using `make k8s-check-ip`
- After the k8s nodes picked up their IP addresses you can ssh into them using `make {one,two,three,four}-ssh`
- If on your workstation `nslookup ceil-{one,two,three.four}.dev` works but `ping ceil-{one,two,three.four}.dev` does not, reestablish the (WiFi) connection of your workstation
- If you want to play with the traffic lights mounted on top of the router: `make router-traffic`
- The last step of the router setup is building [PiWatch](https://github.com/helmuthva/piwatch) which takes ca. 15 minutes for the 1st build

## Setup K8S and execute all deployments

1) Execute `make setup` to setup K8S inc. persistence and deploy everything at once - takes ca. 45 minutes. 

Notes:
- `ceil-one` is set up as k8s master
- Danger: wipes thumb drives for setting up GlusterFS.
- Because of memory constraints the GlusterFS spans `ceil-two` to `ceil-four` but not `ceil-one`

Alternatively you can execute the setup and deploy steps one-by-one as described below

## Interact, open dashboards and UIs

1) Establish proxy to cluster (leave open in separate terminal): `make k8s-proxy` 
2) List nodes: `make nodes-show`
3) List pods: `make pods-show`
4) Generate bearer token for accessing K8S dashboard: `make  k8s-dashboard-bearer-token-show`
5) Access K8S dashboard in your browser and enter token: `make k8s-dashboard-open`
6) Open Traefik UI in your browser: `make traefik-ui-open`
8) Show webpage in your browser: `make httpd-open`
8) Open Prometheus UI in your browser: `make prometheus-open`
9) Open Grafana dashboards in your browser: `make grafana-open`

Notes:
- Add the contents of `workstation/etc/hosts` to `/etc/hosts` of your workstation for steps 6 to 9

## Setup K8S inc. persistence and helm/tiller

1) Setup K8S cluster inc. persistence via GlusterFS+Heketi and helm/tiller for later deployments: `make k8s-setup`. 

Notes:
- `ceil-one` is set up as k8s master
- Danger: wipes thumb drives for setting up GlusterFS.
- Because of memory constraints the GlusterFS spans `ceil-two` to `ceil-four` but not `ceil-one`

## Deploy

1) Execute all deployments using `make all-deploy` or deploy step by step as documented below.
2) Interact, open dashboards and UIs as documented above.

## Delete deployments

1) All deployments provide an individual make target for deleting the deployment, e.g. `ngrok-delete`. Execute `make help` to see all commands.
2) Execute `make all-delete` to delete all deployments at once

## Remove K8S inc. persistence and helm/tiller

1) Execute `make k8s-remove`.

## Teardown

1) Execute `make teardown` to delete all deployments and remove K8S.

## Obstacles 

* Examples for setting up K8S on RPis mostly outdated and/or incomplete or making undocumented assumptions or not using Ansible correctly => full rewrite
* Current Kernel of hypriot does not setup pid cgroup which is used by newer K8S for QoS => downgrade K8S
* RBAC is rather new and not yet accounted for in deployment procedures of all tools and services => amend
* Traefik image of hypriot outdated, dashboard not useable => use original image given manifest lists 
* Some services do not yet compile docker images for ARM and/or do not use docker manifest lists properly => google for alternative images or wait for CNCF
* Mosts ansible playbooks do not provide a teardown role => build yourself

## Additional references

* https://medium.com/@evnsio/managing-my-home-with-kubernetes-traefik-and-raspberry-pis-d0330effea9a (ddns, vpn, let's encrypt)
* https://github.com/luxas/kubeadm-workshop (custom autoscaling, by luxas)
* http://slides.com/lucask/kubecon-berlin#/18 (multiplatform K8S, by luxas)
* https://luxaslabs.com/ (slides by luxas)
* https://medium.com/vescloud/kubernetes-storage-performance-comparison-9e993cb27271 (Kubernetes Storage Performance Benchmark)
* https://tobru.ch/kubernetes-on-orangepi-arm64/ (unsorted)
* https://medium.com/@carlosedp/multiple-traefik-ingresses-with-letsencrypt-https-certificates-on-kubernetes-b590550280cf (traefik,let's encrypt)
* https://medium.com/@carlosedp/building-a-hybrid-x86-64-and-arm-kubernetes-cluster-e7f94ff6e51d (unsorted)
* https://www.gopeedesignstudio.com/2018/07/13/glusterfs-on-arm/ (glusterfs on arm)
* https://stefanprodan.com/2018/expose-kubernetes-services-over-http-with-ngrok/ (ngrok, k8s)
* https://downey.io/blog/how-to-build-raspberry-pi-kubernetes-cluster/ (router)
* https://downey.io/blog/create-raspberry-pi-3-router-dhcp-server/ (router,dhcp)