
#!/usr/bin/env python3
import os, yaml, json
ROOT = os.path.dirname(os.path.dirname(__file__))
products = []
for base, dirs, files in os.walk(os.path.join(ROOT, "collections")):
    if "status.yaml" in files:
        import_path = os.path.join(base, "status.yaml")
        with open(import_path, "r") as f:
            data = yaml.safe_load(f) or {}
        if data.get("active", False):
            products.append({"path": base, **data})
print(json.dumps(products, indent=2))
