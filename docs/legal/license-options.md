# Keeva Open-Source License Candidates & Legal Analysis

This document outlines the legal considerations, permissions, obligations, patent implications, and practical trade-offs of the primary candidate open-source licenses under consideration for **Keeva**.

> [!NOTE]
> **Selected Project License: Apache-2.0 (SELECTED)**
> The project maintainer has formally selected the **Apache License, Version 2.0 (Apache-2.0)** as the open-source license for Keeva. The official `LICENSE` file is committed in the repository root. This document preserves the legal analysis, candidate evaluation, and comparative trade-offs for historical and governance reference.

---

## 1. Context & Architectural Profile

Keeva is an Android-first mobile application built with Flutter, developed by **Nishvanta Labs** (*mr-nishanth/keeva*). Key characteristics impacting license selection include:

1. **Local-First & Privacy-Focused**: No cloud backend, no remote telemetry, no external ad SDKs.
2. **Storage Access Framework (SAF)**: Relies on native Android document provider integration and MediaStore APIs.
3. **All-Permissive Dependency Tree**: 100% of direct and transitive Dart/Flutter dependencies are licensed under permissive terms (MIT, BSD-3-Clause, Apache-2.0).
4. **Embedded Font**: Uses *Plus Jakarta Sans*, licensed under the SIL Open Font License 1.1 (OFL-1.1), which permits bundling with any software license.
5. **Brand Identity**: Original marks, logos, and vector assets belong to Nishvanta Labs.

---

## 2. Candidate License Analysis

### Option A: MIT License

