# Firewall & IP Tables Management 🔥🛡️

## Objective

Interns will learn how to secure AWS EC2 instances using `iptables` and basic firewall rules. This includes configuring allow/deny rules, logging traffic, and testing connectivity.

---

## Task Requirements

1. Launch **2 AWS EC2 instances** (Linux-based).
2. Configure `iptables` rules on both instances:
	- Allow SSH (22), HTTP (80), HTTPS (443) ✅
	- Deny all other incoming connections ❌
	- Allow outgoing connections to internet 🌐
	- Log dropped packets to `/var/log/iptables.log` 📝
3. Create **custom firewall chains**:
	- Example chains: `MY_FIREWALL_IN`, `MY_FIREWALL_OUT`
	- Apply those chains to INPUT/OUTPUT
4. Test rules:
	- Try to access blocked ports from another EC2 instance
	- Ensure allowed ports are accessible
5. Document everything:
	- Commands used to configure iptables
	- How to persist rules after reboot
	- Screenshots/log outputs demonstrating working rules 📸

---

## Optional Challenge ⚡

- Add rate-limiting rules to protect SSH from brute force attacks
