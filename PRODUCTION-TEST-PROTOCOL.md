# Lazarus Key — production test protocol
### Before a single drive is sold · written 27 Aug 2026

---

## 🔴 THE TRAP: cloning proves the image works. It does NOT prove the drive is honest.

This is the one thing to understand before running a batch.

A counterfeit flash drive is programmed to **report** a big size — 32GB, 64GB —
while the real memory inside might be 4GB. Write more than the real amount and it
either wraps around and silently destroys earlier data, or returns garbage.

**Pop!_OS is only a few GB.** So a fake 32GB drive will take the clone, boot
perfectly, and pass every check you would naturally think to run. The fraud stays
invisible **until a customer saves their files to it** — which is the entire point
of a rescue key — and then their data is gone.

**So there are two separate tests, and cloning is only the first:**

| Test | Proves | Catches |
|---|---|---|
| Boot the clone | the image is good | a bad write |
| **Capacity test** | **the drive is real** | **a counterfeit lot** |

Passing test 1 tells you nothing about test 2. Cheap bulk lots from marketplaces
are exactly where fake-capacity drives live, so run both.

---

## STEP 1 — Capacity test. Do this FIRST, before writing anything.

    brew install f3

Insert a drive, find it, and note the identifier carefully:

    diskutil list

⚠️ **Read that output twice.** The next commands write to whatever you name.
Naming your own disk instead of the USB is unrecoverable.

Format it, then fill it completely and read it back:

    diskutil eraseDisk ExFAT KEYTEST /dev/diskN
    f3write /Volumes/KEYTEST
    f3read  /Volumes/KEYTEST

**What you want to see:** `f3read` reports the same amount it wrote, with
**zero** corrupted or overwritten sectors.

**What a fake looks like:** f3write claims to write the full size, then f3read
comes back with a large "corrupted" or "changed" count. That drive is a fake and
so is the rest of the lot.

⏱️ It is slow — filling a 32GB drive takes a while. **Run it on a sample of 3-5
drives from the lot first.** If any one fails, the whole lot is suspect and
nothing ships.

---

## STEP 2 — Write the image. Prefer writing fresh over cloning a used stick.

⚠️ **The gotcha with cloning "the one he made us":** if that master has ever been
**booted and used**, a clone carries everything it picked up — saved Wi-Fi
networks and passwords, logs, shell history, any files left behind. You would be
shipping a copy of someone's session to a stranger.

**Two safe options:**

- ✅ **Best — write the original Pop!_OS ISO to each drive.** Every stick is
  byte-identical and carries no history. `Make-PopOS-Boot-Stick.command` in this
  repo already does it.
- ✅ **Acceptable — clone a master that has NEVER been booted**, only written.

**Never clone a stick that has been used.**

---

## STEP 3 — Verify each drive actually boots

Write it, then **boot a real machine from it.** Not a virtual machine — a real
one. Some drives write cleanly and still will not boot.

⭐ You said a laptop is coming. That is exactly the right test rig: dedicate it to
booting each finished key before it goes in a box.

---

## STEP 4 — ⚖️ The licence rule. This one is not optional.

Pop!_OS is GPL software. **If you SELL a drive with it on there:**

1. The **written offer insert** must ship in the box —
   `docs/drive-insert.html` in this repo. That is what makes selling it lawful.
2. It must be the **Intel/AMD image**, NOT the NVIDIA one. **The NVIDIA image
   contains a driver whose licence forbids sale.**

Getting this wrong turns a $15 product into a licensing problem. Getting it right
costs one printed slip.

---

## The record to keep per batch

| Field | Why |
|---|---|
| Lot / supplier / order no. | so a bad lot can be traced and returned |
| How many f3-tested, and the results | evidence the batch was checked |
| Image file + its checksum | proves every key has the same known-good build |
| How many boot-tested | catches a bad writer or a bad batch |
| Insert included? | the GPL obligation, per unit |

If a customer ever comes back, this record is the difference between "here is
exactly what we tested" and taking their word against yours.

---

**Hahn Technologies Corp** · New Bern, NC
Text: (252) 626-6236 · hahntechnologiescorp@gmail.com
