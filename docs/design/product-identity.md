# Product Identity & Brand Specification

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Approved Brand Specification  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Authors:** Senior Product & Brand Design Architect  
**Date:** September 2026  

---

## 1. Executive Summary & Brand Vision

The status saver utility market on Google Play is deeply compromised. Hundreds of copycat applications exist under names such as *Status Saver*, *Status Downloader*, *Statusly*, *StatusKeep*, and *Status Vault*. These utilities share common anti-patterns:
- Cluttered, ad-heavy interfaces with aggressive interstitial banners
- Garish neon-green WhatsApp clone aesthetics and copyright-infringing brand marks
- Intrusive permission requests (`MANAGE_EXTERNAL_STORAGE`, contact access, account tracking)
- Generic terminology ("Download", "Files", "Videos") treating intimate human memories as disposable bulk files
- Fragile storage architectures that break on modern Android versions (Android 11–16)

**Keeva** reimagines this entire product space. 

Instead of an ad-laden "downloader utility," Keeva is positioned as **a private, premium media keeper for temporary moments**. It is designed around a single, resonant human truth:

> **"Keep the moments that matter."**

Status updates are not mere downloads; they are the shared milestones, candid family photographs, creative short videos, artistic expressions, and announcements of people we care about. Because they disappear after 24 hours, users feel anxiety about losing them. Keeva provides a tranquil, sovereign personal enclave where users can quietly browse their temporary moment stream and selectively keep what is precious with a single, deliberate tap.

---

## 2. Brand Positioning & Emotional Pillars

```
                     HIGH AESTHETIC SOPHISTICATION
                                   ▲
                                   │           ★ KEEVA
                                   │       (Private, Minimal,
                                   │        Media-First Keeper)
                                   │
              Apple Photos /       │
              Google Photos        │
                                   │
◄──────────────────────────────────┼──────────────────────────────────►
BROAD CLOUD / GENERAL GALLERY      │        PURPOSE-BUILT EPHEMERAL
                                   │               STORAGE
                                   │
                                   │      Generic Status Savers
                                   │      (Statusly, Status Vault, etc.)
                                   │      [Ad-heavy, Green Clones]
                                   │
                                   ▼
                      LOW AESTHETIC SOPHISTICATION
```

### Brand Pillars

| Pillar | Expression in UI & Copy | What We Avoid |
| :--- | :--- | :--- |
| **Calm & Quiet** | Restrained graphite surfaces, subtle lighting, zero visual noise, unhurried interactions. | Bright neon colors, flashing banners, exclamation points, cluttered cards. |
| **Private by Design** | 100% on-device processing, zero network requests, clear Android SAF boundaries, explicit trust indicator. | Requiring logins, uploading analytics, requesting contact or chat permissions. |
| **Media as Hero** | Edge-to-edge media cards, minimal UI chrome, typography that yields to imagery, high-fidelity color reproduction. | Heavy card borders, giant drop shadows, excessive metadata badges, prominent file paths. |
| **Deliberate Preservation** | Language of **"Keep"** and **"Kept"**, celebrating saved moments as cherished keepsakes. | Industrial terms like "Download", "Fetch", "Scrape", "Grab", "Export". |
| **Fluid & Trustworthy** | Instant 60/120fps scrolling, native Kotlin thumbnail decoders, zero frozen frames, seamless single-handed navigation. | Laggy web views, delayed thumbnail pops, unresponsive gesture controls. |

---

## 3. Brand Naming Exploration

A rigorous 28-candidate naming exploration was conducted across four thematic clusters. Each candidate was evaluated on linguistic cadence, international pronounceability (specifically validating English, Hindi, and multilingual Indian markets alongside European and American markets), emotional resonance, distinctiveness from WhatsApp, and trademark/app-store conflict profiles.

### Naming Exploration Matrix (28 Candidates)

