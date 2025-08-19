#!/usr/bin/env python3
import sys, zipfile, re, json
import xml.etree.ElementTree as ET
from pathlib import Path

ALLOWED_STYLES = {"heptachord", "dragoncrest"}
# Product-specific expectations (expand as you add products)
PRODUCT_RULES = {
    "filament-spool": {
        "plates": {"plate-main", "plate-cams"},
        "objects": {"flange", "core", "cover", "flange2core", "cover2flange"},
    }
}

def load_xml(zf, path):
    with zf.open(path) as fh:
        return ET.fromstring(fh.read())

def main():
    files = sys.argv[1:]
    if not files:
        print("No .3mf files provided; nothing to check.")
        return 0

    failed = False
    for f in files:
        p = Path(f)
        # Expect .../collections/.../<product>/3mf/<style>/plate-*.3mf
        m = re.search(r"collections/.+?/(?P<product>[^/]+)/3mf/(?P<style>[^/]+)/(?P<plate>plate-(?:main|cams))\.3mf$", str(p))
        if not m:
            print(f"[FAIL] Path does not match convention: {p}")
            failed = True
            continue
        product, style, plate = m.group("product"), m.group("style"), m.group("plate")
        if style not in ALLOWED_STYLES:
            print(f"[FAIL] Unknown style '{style}' in path {p}")
            failed = True
            continue
        rules = PRODUCT_RULES.get(product)
        if not rules:
            print(f"[WARN] No product rules for '{product}'. Skipping object-name assertions.")
        else:
            if plate not in rules["plates"]:
                print(f"[FAIL] Plate name '{plate}' not in allowed set {rules['plates']}")
                failed = True
                continue

        try:
            with zipfile.ZipFile(p, "r") as zf:
                names = set(zf.namelist())
                if "3D/3dmodel.model" not in names:
                    print(f"[FAIL] {p}: missing 3D/3dmodel.model")
                    failed = True
                    continue
                root = load_xml(zf, "3D/3dmodel.model")
                unit = root.attrib.get("unit", "").lower()
                if unit not in ("millimeter", "millimetre", "millimeters"):
                    print(f"[FAIL] {p}: model unit is '{unit}', expected millimeter")
                    failed = True

                # Try to read object names; namespace is usually required
                # We'll be tolerant: search regardless of ns, looking for 'object' elements with 'name' attr
                objs = [el for el in root.iter() if el.tag.endswith("object")]
                obj_names = {el.attrib.get("name","").strip().lower() for el in objs if "name" in el.attrib and el.attrib.get("name","").strip()}
                if rules:
                    expected = {n.lower() for n in rules["objects"]}
                    if obj_names:
                        known = obj_names & expected
                        unknown = obj_names - expected
                        if not known:
                            print(f"[FAIL] {p}: none of the objects match expected names {sorted(expected)}; got {sorted(obj_names)}")
                            failed = True
                        elif unknown:
                            print(f"[WARN] {p}: unknown object names present: {sorted(unknown)}")
                    else:
                        print(f"[WARN] {p}: no object names found in model XML; cannot assert objects")

        except zipfile.BadZipFile:
            print(f"[FAIL] {p}: invalid ZIP/3MF")
            failed = True
        except Exception as e:
            print(f"[FAIL] {p}: exception {e}")
            failed = True

    return 1 if failed else 0

if __name__ == "__main__":
    sys.exit(main())
