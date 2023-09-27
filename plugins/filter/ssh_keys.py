__metaclass__ = type
from collections import defaultdict

import requests


def get_ssh_keys(username: str, keys: list) -> list:
    """Return ssh keys for a github username."""
    keys = keys if keys else []
    response = requests.get(f"https://github.com/{username}.keys")
    if response.status_code == 200:
        content = response.content.decode("utf-8")
        keys.append((username, [key for key in content.split("\n") if key.strip()]))
    return keys


def flatten_ssh_keys(keys: list, prefix: str) -> dict:
    """Return ssh keys for a github username."""
    data = {}
    for username, ssh_keys in keys:
        for idx, key in enumerate(ssh_keys):
            data[f"{prefix}-{username}-{idx:02d}"] = key
    return data


def do_keys_by_username(do_keys: list, prefix: str) -> dict:
    """Parse do_keys.

    "ssh_key": {
        "fingerprint": "32:bc:0a:a5:28:76:36:1e:c5:64:eb:25:92:69:83:8a",
        "id": 29458482,
        "name": "ericof-00",
        "public_key": "ssh-rsa ..."
    }
    """
    data = defaultdict(list)
    prefix_size = len(prefix) + 1
    for item in do_keys.get("results"):
        ssh_key = item.get("data").get("ssh_key")
        username = ssh_key["name"][prefix_size:-3]
        data[username].append(
            {
                "id": ssh_key["id"],
                "fingerprint": ssh_key["fingerprint"],
            }
        )
    return {k: v for k, v in data.items()}


class FilterModule:
    """Ansible core jinja2 filters"""

    def filters(self):
        return {
            "get_ssh_keys": get_ssh_keys,
            "flatten_ssh_keys": flatten_ssh_keys,
            "do_keys_by_username": do_keys_by_username,
        }
