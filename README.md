# Run GitLab with podman

# Quickstart
```
# Install podman
dnf -y install podman

# Auto Updates (daily)
systemctl enable --now podman-auto-update.timer

# One shot
. hacks/gitlab-setup.sh
```

Manual Steps
```
# Setup Folders
GITLAB_ROOT=/srv/containers
sudo mkdir -p ${GITLAB_ROOT}/gitlab/{data,logs,config}

# Copy service file
sudo cp container-gitlab.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable --now container-gitlab

# Another quick check
sudo podman container ls
sudo systemctl status container-gitlab
```

# GitLab Notes

Backup gitlab
```
# Run backups with shell
podman exec -it podman-gitlab /bin/bash
gitlab-ctl backup-etc
#gitlab-ctl stop gitaly
gitlab-backup create
#gitlab-ctl start gitaly

# Run backups without shell
podman exec -it <name of container> gitlab-ctl backup-etc
podman exec -it <name of container> gitlab-backup create
```


Restore gitlab
```
podman exec -it podman-gitlab /bin/bash

# Stop the processes that are connected to the database
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# Verify that the processes are all down before continuing
gitlab-ctl status

# Run the restore
gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce

# Restart the GitLab container
podman restart podman-gitlab

# Check GitLab
podman exec -it podman-gitlab gitlab-rake gitlab:check SANITIZE=true
```

## Podman 

Add registry mirror

```
cat << TOML > /etc/containers/registries.conf.d/001-tigerlab.conf
[[registry]]
location = "git.tigerlab.io:6666"

[[registry]]
location = "podman.io"
[[registry.mirror]]
location = "git.tigerlab.io:6666"
TOML
```

Fix SELINUX context
```
semanage fcontext -l | grep ^/srv

chcon -t container_file_t -R /srv/containers
restorecon -RvF /srv/containers
```

Systemd
```
# Generate systemd service file
podman generate systemd --new --name --files gitlab

# Copy service file
sudo cp container-gitlab.service /etc/systemd/system/

# Reload systemd
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable --now container-gitlab

# Another quick check
sudo podman container ls
sudo systemctl status container-gitlab
```

Updates
```
# add the label
# --label "io.containers.autoupdate=registry"

# Manual Updates
podman auto-update

# Auto Updates (daily)
systemctl enable --now podman-auto-update.timer 
```

# Links
- https://www.redhat.com/sysadmin/manage-container-registries
- https://docs.gitlab.com/ee/raketasks/backup_restore.html
