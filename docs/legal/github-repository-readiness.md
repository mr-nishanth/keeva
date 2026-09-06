# Keeva GitHub Repository Readiness & Configuration Guide

This document outlines the recommended GitHub repository settings, metadata, security automations, and contribution governance structures for **Keeva** prior to open-source publication.

> [!NOTE]
> In accordance with repository guidelines, none of these settings or files are created or applied automatically. This document serves as an actionable recommendation guide for the project maintainer.

---

## 1. Repository Metadata & Presentation

Reference: [GitHub Documentation: Managing Repository Settings](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features)

### Recommended Settings
- **Repository Name**: `keeva`
- **Current Repository Path**: `mr-nishanth/keeva`
- **URL**: `https://github.com/mr-nishanth/keeva`
- **Description**:
  ```text
  Private, local-first Android app for viewing and saving WhatsApp status media, built with Flutter.
  ```
- **Suggested Topics**:
  - `flutter`
  - `dart`
  - `android`
  - `privacy`
  - `local-first`
  - `media`
  - `whatsapp-status`
  - `material-3`
  - `riverpod`
- **Social Preview Banner**:
  - Upload `docs/assets/branding/keeva-github-social-preview.png` (1280×640 px, verified compliant with GitHub OpenGraph display standards).

---

## 2. GitHub Security Features

Reference: [GitHub Documentation: Best Practices for Repositories](https://docs.github.com/en/repositories/creating-and-managing-repositories/best-practices-for-repositories)

### 2.1. Security Configuration Checklist

| Feature | Recommended? | Availability | Action |
| :--- | :--- | :--- | :--- |
| **Dependabot Alerts** | **Yes** | Free for public repositories (GitHub Free & above). | Enable under *Settings > Code security and analysis*. |
| **Dependabot Security Updates** | **Yes** | Free for public repositories. | Enable under *Settings > Code security and analysis*. |
| **Dependabot Version Updates** | **Recommended** | Free for public repositories. | Commit `.github/dependabot.yml` when automated dependency PRs are desired. |
| **Secret Scanning** | **Yes** | Free for public repositories. | Enable under *Settings > Code security and analysis*. |
| **Push Protection** | **Yes** | Free for public repositories. | Enable under *Settings > Code security and analysis*. |
| **Private Vulnerability Reporting** | **Yes** | Free for public repositories. | Enable under *Settings > Code security and analysis*. |
| **Code Scanning (CodeQL / Static CI)** | **Recommended** | Free for public repositories (GitHub Actions minutes apply to private repos; free for standard public repos). | Configure GitHub Actions CI workflow to run formatting, analysis, and test suites. |

> [!NOTE]
> Availability depends on repository visibility and account type. For public repositories on GitHub Free, Dependabot, Secret Scanning, Push Protection, and Private Vulnerability Reporting are available at no charge. For private repositories, advanced security features may require GitHub Advanced Security (GHAS) licensing.

---

## 3. Repository Governance & Community Files

### 3.1. CODEOWNERS Decision

- **File**: `.github/CODEOWNERS`
- **Evaluation**:
  CODEOWNERS defines individuals or teams responsible for reviewing code in a repository. When a pull request touches owned files, GitHub automatically requests a review from the designated owners.
- **Assessment for Keeva**:
  Keeva is currently developed by **Nishvanta Labs** / `@mr-nishanth`.
  Adding `.github/CODEOWNERS` is **recommended** to make pull request review assignments deterministic and ensure that no PR is merged without maintainer review.
- **Proposed Template**:
  ```text
  # Default review assignment for all repository files
  *       @mr-nishanth

  # Native Android platform storage layer
  /android/   @mr-nishanth

  # Core domain & state architecture
  /lib/       @mr-nishanth
  ```
- **Status**: **Maintainer Decision Required.**

---

### 3.2. Code of Conduct Decision

- **File**: `CODE_OF_CONDUCT.md`
- **Evaluation**:
  A Code of Conduct outlines behavioral expectations, inclusivity standards, and harassment reporting channels for open-source project contributors.
- **Assessment for Keeva**:
  Adopting the industry-standard **Contributor Covenant v2.1** is **recommended** before opening the repository to public contributions. It establishes clear communication norms and fosters a healthy, professional open-source community.
- **Reporting Contact**: Requires specifying a dedicated maintainer contact (e.g., maintainer's GitHub handle or security contact email).
- **Status**: **Maintainer Decision Required.**

---

### 3.3. Citation Decision

- **File**: `CITATION.cff`
- **Evaluation**:
  The Citation File Format (`CITATION.cff`) allows academic authors, students, and research institutions to cite software in scholarly papers and research bibliographies.
- **Assessment for Keeva**:
  Keeva is a consumer-facing mobile utility application, not an academic library, scientific simulator, or dataset. A `CITATION.cff` file provides **minimal value** for Keeva and is **not recommended** at this stage unless an academic paper is published regarding its local-first Storage Access Framework architecture.
- **Status**: **Maintainer Decision Required.**

---

## 4. Summary of Maintainer Actions Prior to Public Release

1. **License Selection**: Choose candidate license in `docs/legal/license-options.md` and commit official `LICENSE` file.
2. **Metadata Setup**: Apply recommended name, description, topics, and social preview banner in GitHub repository settings.
3. **Security Configuration**: Enable Secret Scanning, Push Protection, Dependabot, and Private Vulnerability Reporting.
4. **Community Decisions**: Approve or defer `.github/CODEOWNERS` and `CODE_OF_CONDUCT.md`.
