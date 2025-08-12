
#!/usr/bin/env python3
# Move stl/ and 3mf/ content into a release folder (dist/release-vX.Y.Z) and update status.yaml version.
import os, shutil, sys, yaml

if len(sys.argv) < 3:
    print("Usage: archive_release.py <product_path> <version>")
    sys.exit(1)

p = sys.argv[1].rstrip("/")
ver = sys.argv[2]
dist = os.path.join(p, "dist", f"release-{ver}")
os.makedirs(dist, exist_ok=True)

for sub in ["stl","3mf"]:
    src = os.path.join(p, sub)
    if os.path.isdir(src):
        for f in os.listdir(src):
            if f.lower().endswith((".stl",".3mf",".txt")):
                shutil.copy2(os.path.join(src,f), os.path.join(dist,f))

status = os.path.join(p, "status.yaml")
if os.path.exists(status):
    with open(status, "r") as fh:
        d = yaml.safe_load(fh) or {}
    d["version"] = ver
    with open(status, "w") as fh:
        yaml.safe_dump(d, fh)
print(f"Archived to {dist}")
