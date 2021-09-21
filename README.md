# Run GitLab with podman

# Quickstart
```
# One shot
hacks/gitlab-setup.sh

# Manual Steps

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

# Notes

Add registry mirror

```
cat << YAML > /etc/containers/registries.conf.d/001-tigerlab.conf
[[registry]]
location = "git.tigerlab.io:6666"

[[registry]]
location = "podman.io"
[[registry.mirror]]
location = "git.tigerlab.io:6666"
YAML
```

Fix SELINUX context
```
semanage fcontext -l | grep ^/srv
chcon -t container_file_t -R /srv/containers
restorecon -RvF /srv/containers
```

Run gitlab with kube config in podman
```
podman play kube podman-kube.yml
```

Backup gitlab (podman)
```
# Run backups with shell
podman exec -it <name of container> /bin/bash
gitlab-ctl backup-etc
gitlab-ctl stop gitaly
gitlab-backup create
gitlab-ctl start gitaly

# Run backups without shell
podman exec -it <name of container> gitlab-ctl backup-etc
podman exec -it <name of container> gitlab-backup create
```

Restore gitlab (podman)
```
# Stop the processes that are connected to the database
podman exec -it <name of container> gitlab-ctl stop puma
podman exec -it <name of container> gitlab-ctl stop sidekiq

# Verify that the processes are all down before continuing
podman exec -it <name of container> gitlab-ctl status

# Run the restore
podman exec -it <name of container> gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce

# Restart the GitLab container
podman restart <name of container>

# Check GitLab
podman exec -it <name of container> gitlab-rake gitlab:check SANITIZE=true
```

Restore gitlab (podman) w/ shell
```
podman exec -it <name of container> /bin/bash

# Stop the processes that are connected to the database
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# Verify that the processes are all down before continuing
gitlab-ctl status

# Run the restore
gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce

# Restart the GitLab container
podman restart <name of container>

# Check GitLab
podman exec -it <name of container> gitlab-rake gitlab:check SANITIZE=true
```


Crontab Entry
```
cat << EOL > /etc/cron.daily/gitlab
15 04 * * 2-6  gitlab-ctl backup-etc && cd /etc/gitlab/config_backup && cp $(ls -t | head -n1) /secret/gitlab/backups/
EOL
```

## Podman 

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
