.PHONY: prepare-mac k8s-uptime k8s-df k8s-reboot one-ssh two-ssh three-ssh setup teardown k8s-setup k8s-remove k8s-proxy k8s-dashboard-bearer-token-show k8s-dashboard-open

help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "DevOps console for Project max" ; \
	printf "%-30s %s\n" "===============================" ; \
	printf "%-30s %s\n" "" ; \
	printf "%-30s %s\n" "Target" "Help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[36m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

%:      # thanks to chakrit
	@:    # thanks to Wi.lliam Pursell


prepare-mac: ## Prepare mac for provisioning (install homebrew and ansible, install packages via homebrew, update /etc/hosts etc.)
	workstation/MacOSX/bootstrap
	ansible-galaxy install -r workstation/MacOSX/ansible/requirements.yml
	ansible-playbook -i "localhost," workstation/MacOSX/ansible/playbook.yml --ask-become-pass
	ansible-playbook -i "localhost," workstation/Generic/ansible/playbook.yml --tags "hosts" --ask-become-pass
	ansible-galaxy install -r router/requirements.yaml || true
	ansible-galaxy install -r k8s/requirements.yaml || true

router-provision: ## Provision router for boot (flash SD card with OS)
	host/provision/router

one-provision: ## Provision ks8 node one for boot (flash SD card with OS)
	host/provision/one

two-provision: ## Provision ks8 node two for boot (flash SD card with OS)
	host/provision/two

three-provision: ## Provision ks8 node three for boot (flash SD card with OS)
	host/provision/three

four-provision: ## Provision ks8 node four for boot (flash SD card with OS)
	host/provision/four

workstation-route-add: ## Add route to k8s subnet via router
	router/scripts/route-to-subnet

workstation-route-del: ## Delete route to k8s subnet
	router/scripts/route-to-subnet-delete

router-df: ## Show df of router
	cd router && ansible -a "df -kh" all

router-uptime: ## Show uptime of router
	cd router && ansible -a uptime all

router-reboot: ## Reboot max-router
	cd router && ansible -a "shutdown -r now" all

router-check-ip: ## Check IP addresss of router
	cd router && ansible -a "hostname --ip" all

router-setup: ## Setup router, .ovpn file will be downloaded into router/out
	cd router && ansible-playbook setup.yml --tags "setup"

router-base: ## Setup base
	cd router && ansible-playbook setup.yml --tags "base"

router-thumb-drive: ## Setup thumb drive
	cd router && ansible-playbook setup.yml --tags "thumb_drive"

router-routing: ## Setup routing
	cd router && ansible-playbook setup.yml --tags "routing"

router-ddns: ## Setup DDNS
	cd router && ansible-playbook setup.yml --tags "ddns"

router-firewall: ## Setup Firewall
	cd router && ansible-playbook setup.yml --tags "firewall"

router-docker-registry-mirror: ## Setup docker registry mirror
	cd router && ansible-playbook setup.yml --tags "docker_registry_private"

router-docker-registry-private: ## Setup private docker registry
	cd router && ansible-playbook setup.yml --tags "docker_registry_private"

router-vpn: ## Setup VPN
	cd router && ansible-playbook setup.yml --tags "vpn"

one-ssh: ## ssh to one
	ssh root@max-one.dev

two-ssh: ## ssh to two
	ssh root@max-two.dev

three-ssh: ## ssh to three
	ssh root@max-three.dev

k8s-ping: ## Ping nodes
	cd k8s && ansible -m ping all

k8s-check-ip: ## Check IP addresses of nodes
	cd k8s && ansible -a "hostname --ip" all

k8s-uptime: ## Show uptime of nodes
	cd k8s && ansible -a uptime all

k8s-df: ## Show df of nodes
	cd k8s && ansible -a "df -kh" all

k8s-reboot: ## Reboot all k8s nodes
	cd k8s && ansible -a "shutdown -r now" all

k8s-setup: ## Setup cluster
	cd k8s && ansible-playbook setup.yml

k8s-proxy: ## Open proxy
	kubectl proxy

k8s-dashboard-bearer-token-show: ## Show dashboard bearer token
	k8s/scripts/dashboard-bearer-token-show

k8s-dashboard-open: ## Open Dashboarrd
	python -mwebbrowser http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default

