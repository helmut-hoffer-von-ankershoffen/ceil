# `max`: Auto-provisioned RPi cluster running amd64 on bare-metal

Enter `make help` to see available commands.

## Goals

* Setup auto-provisioned amd64 cluster running K8S on bare-metal inc. router
* Educate myself on Ansible + K8S + GitOps for CI/CD/PD from bottom to top
* Refresh knowledge regarding networking and Python
* Enhanced PHP/SF4 stack for K8S supporting HPA, progressive deployments and a/b testing
* Advanced networking and firewalling to use  `max-one` for router *and* k8s master to optimize budget

## Tasks

### Phase 0: Hardware

- [x] Wire up three gigabyte bace 3160 and accessories

![alt text](https://raw.githubusercontent.com/helmuthva/ceil/max/doc/assets/max.jpg "Max Stack")

### Phase 1: Foundation

- [x] Central CloudOps entrypoint is `make`
- [x] Setup and teardown of all steps individually
- [x] Setup and teardown in one step
- [x] Setup of k8s cluster on amd64 using Ansible inc. weave networking and k8s dashboard
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
- [x] Dynamically update domain vpn.maxxx.pro (or similar) using ddclient and Cloudflare v4 API
- [x] Raise Firewall using ufw
- [x] Act as Docker registry mirror using official docker image `registry:2`
- [x] Act as private Docker registry
- [ ] kail and harbor
- [ ] ngrok

### Phase 4: PiWatch

- [x] Deploy kubewatch to push K8S events to arbitrary webhook
- [ ] Configure to push to PiTraffic of ceil cluster

### Phase 5: PiPHP

- [ ] Deploy amd64 version of PiPHP
- [ ] Automate workflow

### Phase 6: Auto-Scaling
- [ ] Autoscaling using HPA and custom metrics
- [ ] Zero-Scaling using Osiris
- [ ] Relevant dashboards in grafana

### Phase 7: Mesh-Networking
- [ ] Istio for Mesh-Networking
- [ ] Visibility tools
- [ ] Additional tools

### Phase 8: GitOps and Progressive Delivery

- [ ] Flagger for Helm using mesh network
- [ ] Canary deployments using mesh network
- [ ] ...

### Phase 9: CI and emphemeral test environments
- [ ] Setup CI using JenkinsX
- [ ] ...


### Phase 10: A/B testing

- [ ] Using mesh network
- [ ] ...

### Phase 11: Sharing is caring

- [x] Open source under GPlv3
- [x] Links to useful material for further studies
- [ ] GitHub Page
- [ ] Prepare interactive install script automating the step to manually copy and edit `.tpl` files
- [ ] Write a series of blog posts
- [ ] Prepare a workshop presentation
- [ ] Educate peers in meetups

## Layers and tools

* CloudOps
  * Workstation: MacBook Pro
  * Package manager: Homebrew
  * Entrypoints: `make` and `kubectl` (GitOps in second step)
* Hardware
  * SBCs: 3x Gigabyte bace 3160 with 8GB SO-DIMM
  * Storage: 3x 128GiB SSDs (OS + containers) + 1x 128GiB USB ThumbDrive (Volumes for Docker registries on router) + 3x 128GiB USB ThumbDrives (GlusterFS) 
  * Networking: 5-port GBit/s switch + WiFi router connected to router
* Software
  * OS: Debian Stretch
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

## Install this repository

1) Fork this repository and clone to your workstation
2) Walk all files with suffix `.tpl`, create a copy in the same directory without said suffix and enter specifics where invited by capital letters

## Provision Mini PCs

1) Manual provisioning of base OS on servers by installing Debian Stretch from ISO on USB thumbs
2) Manual provisioning of wifi connectivity on `max-one` for bootstrapping

## Setup router

1) Make a DHCP reservation for `max-router` on your home or company WiFi router with IP address `192.168.0.111` -  it will register as `max-one` at your WiFi router
2) Set up a static route to the k8s subnet `12.0.0.0` with `192.168.0.111` as gateway in your company or home wifi router - if this is not achievable use `make workstation-route-add` to add a route on your workstation.
3) Reboot `max-one` to pickup its IP address via `make router-reboot` - it will register via ZeroConf/Avahi on your workstation as `max-one.local`
4) Check via `make router-check-ip` if the IP address has been picked up
5) Setup networking services on router using `make router-setup`
6) Add `192.168.0.111` as the second nameserver for the (WiFi) connection of your workstation using system settings
7) Wait for 1 minute than check if the k8s nodes (`max-{one,two,three}.dev`) have picked up their designated IP addresses from the router in the range `12.0.0.101` to `12.0.0.103`:  `make k8s-check-ip` 

Notes:
- Danger: wipes thumb drive in router
- It might take some time until the Zeroconf/Avahi distributed the name `max-router.local` in your network. You can check by ssh'ing into the router via `make router-ssh`
- The router will manage / route to the subnet `12.0.0.[0-128]` (`12/25`) the K8S nodes will life in and act as their DHCP and DNS server
- Furthermore the router acts as an OpenVPN server and updates the IP address of `vpn.max.pro` via DDNS
- After setting up the router wait for a minute to check if the k8s nodes have picked up the designated IPs using `make k8s-check-ip`
- After the k8s nodes picked up their IP addresses you can ssh into them using `make {one,two,three}-ssh`
- If on your workstation `nslookup max-{one,two,three}.dev` works but `ping max-{one,two,three}.dev` does not, reestablish the (WiFi) connection of your workstation
- If you want to play with the traffic lights mounted on top of the router: `make router-traffic`
- The last step of the router setup is building [PiWatch](https://github.com/helmuthva/piwatch) which takes ca. 15 minutes for the 1st build
- Last but not least the router provides a docker registry mirror and private docker registry consumed by the K8S nodes

## Setup K8S and execute all deployments

1) Execute `make setup` to setup K8S inc. persistence and deploy everything at once - takes ca. 45 minutes. 

Notes:
- `max-one` is set up as k8s master
- Danger: wipes thumb drives for setting up GlusterFS.

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

1) Wipe thumb drives for GlusterFS using `make thumb-wipe`
2) Setup K8S cluster inc. persistence via GlusterFS+Heketi and helm/tiller for later deployments: `make k8s-setup`. 

Notes:
- `max-one` is set up as k8s master

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

* RBAC is rather new and not yet accounted for in deployment procedures of all tools and services => amend
* Mosts ansible playbooks do not provide a teardown role => build yourself

## Other Notes

### /etc/hosts on workstation

12.0.0.102 max-two max-two.dev
12.0.0.103 max-three max-three.dev

12.0.0.102 httpd.max.local
12.0.0.102 traefik-ui.max.local
12.0.0.102 prometheus.max.local
12.0.0.102 alertmanager.max.local
12.0.0.102 pushgateway.max.local
12.0.0.102 grafana.max.local

## Additional references

* https://github.com/luxas/kubeadm-workshop (custom autoscaling, by luxas)
* https://luxaslabs.com/ (slides by luxas)
* https://medium.com/vescloud/kubernetes-storage-performance-comparison-9e993cb27271 (Kubernetes Storage Performance Benchmark)
* https://medium.com/@carlosedp/multiple-traefik-ingresses-with-letsencrypt-https-certificates-on-kubernetes-b590550280cf (traefik,let's encrypt)
* https://stefanprodan.com/2018/expose-kubernetes-services-over-http-with-ngrok/ (ngrok, k8s)
* https://github.com/coredns/coredns/issues/2087 (coreDNS and dnsmasq)