| # | Name | Etymology / Meaning | Brand Personality | Why It Works | Potential Conflicts / Search Check | Risk Level |
| :- | :--- | :--- | :--- | :--- | :--- | :- |
| **01** | **Keeva** | Rooted in "Keep"; Gaelic *Caoimhe* ("cherished, gentle, precious"). | Calm, trustworthy, elegant, modern. | Short (5 letters), highly memorable, effortless phonetic delivery across India/global, evokes "Keeper". | No prominent mobile media app on Google Play or App Store. Minor local business matches. | **Low** (Strongest) |
| **02** | **Stowa** | From Old English / Scandinavian *stow* ("a quiet place of custody; to store safely"). | Architectural, Scandinavian, serene. | Evocative of mindful storage; soft vowel ending softens the Germanic root. | Stowa is a classic German watch brand (physical goods, Class 14). Watch faces on Play Store. | **Low–Med** |
| **03** | **Mementa** | Plural of *memento* (Latin: "remember", tokens of memory). | Editorial, literary, premium, thoughtful. | Directly honors the concept of keepsakes; sophisticated cadence. | Christopher Nolan's *Memento* trademark; various small note-taking utilities. | **Low–Med** |
| **04** | **Kip** | Dutch / Nordic short form of "keep"; crisp modern moniker. | Minimalist, snappy, youthful. | 3 letters, punchy, translates well to an icon mark. | Several niche apps ("Kip: Social Map", "Kip Tracker" hardware). Common noun in UK/AU. | **Medium** |
| **05** | **Arca** | Latin *arca* ("chest, coffer, ark, place of safekeeping"). | Classical, solid, vault-like, dignified. | Communicates structural security and timeless preservation. | ARCA Móvil (customs/tax app in Latin America); Arca Notes; Arca Wallet. | **Medium** |
| **06** | **Ambr** | Modern stylized form of *Amber* (natural resin preserving ancient moments). | Warm, protective, organic, precious. | Poetic metaphor of freezing a fleeting moment in golden gemstone. | Ambr health/sleep apps; Amber energy/crypto apps. | **Medium** |
| **07** | **Cairn** | Scottish Gaelic *carn* (man-made pile of stones marking a trail or memory). | Grounded, organic, reflective. | Evokes deliberate physical markers left for remembrance. | *Cairn: Hiking Safety* (popular outdoor app on Play Store). | **High** |
| **08** | **Ephem** | Truncation of *Ephemeral* (lasting for a very short time). | Technical, poetic, avant-garde. | Directly confronts the 24-hour nature of status media. | Harder to pronounce in non-native English regions; slightly abstract. | **Low** |
| **09** | **Keevo** | Masculine/modern vowel spin on "Keep". | Friendly, approachable, dynamic. | Easy to pronounce; feels like a helpful digital companion. | Various niche SaaS tools; lacks the refined poise of Keeva. | **Low** |
| **10** | **Morii** | Coined neologism: "the desire to capture a fleeting experience". | Poetic, philosophical, gentle. | Beautiful concept matching the exact problem space. | *Morii: Moments That Stay* exists on iOS; *AI Morii* on Google Play. | **High** |
| **11** | **Sift** | English verb: to filter and separate the valuable from the trivial. | Analytical, clean, efficient. | Captures the act of curating 1 or 2 great statuses from 50 fleeting posts. | Sift Science (major enterprise fraud prevention company); Sift news apps. | **Medium** |
| **12** | **Folio** | From Latin *folium* (a curated sheet, leaf, or portfolio). | Sophisticated, curated, archival. | Establishes a personal visual portfolio of temporary media. | Adobe Folio; various document/PDF reader applications. | **Medium** |
| **13** | **Haven** | English noun: a place of safety, sanctuary, and refuge. | Protective, soothing, dependable. | Strong privacy communication; makes saved media feel safe. | Haven: Keep Watch (Edward Snowden privacy project); Haven smart home. | **Medium** |
| **14** | **Relic** | An object surviving from an earlier time, held in reverence. | Historic, sacred, profound. | Turns everyday statuses into preserved visual relics. | Video game terminology (Relic Entertainment); slightly heavy/old connotation. | **Medium** |
| **15** | **Vela** | Constellation of the Sail; Latin for veil or sail. | Ethereal, celestial, graceful. | Short, beautiful, sounds premium on mobile. | Vela camera apps, Vela smart home; somewhat generic. | **Medium** |
| **16** | **Canto** | Italian / Latin: a division of a long poem; singing. | Melodic, rhythmic, artisanal. | Evokes storytelling and artistic expression. | Canto Digital Asset Management (enterprise brand, high trademark visibility). | **High** |
| **17** | **Trace** | A mark, object, or evidence left by something that has passed. | Subtle, observant, understated. | Ephemeral status updates leave a "trace" to be captured. | Trace tracking apps, Trace animation apps; common dictionary verb. | **Medium** |
| **18** | **Krona** | Scandinavian / Germanic word for crown; Greek *chronos* (time). | Regal, precise, temporal. | Combines time with enduring value. | Currencies of Sweden/Norway/Iceland; financial apps. | **High** |
| **19** | **Locket** | A small ornamental case holding a private portrait or keepsake. | Intimate, nostalgic, precious. | Beautiful emotional analog for keeping personal moments. | Locket Widget (massive viral photo-sharing app with 50M+ downloads). | **High** (Conflict) |
| **20** | **Capsule** | A sealed vessel holding artifacts from a specific era. | Futuristic, archival, structured. | Perfect metaphor for 24-hour temporary media. | Time Capsule apps, Capsule pharmacy app, Capsule CRM. | **High** |
| **21** | **Kura** | From Latin *curare* (to care for, curate, watch over). | Modern, Japanese/Latin crossover feel. | Sounds like "curate"; easy pronunciation in Asian and European languages. | Kura oncology; Kura sushi app. | **Low** |
| **22** | **Still** | A motionless photographic frame; quietness, peace. | Deeply photographic, tranquil. | Double meaning: freezing motion + stillness/peace of mind. | Common English adverb; difficult app store SEO searchability. | **Medium** |
| **23** | **Vaulta** | Neologism blending *vault* with lightness and agility. | Secure, contemporary, sleek. | Direct communication of safety without heavy banking connotations. | Vaulta energy; sounds close to generic "Vault" utilities. | **Low–Med** |
| **24** | **Aura** | The distinctive atmosphere or quality that surrounds a person or moment. | Luminous, sensory, modern. | Matches our "Obsidian + Aurora" visual identity. | Oura Ring, Aura Frames (digital frames), Aura health app. | **High** |
| **25** | **Flicker** | A quick flash of light; fleeting occurrence. | Dynamic, cinematic, playful. | Metaphor for the 24-hour status flash. | Flickr (iconic Yahoo photo platform — dangerous trademark proximity). | **High** (Fatal) |
| **26** | **Reminis** | Modern truncation of *reminisce* (to recall past experiences). | Nostalgic, thoughtful, personal. | Evokes warm reflection on past shared moments. | Remini (massive AI photo enhancer app with 100M+ downloads). | **High** (Fatal) |
| **27** | **Stash** | To store something safely and secretly in a quiet place. | Informal, smart, personal. | Very clear utility message; friendly. | Stash Invest (multi-billion dollar fintech); feels slightly illicit. | **High** |
| **28** | **Nadir** | The quietest point; astronomical opposite of zenith. | Mysterious, sleek, astronomical. | Evokes late-night private browsing. | Obscure meaning for general consumer audience; negative connotation in some languages. | **Medium** |

