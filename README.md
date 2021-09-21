# Run GitLab with podman

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
gitlab-backup create

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

```
cat << EOL > /etc/cron.daily/gitlab
15 04 * * 2-6  gitlab-ctl backup-etc && cd /etc/gitlab/config_backup && cp $(ls -t | head -n1) /secret/gitlab/backups/
EOL
```

# Links
- https://www.redhat.com/sysadmin/manage-container-registries
