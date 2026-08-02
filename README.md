# lazarus-disk

Tools for bringing old computers back from the dead.

A slow laptop is usually not broken — it is running an operating system that
has outgrown it, on a mechanical drive, under years of accumulated startup
clutter. Wiping it and installing Linux makes most of those machines pleasant
to use again. This repository holds the two things needed to do that as a
service: a safe USB-writing script, and the website that sells the work.

**Live site: https://newberncomputerrepair.com**

Built for Hahn Technologies Corp in New Bern, NC.

---

## `Make-PopOS-Boot-Stick.command`

A macOS script that writes a Pop!\_OS installer to a USB stick. Double-click it
in Finder, or run it from a terminal.

It is written to be handed to someone who is not a systems administrator, so
every destructive step is gated and every assumption is checked.

**What it does before writing anything**

| Guard | Why it exists |
| --- | --- |
| Finds the ISO by location priority, not timestamp | A leftover copy in a temp folder can be newer than the one you meant to use. Sorting by time silently picks the wrong edition. |
| Verifies the ISO against its own ISO9660 header | A half-finished download is still a normal-looking file. It writes "successfully" and produces a stick that will not boot. This catches it offline, with no network needed. |
| Verifies the publisher's SHA-256 | Confirms the image is genuine, not merely complete. Pulled from `api.pop-os.org`, or from a `.sha256` file next to the ISO. Skipped quietly when offline. |
| Lists only external physical disks of 20–64 GB | Excludes the internal drive and any large backup drive by construction, rather than by hoping the right one is picked. |
| Never auto-selects a target | You choose by number, then type `ERASE` in full. |
| Reports what is already on each stick | Distinguishes a factory-blank card from one holding someone's work. An unmounted disk is reported as unknown rather than as blank. |
| Reads the stick back after writing | A failing stick can accept a write and store it wrong. Better to find out at the desk than on someone's dead laptop. |

**Usage**

```bash
# Auto-discover the ISO (~/Desktop/pop disk, ~/Desktop, then ~/Downloads)
./Make-PopOS-Boot-Stick.command

# Or point at one explicitly
./Make-PopOS-Boot-Stick.command ~/Downloads/pop-os_22.04_amd64_nvidia_58.iso

# Walk every prompt without writing a single byte
DRYRUN=1 ./Make-PopOS-Boot-Stick.command
```

**Requirements** — macOS, an admin password (raw disk writes need root), and a
Pop!\_OS ISO from [pop.system76.com](https://pop.system76.com).

**A note on Apple Silicon** — a stick made this way will not boot an M-series
Mac. Those machines cannot boot from USB at all; that is the chip, not a
setting. The stick is for PCs. For a Mac, hold the power button for Recovery.

---

## `docs/index.html`

A single-file landing page for the refresh service. No build step, no
dependencies, no external requests — open it in a browser or drop it on any
static host.

The centerpiece is a hardware checker that answers, honestly, whether a given
machine can run AI locally. Under 8 GB of memory it says no and explains why,
because a page that tells people the truth about their hardware is worth more
than one that promises everything.

It also carries the recurring-plan pricing — monthly maintenance and support
tiers — alongside the one-time refresh rates, with an explicit section on what
those plans do not cover.

Renders in light and dark themes.

---

## `docs/work-order.html`

A printable intake and completion form. Open it in a browser and print on
Letter, double-sided: the front is the authorization signed at drop-off, the
back is the completion record signed at pickup. One sheet per job, so the
signature can never get separated from the machine details.

The front captures the owner's name separately from whoever dropped the machine
off, records its condition on arrival, asks whether the files exist anywhere
else, and carries an initialed acknowledgment for the case where the drive is
already failing. The back has a work log and the handback signature.

Not legal advice, and nobody who wrote it is a lawyer. The limitation of
liability is the clause worth having a North Carolina attorney read.

## `docs/drive-insert.html`

The printed notice that must accompany every drive sold or given away. Carries
the GPL written offer for source code, the build stamp (release, build, channel,
SHA-256, date), the trademark disclaimer, and a plain statement that the software
is free and what the customer is actually paying for.

Selling copies of GPL software is expressly permitted — GPLv2 §1 and GPLv3 §4
say so directly. What is *not* permitted is conveying binaries on physical media
for money without a source offer. GPLv2 §3(c) and GPLv3 §6(c) are noncommercial-
only, and the network-server option in GPLv3 §6(d) applies to downloads rather
than to a stick handed across a counter. So a written offer in Hahn Technologies
Corp's own name, valid three years and valid to *anyone* holding the notice, is
the applicable path. Pointing at System76's or Ubuntu's servers is not sufficient
on its own for the GPLv2 code, which includes the Linux kernel.

**Sell the Intel/AMD image.** The NVIDIA image bundles NVIDIA's proprietary
driver, whose license grants the right to *distribute* alongside a Linux kernel
(§1.1(d)) while separately prohibiting *sale* except as expressly granted (§2.7).
That tension is unresolved publicly. The Intel/AMD image has no such clause, and
Pop!_OS installs the NVIDIA driver after setup anyway.

## License

MIT — see [LICENSE](LICENSE).

Pop!\_OS is a trademark of System76, Inc. This project is independent and is
not affiliated with or endorsed by System76.

---

## `qr/`

QR codes pointing at the live site, all verified by decoding them back to
`https://newberncomputerrepair.com/`.

| File | Use |
| --- | --- |
| `lazarus-qr-print.png` | Print master. 1800×1800, black on white — highest scan reliability. |
| `lazarus-qr.svg` | Vector. Scales to any size without softening; give this to a print shop. |
| `lazarus-qr-brand.png` | Site colors (`#14181A` on `#EDEFEE`) for on-brand material. |
| `lazarus-qr-transparent.png` | Transparent background, for placing on a dark layout. |

Encoded at error-correction level H, so roughly 30% of the code can be
obscured or worn and it still resolves.

**Minimum print size: 1 inch / 25 mm square.** Testing showed reliable
decoding down to 120 px, so 1 inch at 300 DPI leaves
real margin for bad lighting and cheap phone cameras. Always leave the white
border — that quiet zone is part of the code, not padding.
