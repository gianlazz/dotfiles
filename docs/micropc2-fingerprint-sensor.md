# MicroPC 2 Fingerprint Sensor Recovery (MAFP8800)

Hardware: Microarray MAFP8800 (SPI, ACPI `MAFP8800:`), GPD MicroPC 2.
Driver: custom `libfprint-mafp8800` package stored in `~/Development/dotfiles/drivers/libfprint-mafp8800/`.

## Symptom

After an `omarchy update`, `omarchy-setup-fingerprint` fails with:

```
Impossible to enroll: GDBus.Error:org.freedesktop.DBus.Error.NameHasNoOwner:
Could not activate remote peer 'net.reactivated.Fprint': startup job failed
```

## Root Cause

An update removes `libgusb` (a runtime dependency of `fprintd`), causing `fprintd` to crash on start with `status=127`.

## Fix

```bash
# Restore missing runtime and custom driver
sudo pacman -S --noconfirm libgusb
cd ~/Development/dotfiles/drivers/libfprint-mafp8800
makepkg -si --noconfirm

# Reset service backoff then re-enroll
sudo systemctl reset-failed fprintd
omarchy-setup-fingerprint
```

## Diagnostics

```bash
# Check what's missing
ldd /usr/lib/fprintd | grep "not found"

# Check service state
systemctl status fprintd -l --no-pager

# Check installed packages
pacman -Q fprintd libfprint libfprint-mafp8800 2>&1 || true
```