---

### The Strongest 3 Recommendations

#### Rank 1: **KEEVA** (Recommended Product Name)
- **Pronunciation:** `/ˈkiː.və/` ("KEE-vah"). Phonetically clean in Hindi (कीवा), Tamil, Telugu, Spanish, German, and English.
- **Etymology:** Rooted directly in the core product action **"Keep"**, augmented by the Gaelic root *caomh* ("cherished, gentle, beloved").
- **Brand Personality:** Poised, discreet, premium, warm, respectful.
- **Why It Wins:**
  1. It transforms the mechanical verb "Download" into an intimate identity: *Keeva is your private keeper*.
  2. Extremely clean 5-letter visual symmetry that balances beautifully in typography and app icons.
  3. Approved for internal development and testing. Namespace review shows strong distinction from existing gallery apps on Google Play; formal trademark clearance across target commercial jurisdictions remains a release/legal milestone prior to public distribution.
  4. Expandable far beyond WhatsApp: can seamlessly become a keeper for Instagram Stories, Signal disappearing media, Telegram stories, or personal temporary voice memos in future years.

#### Rank 2: **STOWA** (First Alternative)
- **Pronunciation:** `/ˈstoʊ.wə/` ("STOH-wah").
- **Etymology:** Derived from Old English *stōw* ("a place of custody, sanctuary, to stow away precious cargo").
- **Brand Personality:** Architectural, Nordic, minimalist, structured.
- **Why It Works:** Gives the application an industrial-design precision similar to Teenage Engineering or Leica. Ideal for a photography-centric crowd.
- **Risk Assessment:** Minor trademark crossover with Stowa Uhren (German watchmaker), though classes of goods (software vs. mechanical horology) are distinct.

