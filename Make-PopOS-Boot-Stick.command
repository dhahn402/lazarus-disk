#!/bin/bash
# ============================================================
#  MAKE THE POP!_OS BOOT STICK
#
#  Writes a Pop!_OS installer onto a USB stick so it can boot
#  PCs - rescue files off a dead laptop, test hardware, wipe a
#  drive before resale, or install a fresh system.
#
#  NOTE: this will NOT boot David's MacBook. Apple Silicon
#  Macs cannot boot from USB at all - that's the chip, not a
#  setting. For the Mac, hold the power button for Recovery.
#
#  It asks for your Mac password because writing a raw disk
#  image needs admin rights.
#
#  Set DRYRUN=1 to walk through every prompt without writing:
#      DRYRUN=1 ./Make-PopOS-Boot-Stick.command
# ============================================================
clear
echo "=============================================="
echo "   MAKE THE POP!_OS BOOT STICK"
echo "=============================================="
echo ""

pause_exit() { echo ""; read -n 1 -s -r -p "Press any key to close."; echo ""; exit "${1:-0}"; }

# ---------- find the Pop!_OS file ----------
# An explicit path wins. Otherwise search the usual places and
# take the newest match, so this keeps working after a re-download
# instead of pointing at one stale hardcoded path.
# Search locations in PRIORITY order, not by timestamp - the first
# folder holding an .iso wins. "Newest file anywhere" is the wrong
# rule: a leftover copy in a temp folder can be newer than the one
# you deliberately downloaded, and you'd silently get the wrong
# edition (Intel instead of NVIDIA, or the wrong release).
ISO="$1"
if [ -z "$ISO" ]; then
  for spot in \
      "$HOME/Desktop/pop disk" \
      "$HOME/Desktop" \
      "$HOME/Downloads"; do
    found=$(ls -t "$spot"/*.iso 2>/dev/null)
    [ -z "$found" ] && continue
    count=$(printf '%s\n' "$found" | wc -l | tr -d ' ')
    if [ "$count" -eq 1 ]; then
      ISO="$found"
    else
      # More than one image in the same folder. Taking the newest one here
      # is the silent wrong-edition pick this script exists to prevent - an
      # Intel and an NVIDIA image sit side by side and look interchangeable
      # right up until the licence matters. Ask instead of guessing.
      echo "  More than one .iso is in $spot:"
      echo ""
      i=0
      while IFS= read -r f; do
        i=$((i+1))
        echo "     $i) $(basename "$f")"
      done <<< "$found"
      echo ""
      read -r -p "  Which one? [1-$i] " pick
      case "$pick" in
        ''|*[!0-9]*) echo "  Not a number. Nothing written."; pause_exit 1 ;;
      esac
      if [ "$pick" -lt 1 ] || [ "$pick" -gt "$i" ]; then
        echo "  That isn't one of the choices. Nothing written."
        pause_exit 1
      fi
      ISO=$(printf '%s\n' "$found" | sed -n "${pick}p")
      echo ""
    fi
    break
  done
fi

if [ -z "$ISO" ] || [ ! -f "$ISO" ]; then
  echo "  Can't find a Pop!_OS .iso file."
  echo ""
  echo "  I looked in:"
  echo "     ~/Desktop/pop disk/"
  echo "     ~/Desktop/"
  echo "     ~/Downloads/"
  echo ""
  echo "  Download one from https://pop.system76.com then run this again,"
  echo "  or drag the .iso onto this script to point straight at it."
  pause_exit 1
fi

echo "  Pop!_OS file : $(basename "$ISO")"
echo "  Location     : $(dirname "$ISO")"
echo "  Size         : $(du -h "$ISO" | cut -f1)"

# ---------- which edition is this, and may it be sold? ----------
# The NVIDIA image bundles NVIDIA's proprietary driver. That licence grants
# the right to distribute alongside a Linux kernel while separately
# forbidding sale, so a stick made from it cannot lawfully be sold - see
# step 4 of PRODUCTION-TEST-PROTOCOL.md. The Intel/AMD image carries no such
# clause, and Pop!_OS installs the NVIDIA driver after setup anyway, so
# nothing is lost by selling the Intel one.
chan_now=$(basename "$ISO" | sed -n 's/^pop-os_[0-9][0-9.]*_amd64_\([a-z]*\)_.*/\1/p')
if [ "$chan_now" = "nvidia" ]; then
  echo "  Edition      : NVIDIA  --  NOT FOR SALE"
  echo ""
  echo "  This one is fine for your own machine, or a stick you give away"
  echo "  free. It may not be SOLD - NVIDIA's driver licence forbids it."
  echo "  To make a drive you intend to sell, use the Intel/AMD image."
  echo ""
  read -r -p "  Type NOTFORSALE to continue with this one: " ack
  if [ "$ack" != "NOTFORSALE" ]; then
    echo ""
    echo "  Stopped. Nothing written."
    pause_exit 1
  fi
elif [ -n "$chan_now" ]; then
  echo "  Edition      : $chan_now  --  may be sold, with the printed insert in the box"
fi
echo ""

# ---------- prove the download is complete BEFORE writing ----------
# A half-finished download still looks like a normal file and will
# write "successfully" to a stick that then refuses to boot. Every
# ISO records its own true length in its ISO9660 header, so compare
# that against the real file size. This works with no internet.
echo "  Checking the file is complete..."
blocks=$(dd if="$ISO" bs=1 skip=32848 count=4 2>/dev/null | od -An -tu4 | tr -d ' ')
bsz=$(dd if="$ISO" bs=1 skip=32896 count=2 2>/dev/null | od -An -tu2 | tr -d ' ')
actual=$(stat -f%z "$ISO")

if [ -z "$blocks" ] || [ -z "$bsz" ] || [ "$bsz" -eq 0 ] 2>/dev/null; then
  echo "  [!] This file doesn't look like a bootable ISO at all."
  echo "      Expected an ISO9660 disc image. Re-download it."
  pause_exit 1
fi

expected=$((blocks * bsz))
if [ "$actual" -ne "$expected" ]; then
  short=$((expected - actual))
  echo ""
  echo "  [X] THE DOWNLOAD IS INCOMPLETE - not writing."
  echo ""
  echo "      should be : $expected bytes"
  echo "      actually  : $actual bytes"
  echo "      short by  : $short bytes"
  echo ""
  echo "  Writing this would make a stick that looks fine but won't boot."
  echo "  Download it again, then re-run this."
  pause_exit 1
fi
echo "      Complete - $actual bytes, matches its own header."

# ---------- verify the publisher's checksum when we can ----------
# Confirms the file is genuine and unmodified, not merely complete.
# Skipped without complaint if offline or the filename isn't standard.
WANT=""
if [ -f "$ISO.sha256" ]; then
  WANT=$(awk '{print $1}' "$ISO.sha256" | head -1)
else
  base=$(basename "$ISO")
  ver=$(echo "$base"  | sed -n 's/^pop-os_\([0-9][0-9.]*\)_amd64_\([a-z]*\)_.*/\1/p')
  chan=$(echo "$base" | sed -n 's/^pop-os_\([0-9][0-9.]*\)_amd64_\([a-z]*\)_.*/\2/p')
  if [ -n "$ver" ] && [ -n "$chan" ]; then
    WANT=$(curl -s --max-time 8 "https://api.pop-os.org/builds/$ver/$chan" \
           | sed -n 's/.*"sha_sum":"\([a-f0-9]*\)".*/\1/p')
  fi
fi

if [ -n "$WANT" ]; then
  echo "  Verifying the publisher's checksum (about 20 seconds)..."
  GOT=$(shasum -a 256 "$ISO" | awk '{print $1}')
  if [ "$GOT" != "$WANT" ]; then
    echo ""
    echo "  [X] CHECKSUM DOES NOT MATCH - not writing."
    echo "      expected: $WANT"
    echo "      got     : $GOT"
    echo ""
    echo "  The file is damaged or was tampered with. Download it again."
    pause_exit 1
  fi
  echo "      Genuine - checksum matches System76."
else
  echo "  (Skipping checksum - offline or no published hash for this file.)"
fi
echo ""

# ---------- list candidate sticks; NEVER auto-pick ----------
# Only external, physical, 20-64GB. That rules out the internal
# disk and the 2TB backup drive by construction. David has more
# than one small stick, so he chooses explicitly - guessing here
# could wipe the wrong one.
echo "  Removable drives I could write to:"
echo ""
CANDS=()
for d in $(diskutil list | grep -oE '^/dev/disk[0-9]+' | sort -u); do
  info=$(diskutil info "$d" 2>/dev/null)
  echo "$info" | grep -q "Device Location:.*External" || continue
  echo "$info" | grep -q "Virtual:.*No"               || continue
  bytes=$(echo "$info" | grep "Disk Size" | grep -oE '\(([0-9]+) Bytes' | grep -oE '[0-9]+' | head -1)
  [ -z "$bytes" ] && continue
  gb=$((bytes/1000000000))
  [ "$gb" -ge 20 ] && [ "$gb" -le 64 ] || continue
  CANDS+=("$d")
  nm=$(echo "$info" | grep "Device / Media Name" | cut -d: -f2- | xargs)
  # warn loudly if this stick already holds something. Read the TYPE column
  # from diskutil's partition rows; "(free space)" rows are ignored.
  content=$(diskutil list "$d" | sed -n 's/^ *[0-9]*: *\([A-Za-z0-9_][A-Za-z0-9_ ]*[A-Za-z0-9_]\) .*/\1/p' \
            | grep -viE 'FDisk_partition_scheme|GUID_partition_scheme|free space' | sort -u | tr '\n' ' ')
  if echo "$content" | grep -qiE 'linux|apfs|hfs|ntfs|ext[234]|0xEF'; then
    # a real filesystem or a Linux/EFI layout - almost certainly someone's work
    used="!! ALREADY HAS DATA -> $content"
  else
    # plain FAT/exFAT: look inside before crying wolf, since a factory-fresh
    # card ships formatted-but-empty and that is exactly what we want to use.
    # If it isn't mounted we genuinely cannot see inside - say so rather than
    # implying it's empty, because "blank" is the one word that invites a wipe.
    mp=$(diskutil info "$d"s1 2>/dev/null | grep "Mount Point" | cut -d: -f2- | xargs)
    if [ -n "$mp" ] && [ -d "$mp" ]; then
      n=$(ls -A "$mp" 2>/dev/null | grep -vcE '^\.(Spotlight-V100|fseventsd|Trashes|TemporaryItems|DS_Store)$')
      if [ "${n:-0}" -gt 0 ]; then used="!! HAS $n item(s) -> $content"; else used="empty - safe to use"; fi
    else
      used="?? not mounted - contents unknown, check before wiping"
    fi
  fi
  printf "    [%d]  %-12s %3sGB  %-22s %s\n" "${#CANDS[@]}" "$d" "$gb" "$nm" "$used"
done
echo ""

if [ "${#CANDS[@]}" -eq 0 ]; then
  echo "  No removable 20-64GB drive found. Plug the stick in and run this again."
  echo "  (Your 2TB backup drive is deliberately never eligible.)"
  pause_exit 1
fi

printf "  Which one? Type its number (or press Return to cancel): "
read -r pick
[ -z "$pick" ] && { echo "  Cancelled - nothing changed."; pause_exit 0; }
case "$pick" in ''|*[!0-9]*) echo "  Not a number - cancelled."; pause_exit 0;; esac
{ [ "$pick" -ge 1 ] && [ "$pick" -le "${#CANDS[@]}" ]; } 2>/dev/null \
  || { echo "  Out of range - cancelled."; pause_exit 0; }
