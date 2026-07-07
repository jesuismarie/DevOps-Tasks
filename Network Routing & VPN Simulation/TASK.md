# Network Routing & VPN Simulation 🌐🚦

## Objective

Interns will learn how to manage routing tables, static routes, and simulate simple VPN-like routing between two EC2 instances.

---

## Task Requirements

1. Launch **2 AWS EC2 instances** (Linux-based).
2. Configure **static routes** between instances:
	- Instance 1: route traffic to Instance 2 for a private subnet (e.g., 10.10.0.0/24)
	- Instance 2: route traffic to Instance 1 for another subnet (e.g., 10.20.0.0/24)
3. Test routing:
	- Ping from one instance to another using private IP addresses ✅
	- Verify connectivity via traceroute/tracert 🌐
4. Simulate **VPN routing**:
	- Use a Linux interface like `tun0` (or `tap0`) to create a virtual network
	- Add routes to send traffic from one instance to the other through the virtual interface
5. Document everything:
	- Routing table changes
	- Commands used to configure routes
	- Screenshots/log outputs demonstrating traffic flow
	- Diagram of subnet & routing setup 🖼️

---

## Optional Challenge ⚡

- Add NAT rules to allow traffic from private subnet to internet via one instance
