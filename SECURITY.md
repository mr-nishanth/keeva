# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| main    | :white_check_mark: |

---

## Security Architecture & Design

Keeva is engineered around a privacy-preserving, local-first mobile architecture:

- **Local-First On-Device Execution**: Keeva does not declare internet permissions in its Android manifest (`android.permission.INTERNET` is absent) and performs no outbound network requests. Media discovery, preview caching, and saving operate strictly on the local device without external server dependencies.
- **No Intentional Telemetry**: The application includes no third-party analytics libraries, advertising SDKs, crash beacons, or remote tracking instrumentation.
- **Storage Access Framework (SAF)**: Keeva does not request or require broad storage manager permissions (`MANAGE_EXTERNAL_STORAGE`). File and directory access is limited strictly to the location explicitly chosen and authorized by the user via Android's native system picker (`ACTION_OPEN_DOCUMENT_TREE`).
- **MediaStore Export**: Kept media is saved to standard public collections (`Pictures/SavedStatus`, `Movies/SavedStatus`) via scoped Android MediaStore APIs without requesting broad legacy storage permissions.
- **Opaque Identifiers**: Storage URIs and raw filesystem paths remain encapsulated within the native Android service layer; Flutter presentation widgets interact only with opaque identifiers.


---

## Reporting a Vulnerability

If you discover a security vulnerability in Keeva, please report it responsibly:

1. **Do NOT open a public GitHub issue.**
2. Send a detailed report describing the vulnerability, affected components, and steps to reproduce to the repository maintainers via GitHub Security Advisories or the security contact email specified in the repository profile.
3. Allow reasonable time for investigation and resolution before public disclosure.

We take security seriously and appreciate your cooperation in keeping Keeva safe for all users.