CARD="${CANDS[$((pick-1))]}"

echo ""
echo "  ############################################"
echo "  #  THIS ERASES EVERYTHING ON $CARD"
echo "  ############################################"
echo ""
diskutil list "$CARD" | sed 's/^/     /'
echo ""
printf "  Type ERASE to go ahead: "
read -r ans
[ "$ans" = "ERASE" ] || { echo ""; echo "  Cancelled - nothing was changed."; pause_exit 0; }

echo ""
echo "  Unmounting the stick..."
diskutil unmountDisk "$CARD" || { echo "  Couldn't unmount. Close any Finder windows on it and retry."; pause_exit 1; }

# /dev/rdiskN (raw) is far faster than /dev/diskN
RAW="${CARD/disk/rdisk}"

if [ "$DRYRUN" = "1" ]; then
  echo ""
  echo "  [DRY RUN] Would now run:"
  echo "      sudo dd if=\"$ISO\" of=\"$RAW\" bs=4m"
  echo "  [DRY RUN] Nothing was written. Exiting."
  pause_exit 0
fi

echo "  Writing Pop!_OS - takes several minutes, the stick's light will blink."
echo "  Enter your Mac password when asked."
echo ""
echo "  Heads up: macOS may pop up \"The disk you inserted was not readable.\""
echo "  Click IGNORE. Never click Initialize - that would wipe what we just wrote."
echo "  (macOS simply can't read Linux disks. The stick is fine.)"
echo ""