- **SPDX Identifier**: `MIT`
- **Type**: Permissive
- **Full Text Reference**: [https://opensource.org/licenses/MIT](https://opensource.org/licenses/MIT) / [choosealicense.com/licenses/mit](https://choosealicense.com/licenses/mit/)

#### Summary of Terms
The MIT license is the most widely used permissive open-source license. It grants broad rights to use, copy, modify, merge, publish, distribute, sublicense, and sell copies of the software.

#### Permissions
- **Commercial Use**: Software and derivatives can be used commercially.
- **Modification**: Code can be modified, rewritten, or incorporated into other projects.
- **Distribution**: Code can be distributed in source or compiled form.
- **Sublicensing**: Downstream recipients can sublicense under different terms, including closed-source/proprietary terms.
- **Private Use**: Users may run, modify, and distribute internally without sharing source code.

#### Obligations & Conditions
- **License and Copyright Notice**: The original copyright notice and permission notice must be included in all copies or substantial portions of the Software.

#### Limitations
- **No Liability**: The author provides the software "as is" without warranty or liability.
- **No Trademark Rights**: Does not grant trademark rights, though it lacks an explicit trademark clause.
- **Patent Silence**: Contains no explicit patent grant or patent retaliation clause.

#### Compatibility
- Fully compatible with all existing Keeva dependencies (MIT, BSD-3-Clause, Apache-2.0).
- Downstream projects can incorporate Keeva code into virtually any project (permissive or copyleft).

#### Practical Implications for Keeva
- **Pros**: Minimal friction for community contributions; standard convention across the Flutter ecosystem; extremely simple for contributors and downstream developers to understand.
- **Cons**: Allows third parties to take Keeva's source code, rebrand it, close the source, and publish proprietary clones to Google Play without contributing changes back.

---

### Option B: Apache License 2.0 (SELECTED PROJECT LICENSE)

- **SPDX Identifier**: `Apache-2.0`
- **Type**: Permissive with Express Patent & Trademark Terms
- **Full Text Reference**: [https://www.apache.org/licenses/LICENSE-2.0](https://www.apache.org/licenses/LICENSE-2.0) / [choosealicense.com/licenses/apache-2.0](https://choosealicense.com/licenses/apache-2.0/)

#### Summary of Terms
The Apache 2.0 license is a comprehensive permissive license authored by the Apache Software Foundation. Like MIT, it permits commercial use, modification, and distribution, but adds explicit legal protections regarding patents, contributor grants, and trademarks.

#### Permissions
- **Commercial Use**: Full commercial usage and monetization allowed.
- **Modification**: Derivative works and alterations permitted.
- **Distribution**: Distribution of source and compiled binaries permitted.
- **Sublicensing**: Downstream derivatives can be licensed under differing terms (with conditions).
- **Patent Grant (Section 3)**: Explicit, royalty-free, irrevocable patent license granted by each contributor for contributions.

#### Obligations & Conditions
- **License and Copyright Notice**: Retain copyright, patent, trademark, and attribution notices.
- **State Changes (Section 4b)**: Prominent notices must be added to any modified files stating they were changed.
- **NOTICE File (Section 4d)**: If a `NOTICE` text file is included, downstream distributions must preserve it.

#### Limitations & Protections
- **No Trademark Grant (Section 6)**: Explicitly states that the license does **not** grant permission to use the trade names, trademarks, service marks, or product names of the Licensor (protects "Keeva" and "Nishvanta Labs" marks from unauthorized downstream commercial usage).
- **Patent Retaliation (Section 3)**: If a licensee initiates patent litigation alleging that the software infringes their patents, any patent licenses granted to them under Apache-2.0 terminate automatically.
- **No Liability / No Warranty**: Standard disclaimer of warranty and liability.

#### Compatibility
- Fully compatible with all Keeva dependencies (MIT, BSD-3-Clause, Apache-2.0).
- Apache-2.0 code can be incorporated into GPL-3.0 projects (one-way compatibility).

#### Practical Implications for Keeva
- **Pros**: Express trademark protection for the "Keeva" and "Nishvanta Labs" brand identities; express patent safety for contributors and users; structured attribution requirements (`NOTICE` file support).
- **Cons**: Slightly longer legal text; requires downstream distributors to document modifications explicitly.

---

### Option C: GNU General Public License v3.0

- **SPDX Identifier**: `GPL-3.0-only` or `GPL-3.0-or-later`
- **Type**: Strong Copyleft
- **Full Text Reference**: [https://www.gnu.org/licenses/gpl-3.0.en.html](https://www.gnu.org/licenses/gpl-3.0.en.html) / [choosealicense.com/licenses/gpl-3.0](https://choosealicense.com/licenses/gpl-3.0/)

#### Summary of Terms
The GPLv3 is the flagship strong-copyleft license from the Free Software Foundation. It is designed to ensure that the software and all derivative works remain free and open source forever ("copyleft").

#### Permissions
- **Commercial Use**: Software can be used commercially and distributed for a fee.
- **Modification**: Full rights to modify, enhance, or adapt the code.
- **Distribution**: Full rights to distribute binaries and source code.
- **Patent Grant (Section 11)**: Express patent grant shielding users from patent ambush.

#### Obligations & Conditions
- **Source Code Disclosure (Section 6)**: Anyone distributing binaries (e.g., via Google Play, GitHub Releases, or APK mirrors) must make the complete corresponding source code available under GPL-3.0.
- **Same License (ShareAlike)**: All modifications and derivative works *must* be licensed under the GPL-3.0. Downstream projects cannot close source code or re-license as proprietary.
- **State Changes**: Modified files must carry prominent notices stating that they were modified.
- **Tivoization / Anti-Circumvention (Section 6)**: Hardware devices that run GPLv3 software must provide users with installation information to execute modified binaries.

#### Limitations
- **No Sublicensing**: Downstream recipients receive their license directly from the original licensor.
- **No Liability / No Warranty**: Complete disclaimer of liability.

#### Compatibility
- Permissive dependencies (MIT, BSD-3-Clause, Apache-2.0) can be incorporated into a GPL-3.0 project without conflict.
- However, GPL-3.0 code **cannot** be incorporated back into purely permissive (MIT/Apache) projects.

#### Practical Implications for Keeva
- **Pros**: Prevents low-effort clone factories from taking Keeva's source code, repackaging it as a closed-source ad-infested app on the Play Store, and hiding improvements. Any distributor of Keeva must share their source code.
- **Cons**: Incompatible with closed-source enterprise environments; restricts downstream developers who might want to extract individual Keeva modules or libraries into proprietary apps.

---

## 3. Comparative Matrix

| Criterion | MIT | Apache-2.0 | GPL-3.0 |
| :--- | :--- | :--- | :--- |
| **License Category** | Permissive | Permissive with Patent Terms | Strong Copyleft |
| **Source Disclosure Required?** | No | No | **Yes** (for all distributions) |
| **Derivative Licensing** | Any license (even proprietary) | Any license (with notices) | **Must remain GPL-3.0** |
| **Express Patent Grant?** | No (silent) | **Yes** (Section 3) | **Yes** (Section 11) |
| **Patent Retaliation Clause?** | No | **Yes** | **Yes** |
| **Explicit Trademark Protection?** | No | **Yes** (Section 6) | Yes (Section 7(e)) |
| **State Changes Documented?** | No | **Yes** | **Yes** |
| **Dependency Tree Compatibility** | 100% Compatible | 100% Compatible | 100% Compatible |
| **Downstream Closed-Source Use** | Permitted | Permitted | **Prohibited** |
| **Ecosystem Norm (Flutter)** | Very High | High | Moderate (common for standalone apps) |

---

## 4. Special Considerations for Keeva

### 4.1. WhatsApp & Meta Trademark Distinction
Regardless of which license is chosen for the code, trademark rights are distinct from copyright:
- Neither MIT, Apache-2.0, nor GPL-3.0 gives anyone rights to Meta's or WhatsApp's trademarks.
- Apache-2.0 provides the clearest explicit protection for the project's own name ("Keeva") and developer name ("Nishvanta Labs").

### 4.2. Embedded Asset Separation
If the maintainer wishes to release the source code under an open-source license while retaining exclusive rights to the canonical brand marks (`assets/brand/keeva/` and `assets/brand/nishvanta/`), a dual or split-licensing clause can be documented:
- Source code: Licensed under chosen open-source license (e.g., MIT, Apache-2.0, or GPL-3.0).
- Brand assets: All rights reserved / proprietary to Nishvanta Labs, or governed by project brand guidelines.

---

## 5. Maintainer Decision Block

- **Selected License:** Apache License, Version 2.0 (`Apache-2.0`) [SELECTED]
- **Copyright Holder:** Nishvanta Labs
- **Decision Date:** 2026-09-06
- **Status:** Finalized — `LICENSE` file created and committed at repository root.
- **Scope:** Project source code, documentation, and tooling. (Canonical brand assets in `assets/brand/` remain governed by Nishvanta Labs brand guidelines in accordance with Section 6 of Apache-2.0).
