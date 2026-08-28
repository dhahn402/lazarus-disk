# Batch record — Lazarus Key, August 2026

The protocol asks for one of these per batch. If a customer ever comes back,
this sheet is the difference between "here is exactly what we tested" and
taking their word against yours.

**Batch:** first production run · **Units:** 5 · **Opened:** 27 Aug 2026

---

## Source

| Field | Value |
|---|---|
| Supplier | Amazon (William buys a batch at a time — no distributor, no lot number) |
| Order no. | _______________________ |
| Product | KinHom keepsake USB necklace — stainless ball chain, white gift box |
| Marked capacity | _______ GB (read off the drive or listing) |

> No lot number means a bad batch cannot be traced or returned as a lot.
> Keep the Amazon order number here — it is the only thread back to the seller.

---

## Image written to every unit — ✅ verified 27 Aug 2026

| Field | Value |
|---|---|
| Release | Pop!_OS **24.04 LTS** |
| Build | **20** |
| Channel | **Intel/AMD** ✅ *(sellable — NOT the NVIDIA image)* |
| File | `~/Desktop/pop disk/pop-os_24.04_amd64_intel_20.iso` |
| Size | 2,955,067,392 bytes |
| SHA-256 | `a0ef3842ab710db4f4407cf3499560b59dddbbcd59bee17beab7b0e99dc22b4c` |
| Verified against | System76 `api.pop-os.org/builds/24.04/intel` — **exact match** |

A `.sha256` sidecar sits next to the ISO, so the write script re-verifies this
offline every time, with no internet needed.

---

## STEP 1 — Capacity test (`f3`) · the counterfeit check

`f3` is installed (v10.0). For each drive: `diskutil list`, read it **twice**,
then erase and fill it.

    diskutil eraseDisk ExFAT KEYTEST /dev/diskN
    f3write /Volumes/KEYTEST
    f3read  /Volumes/KEYTEST

**Pass = f3read returns what f3write wrote, with ZERO corrupted or changed sectors.**

| # | Colour | Marked | f3write GB | f3read GB | Corrupted | Verdict | Date |
|---|---|---|---|---|---|---|---|
| 1 |  |  |  |  |  | ☐ pass ☐ **FAKE** |  |
| 2 |  |  |  |  |  | ☐ pass ☐ **FAKE** |  |
| 3 |  |  |  |  |  | ☐ pass ☐ **FAKE** |  |
| 4 |  |  |  |  |  | ☐ pass ☐ **FAKE** |  |
| 5 |  |  |  |  |  | ☐ pass ☐ **FAKE** |  |

🔴 **If ANY of the five fails, none of them ship.** One fake means the seller's
stock is suspect, and the next batch from that seller is too.

---

## STEP 2 — Write · STEP 3 — Boot test

Write fresh from the ISO above. Never clone a stick that has been booted — it
carries the Wi-Fi passwords, logs and shell history of whoever used it.

Boot each finished drive on a **real** machine, not a VM.

| # | Written | Read back OK | Booted a real PC | Insert in box | Ready |
|---|---|---|---|---|---|
| 1 | ☐ | ☐ | ☐ | ☐ | ☐ |
| 2 | ☐ | ☐ | ☐ | ☐ | ☐ |
| 3 | ☐ | ☐ | ☐ | ☐ | ☐ |
| 4 | ☐ | ☐ | ☐ | ☐ | ☐ |
| 5 | ☐ | ☐ | ☐ | ☐ | ☐ |

---

## STEP 4 — The licence obligation, per unit

- [x] Image is **Intel/AMD**, not NVIDIA — confirmed above
- [ ] **Print `GPL-insert-BATCH1-prefilled-PRINT-5.pdf` × 5** (in `~/Desktop/pop disk/`).
      Release, build, channel and the full SHA-256 are already printed on it, so
      they are not hand-copied five times and cannot be miscopied. Only the date
      and initials are left blank. `GPL-drive-insert-PRINT-ME.pdf` is the blank
      master, for any batch built on a different image.
- [ ] ⚠️ **Mailing address written on each insert.** The GPL written offer is
      only valid if someone can actually reach you at it. The printed slip has
      a blank line for it. **A drive must not ship with that line empty.**
- [ ] Build stamp filled in on each insert: release, build, channel, SHA-256, date

---

**Hahn Technologies Corp** · New Bern, NC
Text: (252) 626-6236 · hahntechnologiescorp@gmail.com
