check-variables:
ifndef PROJECT
  $(error PROJECT is undefined)
endif
ifndef IMAGE_NAME
  $(error IMAGE_NAME is undefined)
endif
ifndef DOCKER_COMPOSE_PATH
  DOCKER_COMPOSE_PATH=..
endif

generate-secrets:
	${DOCKER_COMPOSE_PATH}/generate-ssl-certs.sh

build: check-variables generate-secrets
	mkdir -p files/compose/${IMAGE_NAME}; \
	cp ${DOCKER_COMPOSE_PATH}/.*.env ${DOCKER_COMPOSE_PATH}/*.yml ${DOCKER_COMPOSE_PATH}/COMPOSE_README.md files/compose/${IMAGE_NAME}/; \
	cp -R ${DOCKER_COMPOSE_PATH}/.az-mount ${DOCKER_COMPOSE_PATH}/aws.setup.d ${DOCKER_COMPOSE_PATH}/config ${DOCKER_COMPOSE_PATH}/data ${DOCKER_COMPOSE_PATH}/docker ${DOCKER_COMPOSE_PATH}/notebooks files/compose/${IMAGE_NAME}/; \
	packer build -var 'project_id=${PROJECT}' -var 'image_name=${IMAGE_NAME}' packer.json; \
	rm -rf files/compose/${IMAGE_NAME};


force-build: check-variables generate-secrets
	mkdir -p files/compose/${IMAGE_NAME}; \
	cp ${DOCKER_COMPOSE_PATH}/.*.env ${DOCKER_COMPOSE_PATH}/*.yml ${DOCKER_COMPOSE_PATH}/COMPOSE_README.md files/compose/${IMAGE_NAME}/; \
	cp -R ${DOCKER_COMPOSE_PATH}/.az-mount ${DOCKER_COMPOSE_PATH}/aws.setup.d ${DOCKER_COMPOSE_PATH}/config ${DOCKER_COMPOSE_PATH}/data ${DOCKER_COMPOSE_PATH}/docker ${DOCKER_COMPOSE_PATH}/notebooks files/compose/${IMAGE_NAME}/; \
	packer build -force -var 'project_id=${PROJECT}' -var 'image_name=${IMAGE_NAME}' packer.json; \
	rm -rf files/compose/${IMAGE_NAME};
