# Remote Work Readiness Test

> **Testing note:** This was tested by me to be working. User experience may vary.

Included: `Test-RemoteWorkReadiness.ps1`

```powershell
.\Test-RemoteWorkReadiness.ps1
.\Test-RemoteWorkReadiness.ps1 -Endpoint 'example.com','login.microsoftonline.com'
```

Creates read-only reports for adapters, IP configuration, proxy, VPN adapters, Microsoft client presence, DNS and HTTPS connectivity.

Reports: `C:\Users\Public\Documents\RemoteWorkReadinessReports`

Exit codes: `0` all endpoint tests passed, `1` fatal error, `2` one or more endpoint tests failed.

A successful test does not guarantee application or account authentication. MIT License.