k8s-remove: ## Remove previous installation of Kubernetes cluster
	cd k8s && ansible-playbook remove.yml

thumb-wipe: ## Wipe thump drives of nodes (not master)
	cd k8s && ansible-playbook thumb-wipe.yml

gluster-heketi-setup: ## Setup GlusterFS + Heketi for dynamic volume provisioning as default storage class backed by thumb drives
	cd k8s && ansible-playbook gluster-heketi-setup.yml

gluster-heketi-remove: ## Remove GlusterFS + Heketi incl. wiping thumb drives (YOU WILL LOSE ALL DATA ON ALL THUMB DRIVES)
	cd k8s && ansible-playbook gluster-heketi-remove.yml

helm-setup: ## Init helm CLI and deploy tiller  to cluster
	cd k8s && ansible-playbook helm-setup.yml

helm-remove: ## Reset helm CLI and delete tiller from cluster
	cd k8s && ansible-playbook helm-remove.yml

nodes-show: ## Show nodes
	kubectl get nodes

pods-show: ## Show pods
	kubectl get pods --all-namespaces -o wide

deployments-show: ## Show deployments
	kubectl get deployments --all-namespaces

services-show: ## Show services
	kubectl get services --all-namespaces

endpoints-show: ## Show endpoints
	kubectl get endpoints --all-namespaces

metallb-deploy: ## Deploy MetalLB
	deployment/metallb/deploy

metallb-delete: ## Delete MetalLB
	deployment/metallb/delete

ingress-show: ## Show ingress
	kubectl get ingress --all-namespaces

traefik-deploy: ## Deploy traefik ingress controller
	deployment/traefik/deploy

traefik-delete: ## Delete traefik ingress controller
	deployment/traefik/delete

traefik-ui-open: ## Open traefik UI
	python -mwebbrowser http://traefik-ui.max.local

httpd-deploy: ## Deploy httpd
	deployment/httpd/deploy

httpd-open: ## Open httpd
	python -mwebbrowser http://httpd.max.local

httpd-delete: ## Delete httpd
	deployment/httpd/delete

prometheus-deploy: ## Deploy prometheus
	deployment/prometheus/deploy

prometheus-open: ## Open prometheus
	python -mwebbrowser http://prometheus.max.local
	python -mwebbrowser http://alertmanager.max.local
	python -mwebbrowser http://pushgateway.max.local

prometheus-delete: ## Delete prometheus
	deployment/prometheus/delete

grafana-deploy: ## Deploy grafana
	deployment/grafana/deploy

grafana-admin-password-show: ## Show grafana password
	kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

grafana-open: ## Open grafana
	python -mwebbrowser http://grafana.max.local

grafana-delete: ## Delete grafana
	deployment/grafana/delete

kubewatch-deploy: ## Deploy kubewatch
	deployment/kubewatch/deploy

kubewatch-delete: ## Delete kubewatch
	deployment/kubewatch/delete

podinfo-deploy: ## Deploy podinfo
	deployment/podinfo/deploy

podinfo-delete: ## Delete podinfo
	deployment/podinfo/delete

ngrok-deploy: ## Deploy ngrok
	deployment/ngrok/deploy

ngrok-tunnel-port-exposed-show: ## Show port exposed by ngrok-tunnel
	kubectl get --namespace ngrok -o jsonpath="{.spec.ports[0].nodePort}" services tunnel-ngrok

ngrok-status: ## Show ngrok status
	python -mwebbrowser http://max-one.local:31742/status

ngrok-delete: ## Delete ngrok
	deployment/ngrok/delete

piphp-deploy: ## Deploy piphp
	deployment/piphp/deploy

piphp-delete: ## Delete piphp
	deployment/piphp/delete

all-deploy: metallb-deploy traefik-deploy httpd-deploy prometheus-deploy grafana-deploy kubewatch-deploy ## Execute all deployments

all-delete: ngrok-delete podinfo-delete kubewatch-delete grafana-delete prometheus-delete httpd-delete traefik-delete metallb-delete ## Delete all deployments

setup: thumb-wipe k8s-setup all-deploy  ## Setup K8S, deploy all - DANGER: wipes thumb drives

teardown: all-delete k8s-remove ## Delete all deployments, remove K8S