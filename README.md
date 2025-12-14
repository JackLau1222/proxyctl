# proxyctl

`proxyctl` is a tiny, cross-platform helper for managing proxy environment
variables in terminal sessions.

It is designed for modern proxy tools (Clash, v2ray, ss-local, mitmproxy)
and supports **mixed proxy ports** out of the box.

---

## Features

- Cross-platform (Linux, macOS, Windows)
- Works in interactive shells (bash, zsh, sh, PowerShell)
- Clean separation between **configuration** and **enable/disable**
- Mixed-port shorthand support (`host:port`)
- Sets both lowercase and uppercase proxy variables
- No external dependencies

---

## Design

`proxyctl` follows a simple rule:

> **Configuration and state are separate.**

| Action | Command |
|------|--------|
| Configure proxy | `proxy_set` / `Set-ProxyConfig` |
| Enable proxy | `proxy_on` / `Enable-Proxy` |
| Disable proxy | `proxy_off` / `Disable-Proxy` |
| Show status | `proxy_show` / `Show-Proxy` |

This avoids accidental changes and makes scripting predictable.

---

## Mixed-port proxies (important)

Many modern proxies expose a **single mixed port** that supports
both HTTP CONNECT and SOCKS.

`proxyctl` treats a bare `host:port` input as a mixed proxy:

```sh
proxy_set 127.0.0.1:7890
proxy_on
```
This results in:
```
http_proxy  = http://127.0.0.1:7890
https_proxy = http://127.0.0.1:7890
all_proxy   = socks5://127.0.0.1:7890
```
No extra configuration required.

---

## Installation
### Linux / macOS (bash, zsh, sh)
```sh
mkdir -p ~/.local/share
curl -fsSL https://raw.githubusercontent.com/JackLau1222/proxyctl/master/proxyctl.sh \
  -o ~/.local/share/proxyctl.sh

echo '. ~/.local/share/proxyctl.sh' >> ~/.bashrc
# or ~/.zshrc
source ~/.bashrc
```
⚠️ The script must be sourced, not executed.
```powershell
Windows (PowerShell)
Invoke-WebRequest https://raw.githubusercontent.com/JackLau1222/proxyctl/master/proxyctl.ps1 `
  -OutFile $env:LOCALAPPDATA\proxyctl.ps1

Add-Content $PROFILE.CurrentUserAllHosts '. $env:LOCALAPPDATA\proxyctl.ps1'
. $PROFILE.CurrentUserAllHosts
```

## Usage
1. Configure proxy (once)
Mixed port (recommended)
```sh
proxy_set 127.0.0.1:7890
```
```powershell
Set-ProxyConfig 127.0.0.1:7890
```
Explicit protocols
```sh
proxy_set http://127.0.0.1:7890 socks5://127.0.0.1:7890
```
```powershell
Set-ProxyConfig http://127.0.0.1:7890 socks5://127.0.0.1:7890
```

2. Enable / Disable
```sh
proxy_on
proxy_off
proxy_show
```
```powershell
Enable-Proxy
Disable-Proxy
Show-Proxy
```

---

## Environment variables set

When enabled, `proxyctl` sets:
- `http_proxy`, `https_proxy`, `all_proxy`
- `HTTP_PROXY`, `HTTPS_PROXY`, `ALL_PROXY`
- `no_proxy`, `NO_PROXY`

This ensures compatibility with tools like:
- `curl`
- `git`
- `ffmpeg`
- `apt`, `dnf`, `brew`
- Python / Node / Go toolchains

## Configuration files
Platform | Path
---|---
Linux / macOS |	`~/.config/proxyctl/config`
Windows |	`%APPDATA%\proxyctl\config.ps1`

## Limitations
- Only affects the current shell session
- Does not modify system-wide or GUI proxy settings
- Must be sourced to work correctly

## License
MIT

> **Note:** `proxyctl` genereted by LLM.
