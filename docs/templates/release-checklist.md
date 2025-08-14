# Release checklist — Metricraft

> Use this for each part/assembly before tagging + publishing.

## 1) Model & geometry
- [ ] All objects named; plates named clearly.
- [ ] Seam keep-outs modeled or annotated where needed.
- [ ] Overhangs checked; supports required only where justified.
- [ ] Test coupons included (XY ladder, hole/shaft, snap-fit, etc.).

## 2) Slicing sanity (Bambu Studio 2.2.0.85)
- [ ] Layer height set per goal (0.20 mm default).
- [ ] Walls = 3 (unless justified); infill ≥ 15% grid (unless justified).
- [ ] Seam policy set; seam hidden from show faces.
- [ ] Support style chosen and tuned (tree vs. normal) if needed.
- [ ] Cooling/speed overrides documented when used.
- [ ] Preview passes: thin walls, bridges, overhangs, and timelapse seams.
- [ ] Estimated time/grams recorded in README.

## 3) Filenames & versions
- [ ] Filenames use all-lowercase-hyphens.
- [ ] `vX.Y.Z` bumped per semver; rationale added to CHANGELOG.
- [ ] Export STL and a Bambu 3MF with named objects/plates + README text object.

## 4) Docs
- [ ] `README.md` filled using template (what/why, coupons, slicing, tolerances).
- [ ] `CHANGELOG.md` updated (Keep a Changelog).
- [ ] Photos/screens: neutral background, 3/4 view, seam hidden; coupon close-up.

## 5) Test prints (acceptance)
- [ ] PETG test print passes coupon acceptance criteria.
- [ ] If publishing a PLA profile too, PLA coupon notes documented (heat limits).

## 6) License & publishing
- [ ] License clarified (repo LICENSE or project-specific).
- [ ] MakerWorld listing: title, tags, description (what/why first), license.
- [ ] Upload STL + 3MF; attach hero images; link back to Git tag.
- [ ] First comment drafted (what changed, feedback request).

## 7) Tag & ship
- [ ] Git tag `vX.Y.Z` created and pushed.
- [ ] MakerWorld link added to repo (README or release notes).
