# luci-app-twofa

Two-Factor Authentication (TOTP) for OpenWrt LuCI web interface.

- Supports Google Authenticator and Microsoft Authenticator.
- Configurable via LuCI System menu.
- Compatible with OpenWrt 22.03+.
- Automatically built for multiple architectures via GitHub Actions.

## Features
- Enable/disable 2FA from LuCI.
- Auto-generate TOTP secret and QR code.
- Secure HMAC-SHA1 based TOTP verification.
- Only affects root login (LuCI default user).

## Installation
After building, install the `.ipk` package:
```sh
opkg install luci-app-twofa_*.ipk
