check-variables:
ifndef PROJECT
  $(error PROJECT is undefined)
endif
ifndef IMAGE_NAME
  $(error IMAGE_NAME is undefined)
endif

build: check-variables
	mkdir -p packer-docker-compose/files/compose/${IMAGE_NAME}; \
	cp .*.env *.yml packer-docker-compose/files/compose/${IMAGE_NAME}/; \
	cp -R aws.setup.d config data docker notebooks packer-docker-compose/files/compose/${IMAGE_NAME}/; \
	cd packer-docker-compose; \
	packer build -var 'project_id=${PROJECT}' -var 'image_name=${IMAGE_NAME}' packer.json; \
	cd ..; \
	rm -rf packer-docker-compose/files/compose/${IMAGE_NAME};


force-build: check-variables
	mkdir -p packer-docker-compose/files/compose/${IMAGE_NAME}; \
	cp .*.env *.yml packer-docker-compose/files/compose/${IMAGE_NAME}/; \
	cp -R aws.setup.d config data docker notebooks packer-docker-compose/files/compose/${IMAGE_NAME}/; \
	cd packer-docker-compose; \
	packer build -force -var 'project_id=${PROJECT}' -var 'image_name=${IMAGE_NAME}' packer.json; \
	cd ..; \
	rm -rf packer-docker-compose/files/compose/${IMAGE_NAME};
