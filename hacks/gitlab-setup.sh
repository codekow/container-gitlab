#!/bin/bash
#set -x

SUDO=sudo
PODMAN_CMD="${SUDO} podman"
#PODMAN_OPT='generate systemd'

GITLAB_ROOT=/srv/containers
GITLAB_SSH_PORT=2222
GITLAB_IMAGE=docker.io/gitlab/gitlab-ce:latest
GITLAB_HOSTNAME=gitlab

gitlab_setup_dirs(){
  ${SUDO} mkdir -p ${GITLAB_ROOT}/gitlab/{data,logs,config}
}

gitlab_pull_image(){
  ${PODMAN_CMD} pull ${GITLAB_IMAGE}
}

gitlab_podman_start_selinux(){

${PODMAN_CMD} ${PODMAN_OPT:-run} --detach \
  --label "io.containers.autoupdate=registry" \
  --hostname ${GITLAB_HOSTNAME} \
  --publish 443:443 \
  --publish 80:80 \
  --publish 5000:5000 \
  --publish ${GITLAB_SSH_PORT}:22 \
  --memory 8g \
  --cpus 2 \
  --name gitlab \
  --restart always \
  --volume ${GITLAB_ROOT}/gitlab/config:/etc/gitlab:Z \
  --volume ${GITLAB_ROOT}/gitlab/logs:/var/log/gitlab:Z \
  --volume ${GITLAB_ROOT}/gitlab/data:/var/opt/gitlab:Z \
  ${GITLAB_IMAGE}

}

gitlab_podman_cleanup(){
  ${PODMAN_CMD} rm -f gitlab 
}

gitlab_podman_gen_kube(){
  ${PODMAN_CMD} generate kube gitlab
}

gitlab_podman_gen_systemd(){
  ${PODMAN_CMD} generate systemd --new --name --files gitlab
}

gitlab_podman_setup_systemd(){

# Copy service file
${SUDO} cp container-gitlab.service /etc/systemd/system/

# Reload systemd
${SUDO} systemctl daemon-reload

# Enable and start the service
${SUDO} systemctl enable --now container-gitlab

# Another quick check
${SUDO} podman container ls
${SUDO} systemctl status container-gitlab
 
}

gitlab_setup_dirs
gitlab_pull_image
#gitlab_podman_start_selinux
gitlab_podman_setup_systemd