if sudo dd if="$ISO" of="$RAW" bs=4m status=progress; then
  sync
  echo ""
  echo "  Written. Checking the stick actually matches the file..."
  # Read back exactly as many bytes as we wrote and compare fingerprints.
  # Catches a dying stick that accepted the write but stored it wrong -
  # far better to learn that here than on someone's dead laptop.
  BACK=$(sudo dd if="$RAW" bs=1m count=$((actual/1048576+1)) 2>/dev/null \
         | head -c "$actual" | shasum -a 256 | awk '{print $1}')
  SRC=$(shasum -a 256 "$ISO" | awk '{print $1}')
  diskutil eject "$CARD" >/dev/null 2>&1

  if [ "$BACK" = "$SRC" ]; then
    echo "      Verified - the stick is a perfect copy."
    echo ""
    echo "  =========================================="
    echo "     POP!_OS BOOT STICK READY"
    echo "  =========================================="
    echo "     Use it on a PC: plug in, then tap the"
    echo "     boot menu key as it powers on -"
    echo "     usually F12, or F9 / Esc / F2."
    echo ""
    echo "     Pick 'Try or Install Pop!_OS'."
    echo "     It runs off the stick and changes"
    echo "     nothing on that computer unless you"
    echo "     choose to install."
    echo ""
    echo "     Reminder: this will NOT boot your Mac."
    echo "     For the Mac, hold the power button."
  else
    echo ""
    echo "  [X] The stick does NOT match the file."
    echo "      This stick is probably failing. Try a different one."
    echo "      Do not rely on it to boot anything."
  fi
else
  echo ""
  echo "  [X] Write failed. The stick may be faulty or write-protected."
fi
pause_exit 0