#### Rank 3: **MEMENTA** (Second Alternative)
- **Pronunciation:** `/mɪˈmɛn.tə/` ("meh-MEN-tuh").
- **Etymology:** Neo-Latin plural of *memento* ("remembrances, keepsakes").
- **Brand Personality:** Editorial, literary, reflective, timeless.
- **Why It Works:** Elevates mundane status saving into an intentional act of visual archiving. 
- **Risk Assessment:** Longer letterform (7 characters); slightly academic for fast casual mobile users in emerging markets.

---

## 4. Brand Visual Direction Exploration

Three distinct visual directions were developed and evaluated against the application's unique constraints: heavy visual media browsing, high-density photo/video rendering, OLED battery efficiency, and emotional calm.

```
+---------------------------+---------------------------+---------------------------+
|  DIRECTION A:             |  DIRECTION B:             |  DIRECTION C:             |
|  OBSIDIAN + AURORA        |  SOFT EDITORIAL           |  MIDNIGHT GALLERY         |
|                           |                           |                           |
|  • Deep Graphite Charcoal |  • Warm Limestone & Linen |  • Pure OLED Black #000000|
|  • Restrained Mint Spark  |  • Terracotta & Sienna    |  • Stark Museum White     |
|  • Subtle Aurora Indigo   |  • Literary Serif Display |  • Monospaced Technical   |
|  • Fluid Specular Accents |  • Generous White Space   |  • Razor-thin 1px Frames  |
|  • Cinematic Media Focus  |  • Magazine Layout Feel   |  • Ultra-Austere Aesthetic|
+---------------------------+---------------------------+---------------------------+
```

### Comparative Evaluation Matrix

