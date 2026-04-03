# Systemd Service Persistence & Blue Team Telemetry
[https://roadmap.sh/projects/dummy-systemd-service](https://roadmap.sh/projects/dummy-systemd-service)

## Objective
This project demonstrates the creation, management, and monitoring of a custom systemd daemon in Linux. While originally a system administration exercise, this lab is approached from a **Blue Team / SOC perspective** to understand how threat actors establish boot persistence and how analysts can hunt for these anomalies using native Linux logging.

## Concepts Covered
* **Linux Filesystem Hierarchy Standard (FHS):** Proper placement of local executables.
* **Systemd Configuration:** Writing `.service` unit files, managing `ExecStart`, and configuring `Restart` parameters.
* **Boot Persistence:** Utilizing `systemctl enable` to hook a service into `multi-user.target`.
* **Log Analysis & Threat Hunting:** Correlating custom application logs with `journald` process state telemetry to identify violent process terminations (`SIGKILL`) and automatic respawns.

---

## Execution Steps

### 1. Creating the Payload
To blend in with standard administrative practices and adhere to the FHS, the custom script is placed in `/usr/local/bin/` rather than a user directory or a temporary folder.

**File:** `/usr/local/bin/dummy.sh`
**Command:** `sudo vim usr/local/bin/dummy.sh`
```bash
#!/bin/bash

while true; do
  echo "Dummy service is running..." >> /var/log/dummy-service.log
  sleep 30
done
```
*Note:* The script is made executable using `sudo chmod +x`.

**Testing the Script**
```bash
sudo bash /usr/local/bin/dummy.sh

less /var/log/dummy-service.log
```

---

### 2. Establishing the Service & Persistence Mechanism
The unit file is created in `/etc/systemd/system/`, the standard directory for administrator-created services.

**File:** `/etc/systemd/system/dummy.service`
**Command:** `sudo vim /etc/systemd/system/dummy.service`
```Ini
[Unit]
Description=SOC Training - Dummy Persistence Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dummy.sh
Restart=always

[Install]
WantedBy=multi-user.target
```
- [Unit]: Metadata. `After=` ensures the system doesn't try to start this service before the networking subsystem is up.
- [Service]: Execution logic.

*Security Context:* The `ExecStart` directive reveals the exact path of the payload. When you are analyzing a suspicious service, `ExecStart` is the very first thing you check—it tells you exactly what malicious payload is being detonated. The` WantedBy` directive under `[Install]` is what allows the service to achieve reboot persistence when enabled. `Restart=always` ensures the process respawns even if forcefully killed. From a Blue Team perspective, this exact line is how an attacker achieves reboot persistence.

---

### 3. Activating the Service
The following commands hook the service into the OS and start the daemon.

```bash
sudo systemctl daemon-reload
sudo systemctl start dummy
sudo systemctl enable dummy   # Creates the symlink for boot persistence
sudo systemctl status dummy
```

---

### 4. Blue Team Log Hunt: Simulating an Investigation
A common mistake during incident response is simply killing a malicious Process ID (PID) without investigating the underlying persistence mechanism. This lab simulates that scenario.

**The Test:**

- [ ] Open Terminal A and watch custom application log: `sudo tail -f /var/log/dummy-service.log`

- [ ] Open Terminal B and watch the system service log: `sudo journalctl -u dummy.service -f`

- [ ] Open Terminal C and find your PID: `systemctl status dummy.` then execute the kill command: `sudo kill -9 <PID>`


**The Telemetry Output (`journalctl`):**

```Plaintext
systemd[1]: dummy.service: Main process exited, code=killed, status=9/KILL
systemd[1]: dummy.service: Failed with result 'signal'.
systemd[1]: dummy.service: Scheduled restart job, restart counter is at 1.
systemd[1]: Started dummy.service - SOC Training - Dummy Persistence Service.
```

**Analysis:**
Because the standard output was redirected to `/var/log/dummy-service.log`, journald was blind to the echo statements. However, `journald` still tracked the process state. The logs clearly show the process being terminated (`status=9/KILL`) and immediately respawning due to the `Restart=always` configuration. This highlights the importance of analyzing systemd logs to track persistence mechanisms rather than solely relying on application-level logs.

---

### 5. Remediation & Cleanup
To completely remove the service and break persistence.

```bash
sudo systemctl stop dummy
sudo systemctl disable dummy
sudo rm /etc/systemd/system/dummy.service
sudo rm /usr/local/bin/dummy.sh
sudo rm /var/log/dummy-service.log
sudo systemctl daemon-reload
```
