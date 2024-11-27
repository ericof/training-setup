__metaclass__ = type


def parse_droplets(response: dict) -> list:
    """Return a list of droplets."""
    droplets = []
    for item in response.get("results", []):
        droplet = item.get("data", {}).get("droplet", {})
        if "name" not in droplet:
            continue
        name = droplet["name"]
        networks = droplet["networks"]["v4"]
        public_networks = [net for net in networks if net["type"] == "public"]
        ip_address = public_networks[0].get("ip_address")
        droplets.append({"name": name, "host": ip_address})
    return droplets


class FilterModule:
    """Ansible core jinja2 filters"""

    def filters(self):
        return {
            "parse_droplets": parse_droplets,
        }