| Evaluation Criteria | Direction A: Obsidian + Aurora | Direction B: Soft Editorial | Direction C: Midnight Gallery |
| :--- | :---: | :---: | :---: |
| **Media Heroism** (Does media pop without UI clash?) | **9.5 / 10** (Dark backdrop makes vivid status colors shine) | **7.0 / 10** (Beige/warm tones clash with brightly saturated status media) | **9.0 / 10** (High contrast, but stark black feels sterile) |
| **Emotional Tone** (Calm, private, safe) | **9.5 / 10** (Intimate, sovereign, protective) | **8.5 / 10** (Relaxing, warm, but feels like a blog/journal) | **6.5 / 10** (Cold, clinical, aloof) |
| **Differentiation from Clones** | **10 / 10** (Completely breaks the cheap green downloader trope) | **9.0 / 10** (Unique, but feels like an Apple Books reader) | **8.0 / 10** (Resembles VSCO or minimalist camera apps) |
| **OLED / Battery Performance** | **9.5 / 10** (Near-black #0B0D11 saves substantial power) | **4.0 / 10** (Light surfaces consume 3-4x more display power) | **10 / 10** (True black #000000 maximizes pixel shutoff) |
| **UI Longevity & Ergonomics** | **9.0 / 10** (Gentle dark tones reduce night-time eye fatigue) | **7.5 / 10** (Harsh at night when browsing in bed) | **7.0 / 10** (Pure #000000 causes harsh smearing during 120Hz scroll) |
| **Overall Score** | **9.3 / 10 (WINNER)** | **7.2 / 10** | **8.1 / 10** |

### Selected Direction: **OBSIDIAN + AURORA**

#### Key Characteristics:
1. **The Canvas (Obsidian):** The primary environment is composed of deep, near-black graphite tones (`#090B0E` background, `#12151B` cards, `#1A1E26` elevated sheets). Pure `#000000` is avoided on scrollable containers to eliminate OLED purple pixel smearing on 120Hz displays (such as the Xiaomi 2311DRK48I test device).
2. **The Signature Spark (Aurora Mint):** A cool, restrained emerald-mint (`#10B981` / `#34D399`) represents the positive act of keeping. It is used sparingly: for the "Keep" confirmation, active navigation indicators, and the "Private" trust pill. It pays subtle homage to communication green while feeling luxurious, modern, and desaturated.
3. **The Ambient Depth (Aurora Indigo/Violet):** A subtle, deep violet-indigo glow (`#6366F1` / `#818CF8`) appears during multi-selection, focus highlights, and background depth gradients, giving the app an atmospheric luminescence without feeling like a garish gaming app.
4. **Editorial Typography:** High-contrast off-white (`#F9FAFB`) headlines paired with neutral muted grey metadata (`#9CA3AF`) set in **Plus Jakarta Sans**, an open-source geometric sans-serif with exceptional small-text legibility and tabular numbers for file metrics.

> **Anti-Gaming Guardrail:** No animated RGB borders, no pulsating particle effects, no heavy drop shadows, no neon glow text. Glows are strictly restricted to 1–2% opacity radial gradient backdrops behind key action sheets.

---

## 5. Logo & Brand Mark Specification

### Conceptual Architecture: "The Aperture of Keepsakes"

The Keeva logo mark is an original geometric emblem crafted from three interlocking visual ideas:
1. **The Media Frame (Outer Squircle):** A continuous-curvature squircle representing visual media (photography and video).
2. **The Inward Aperture Fold:** A geometric curve dipping inward from the upper-right corner, symbolizing the act of folding an ephemeral moment into safekeeping (a modern digital bookmark).
3. **The Aurora Spark:** A central luminous circular beacon at the golden focal point, representing the preserved moment radiating forever inside the protective frame.

```
       KEEVA LOGO MARK GEOMETRY
       
       ┌───────────────────────┐
       │   ╭───────────────╮   │
       │  │                 ╲  │  <-- Inward Folding Aperture
       │  │        ●         │ │  <-- The Preserved Moment Spark
       │  │                  │ │
       │   ╰────────────────╯  │
       └───────────────────────┘
```

### Logo Anatomy & Variants

| Asset File | Description | Usage Context |
| :--- | :--- | :--- |
| `assets/brand/logo.svg` | Combined Lockup: Mark + "Keeva" Wordmark | Brand headers, onboarding welcome, website, documentation. |
| `assets/brand/logo_mark.svg` | Standalone Geometric Symbol (Aperture + Spark) | App icon, splash screen center, favicon, watermark. |
| `assets/brand/logo_wordmark.svg` | Pure Typographic Wordmark in Plus Jakarta Sans Bold | Minimal navigation bars, footer credits, legal screens. |
| `assets/brand/logo_light.svg` | Dark Charcoal Lockup on Transparent Canvas | Light mode documentation, PDF exports, marketing print. |
| `assets/brand/logo_dark.svg` | Crisp Off-White + Mint Lockup on Dark Canvas | In-app dark theme splash, about screen, dark marketing. |
| `assets/icon/adaptive_foreground.svg` | High-Contrast Centered Mark (432x432 canvas, 240dp safe zone) | Android Adaptive Icon Foreground layer. |
| `assets/icon/adaptive_background.svg` | Deep Obsidian Charcoal Canvas with Subtle Radial Gradient | Android Adaptive Icon Background layer. |
| `assets/icon/app_icon_512.png` | Master 512×512 Squircle App Store Icon | Google Play Store listing, APK packaging. |
| `assets/icon/app_icon_round_512.png` | Master 512×512 Circular App Store Icon | Legacy circular launchers (Samsung OneUI / Pixel Launcher). |

### Optical Sizing & 24dp Recognition
The logo mark's strokes and negative space have been mathematically calculated for extreme legibility at small sizes:
- At **512dp**, the aperture stroke is 24px and the spark diameter is 56px with a delicate aurora halo.
- At **24dp** (notification bar / status bar icon), the stroke remains optically distinct (equivalent to 2.2dp weight) and the spark remains cleanly separated by a minimum of 3dp negative space, preventing the mark from filling in or blurring on low-DPI displays.

---

## 6. Brand Voice, Tone & Messaging

### Tone of Voice: *The Quiet Archivist*
- **Understated over Loud:** We speak in concise, composed sentences. We never use exclamation marks in core user flows.
- **Supportive over Pushy:** We guide the user with transparent technical honesty (e.g., explaining why a status must be viewed in WhatsApp first before Android's storage layer discovers it).
- **Sovereign over Cloned:** We never refer to "Status Saver" or use Meta/WhatsApp trademarks. We refer to the source neutrally as *"Your connected media folder"* or *"Status updates"*.

### Core Copywriting Dictionary

| Generic Utility Term | Keeva Term | Context & UX Rationale |
| :--- | :--- | :--- |
| Download | **Keep** | Shifts the emotion from a mundane network fetch to personal preservation. |
| Downloaded / Saved | **Kept** | A quiet badge of custody on a media card. |
| Download All | **Keep all** | Batch multi-select primary CTA. |
| Already Downloaded | **Already kept** | Informative duplicate notification with zero user guilt. |
| Download Success! | **Kept safely** | Discreet snackbar confirmation that automatically dismisses. |
| Status Media | **Moments** | Treats photos and videos as human memories. |
| Status Inbox | **Moments** | The primary screen destination. |
| Saved Vault | **Kept** | The permanent collection screen destination. |
| Delete from device | **Remove from Kept** | Explicitly clarifies that the original status on WhatsApp is unaffected. |
| Connect WhatsApp | **Connect your media folder** | Complies strictly with Google Play trademark guidelines. |

---

## 7. Legal & Trademark Compliance Safeguards

1. **Zero Meta/WhatsApp Brand Assets:** Keeva does not include, bundle, or reference the WhatsApp phone bubble logo, green palette, font, or trademarked graphics anywhere in the application or promotional store assets.
2. **Neutral Guidance Artwork:** In the onboarding flow (Step 3: Connect your WhatsApp media), system folder navigation is illustrated using generic Android document tree iconography (`DocumentsUI` folder motifs) rather than WhatsApp app screenshots.
3. **Google Play Policy Compliance:** The application is designed around Android scoped-storage and privacy-friendly SAF/MediaStore mechanisms. It accesses user-authorized folders via Android's official Storage Access Framework (`ACTION_OPEN_DOCUMENT_TREE`), requiring no background network permissions or broad storage management (`MANAGE_EXTERNAL_STORAGE`). Note: Google Play approval is subject to store review at submission time and cannot be unconditionally guaranteed.
4. **Brand Name Trademark Status:** "Keeva" is approved as the project's internal development and testing brand name. Formal legal trademark clearance and registration across target commercial jurisdictions remains a release milestone prior to public distribution.

