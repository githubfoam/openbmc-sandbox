IMAGE := alpine/fio
APP:="scripts/containerd.sh"



deploy-openbmc:
	bash scripts/deploy-openbmc.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-libvirt deploy-vagrant deploy-packer deploy-terraform push-image
