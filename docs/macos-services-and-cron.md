# macOS Services and Cron Jobs

macOS does not use `systemd`. The native service manager is `launchd`, configured
with `.plist` files and managed with `launchctl`.

Cron is still available on macOS, but `launchd` is the preferred macOS-native
option for new scheduled jobs.

## launchd Service Files

### Common Paths

| Path | Scope | Runs as |
| --- | --- | --- |
| `~/Library/LaunchAgents/` | Current user | Logged-in user |
| `/Library/LaunchAgents/` | All users | Logged-in user |
| `/Library/LaunchDaemons/` | System service | `root`, unless `UserName` is set |
| `/System/Library/LaunchAgents/` | Apple-managed | Do not edit |
| `/System/Library/LaunchDaemons/` | Apple-managed | Do not edit |

Use `LaunchAgents` for user jobs and `LaunchDaemons` for background services
that should run without a user login.

### Example Service

Create `~/Library/LaunchAgents/com.example.hello.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.example.hello</string>

  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>echo "hello from launchd"</string>
  </array>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/com.example.hello.out.log</string>

  <key>StandardErrorPath</key>
  <string>/tmp/com.example.hello.err.log</string>
</dict>
</plist>
```

Set permissions:

```console
chmod 644 ~/Library/LaunchAgents/com.example.hello.plist
```

For `/Library/LaunchDaemons/`, use:

```console
sudo chown root:wheel /Library/LaunchDaemons/com.example.hello.plist
sudo chmod 644 /Library/LaunchDaemons/com.example.hello.plist
```

### Load, Start, Stop, Restart

User agent:

```console
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.example.hello.plist
launchctl kickstart -k gui/$(id -u)/com.example.hello
launchctl bootout gui/$(id -u)/com.example.hello
```

System daemon:

```console
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.hello.plist
sudo launchctl kickstart -k system/com.example.hello
sudo launchctl bootout system/com.example.hello
```

`kickstart -k` is the closest equivalent to restarting a `systemd` service.

### Check Status

User agent:

```console
launchctl print gui/$(id -u)/com.example.hello
launchctl list | grep com.example.hello
```

System daemon:

```console
sudo launchctl print system/com.example.hello
sudo launchctl list | grep com.example.hello
```

Useful fields in `launchctl print`:

| Field | Meaning |
| --- | --- |
| `state` | Current state, such as `running` or `waiting` |
| `pid` | Process ID if currently running |
| `last exit code` / `LastExitStatus` | Last process exit status |
| `program` / `program arguments` | Command being executed |

### Validate a plist

```console
plutil -lint ~/Library/LaunchAgents/com.example.hello.plist
```

### Logs and Errors

If the plist has `StandardOutPath` and `StandardErrorPath`, check those files:

```console
tail -f /tmp/com.example.hello.out.log
tail -f /tmp/com.example.hello.err.log
```

Check macOS unified logs:

```console
log show --last 1h --predicate 'process == "launchd"'
log show --last 1h --predicate 'eventMessage CONTAINS "com.example.hello"'
```

Stream live logs:

```console
log stream --predicate 'eventMessage CONTAINS "com.example.hello"'
```

### Last Run Time

`launchd` does not provide a simple `systemctl status`-style "last run" field
for every job. Common ways to find it are:

```console
launchctl print gui/$(id -u)/com.example.hello
log show --last 24h --predicate 'eventMessage CONTAINS "com.example.hello"'
ls -l /tmp/com.example.hello.out.log /tmp/com.example.hello.err.log
```

For scheduled jobs, it is often best to write a timestamp in the script itself:

```sh
date -u +"%Y-%m-%dT%H:%M:%SZ job started"
```

### Scheduled launchd Job

Run every 15 minutes:

```xml
<key>StartInterval</key>
<integer>900</integer>
```

Run every day at 02:30:

```xml
<key>StartCalendarInterval</key>
<dict>
  <key>Hour</key>
  <integer>2</integer>
  <key>Minute</key>
  <integer>30</integer>
</dict>
```

## Cron Jobs

### Edit Cron Jobs

Current user:

```console
crontab -e
crontab -l
crontab -r
```

Another user:

```console
sudo crontab -u username -e
sudo crontab -u username -l
```

System-wide cron files may also exist at:

```text
/etc/crontab
/etc/periodic/
/usr/lib/cron/tabs/
```

Prefer `crontab -e` over editing spool files directly.

### Example Cron Job

Run every 15 minutes:

```cron
*/15 * * * * /path/to/script.sh >> /tmp/example-cron.log 2>&1
```

Run every day at 02:30:

```cron
30 2 * * * /path/to/script.sh >> /tmp/example-cron.log 2>&1
```

Cron uses a small environment. Use absolute paths and set needed environment
variables in the cron entry or in the script.

### Check if Cron Is Active

Check the macOS cron daemon:

```console
sudo launchctl print system/com.vix.cron
sudo launchctl list | grep cron
```

Check installed jobs:

```console
crontab -l
sudo crontab -u username -l
```

There is no built-in per-job active status like `systemctl status`. A cron job is
"active" if it is present in the crontab and the cron daemon is running.

### Restart Cron

```console
sudo launchctl kickstart -k system/com.vix.cron
```

### Cron Logs, Errors, and Last Run

Check the output file if the job redirects stdout and stderr:

```console
tail -f /tmp/example-cron.log
ls -l /tmp/example-cron.log
```

Check unified logs:

```console
log show --last 24h --predicate 'process == "cron"'
log stream --predicate 'process == "cron"'
```

If a cron job produces output and does not redirect it, cron may try to send it
as local mail:

```console
mail
```

The most reliable way to know the last run time is to log it from the script:

```sh
date -u +"%Y-%m-%dT%H:%M:%SZ cron job started" >> /tmp/example-cron.log
```

## Quick Reference

| Task | launchd | cron |
| --- | --- | --- |
| List jobs | `launchctl list` | `crontab -l` |
| Check one job | `launchctl print gui/$(id -u)/LABEL` | Check `crontab -l` and logs |
| Start now | `launchctl kickstart gui/$(id -u)/LABEL` | Run the command manually |
| Restart | `launchctl kickstart -k gui/$(id -u)/LABEL` | `sudo launchctl kickstart -k system/com.vix.cron` |
| Stop/unload | `launchctl bootout gui/$(id -u)/LABEL` | Remove or comment out crontab entry |
| Validate config | `plutil -lint file.plist` | `crontab -l` |
| Logs | `StandardOutPath`, `StandardErrorPath`, `log show` | Redirected log file, `log show`, `mail` |

## Role Defaults on macOS

This role detects Darwin/macOS from Ansible facts and uses a native launchd plist
instead of a Linux systemd unit.

Default generated paths:

```text
~/Library/LaunchAgents/deploy-service.<service>.plist
~/.local/bin/deploy-service.<service>
~/Library/Logs/deploy-service/<service>.out.log
~/Library/Logs/deploy-service/<service>.err.log
~/.config/deploy-service/<service>.env
~/.local/share/deploy-service/<service>/
```

The role uses `dystemctl` through its `systemctl` command:

```console
systemctl enable deploy-service.<service>
systemctl restart deploy-service.<service>
systemctl status deploy-service.<service>
journalctl -u deploy-service.<service>
```
