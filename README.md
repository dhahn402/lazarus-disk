# lazarus-disk

Tools for bringing old computers back from the dead.

A slow laptop is usually not broken — it is running an operating system that
has outgrown it, on a mechanical drive, under years of accumulated startup
clutter. Wiping it and installing Linux makes most of those machines pleasant
to use again. This repository holds the two things needed to do that as a
service: a safe USB-writing script, and the website that sells the work.

**Live site: https://dhahn402.github.io/lazarus-disk/**

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

Renders in light and dark themes.

---

## License

MIT — see [LICENSE](LICENSE).

Pop!\_OS is a trademark of System76, Inc. This project is independent and is
not affiliated with or endorsed by System76.
