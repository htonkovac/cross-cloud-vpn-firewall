# cross-cloud-vpn-firewall

This repo deploys 2 (simple) cloud environments and connects them with a Wireguard VPN. Cloud resources are provisioned with terraform. Both environments are hosted in Azure cloud and consist of:
- a VNET with 1 subnet
- a linux machine acting as the "VPN hub"
- few other machines for testing

To get a linux machine acting as a "VPN hub" I've used ansible. Key takeaways:
- ip_forward needs to be set (was on by default)
- nsg and route tables in azure need to be set properly (allow 10.0.0.0/8 traffic and route traffic to the VPN hub)
- wg-quick utility can help with setting up the proper routes # in my initial setup this wasn't working - after tearing down everything and rebuilding the routes were autocreated by wg-quick
- ip tables needs to have forwardin rules set to accept packets.

-systemd?
![image](docs/image.png)
___
## Sources

1. https://tailscale.com/blog/how-nat-traversal-works/
2. https://github.com/facebookincubator/katran
3. https://www.wireguard.com/
4. https://dev.to/stack-labs/introduction-to-taskfile-a-makefile-alternative-h92
5. https://github.com/mina-alber/wireguard-ansible/blob/master/tasks/main.yml
6. https://stackoverflow.com/questions/40086613/ansible-jinja2-string-comparison # "You don't need quotes and braces to refer to variables inside expressions"
7. https://docs.ansible.com/ansible/latest/user_guide/playbooks_vars_facts.html
8. https://github.com/tommywalkie/excalidraw-cli
9. https://ro-che.info/articles/2021-02-27-linux-routing

