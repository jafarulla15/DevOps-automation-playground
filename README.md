"# DevOps-automation-playground" 

Step 1 — Prepare Ubuntu:

SSH into your Ubuntu VM and run:
sudo apt update
sudo apt upgrade -y

**Give it a static IP.** DHCP will eventually hand your VM a different address
and every TLS certificate, kubeconfig and inventory entry will break at once.
Either reserve the MAC in your router, or set it in netplan:

```bash
sudo vi /etc/netplan/50-cloud-init.yaml
```

```yaml
network:
  version: 2
  ethernets:
    ens33:                        # check yours with `ip -br link`
      dhcp4: false
      addresses: [192.168.1.50/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
```

```bash
sudo chmod 600 /etc/netplan/50-cloud-init.yaml
sudo netplan apply
ip -br addr
```
**If you disconnected from internet after setting up the static IP** DHCP will eventually hand your VM a different address
and every TLS certificate, kubeconfig and inventory entry will break at once.
Either reserve the MAC in your router, or set it in netplan:

Yes. The Netplan configuration itself is mostly correct, but 192.168.1.1 must actually be the gateway of the VMware network your Ubuntu VM is connected to.
Since you're running Ubuntu in VMware on your Windows laptop, this is very likely a VMware network mismatch.

A. First check your current network
Run:
```
ip -br addr
```
Then:
```
ip route
```
And:
```
ip route get 8.8.8.8
```
Also check DNS:
```
resolvectl status
```
The most important thing is the output of:
```
ip route
```
You should see something like:
```
default via 192.168.1.1 dev ens33
192.168.1.0/24 dev ens33 proto kernel scope link src 192.168.1.50
```
If you don't actually have a 192.168.1.1 gateway, internet won't work.

B. Very likely issue: VMware network

In VMware, check:
```
VM → Settings → Network Adapter
```
You will normally have one of these:
```
NAT
```
This is usually the easiest choice for your setup.

```
Bridged
```
The VM gets an IP from the same network as your physical Windows machine.
```
Host-only
```

⚠️ Host-only normally does not provide Internet access.

For your DevOps training VM, I'd recommend NAT.

C. If VMware is using NAT

Don't assume:
```
via: 192.168.1.1
```
Your VMware NAT gateway could be something like:
```
192.168.174.2
```
or:
```
192.168.237.2
```
depending on your VMware configuration.
Check the VMware network configuration on Windows.

Open:
```
VMware → Edit → Virtual Network Editor
```
Look at:
```
VMnet8
```
For example, you might see:
```
Subnet IP:      192.168.174.0
Subnet mask:    255.255.255.0
NAT Gateway:    192.168.174.2
```
Then your Ubuntu static configuration should use that network.
For example:
```
network:
  version: 2
  ethernets:
    ens33:
      dhcp4: false
      addresses:
        - 192.168.174.50/24
      routes:
        - to: default
          via: 192.168.174.2
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
```
Then:
```
sudo netplan apply
```

