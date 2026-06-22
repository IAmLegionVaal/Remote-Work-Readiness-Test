# Remote Work Readiness Test

> **Testing note:** This was tested by me to be working. User experience may vary.

## One-click use

1. Download and extract the repository.
2. Double-click `Run-OneClick.bat`.
3. The full readiness test runs directly—there is no menu and no Windows configuration is changed.
4. Review the exit code and reports under `C:\Users\Public\Documents\RemoteWorkReadinessReports`.

Included: `Test-RemoteWorkReadiness.ps1`

## PowerShell usage

```powershell
.\Test-RemoteWorkReadiness.ps1
.\Test-RemoteWorkReadiness.ps1 -Endpoint 'example.com','login.microsoftonline.com'
```

Creates read-only reports for adapters, IP configuration, proxy, VPN adapters, Microsoft client presence, DNS and HTTPS connectivity.

Exit codes: `0` all endpoint tests passed, `1` fatal error, `2` one or more endpoint tests failed.

A successful test does not guarantee application or account authentication. MIT License.
