# User Flows & Interaction State Machines

**Product:** Keeva (WhatsApp Status Saver → New Product Identity)  
**Document Status:** Approved Interaction Architecture  
**Design Phase:** Phase 2E-A (Product Brand & UI/UX Design System)  
**Authors:** Senior Mobile UX Architect  
**Date:** September 2026  

---

## 1. Flow 1: First-Time User Onboarding & SAF Folder Grant

This flow guides the user from cold initial app launch through the required Android Storage Access Framework (SAF) folder authorization with zero confusion and zero technical jargon.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant FlutterUI as Keeva (Flutter UI)
    participant Channel as Platform Channel
    participant Native as Kotlin (SafStorageManager)
    participant System as Android OS (DocumentsUI)

    User->>FlutterUI: Opens Keeva for the first time
    FlutterUI->>Channel: checkFolderAccess()
    Channel->>Native: Check persisted URI permissions
    Native-->>FlutterUI: { hasAccess: false }
    FlutterUI->>User: Displays Screen 02 (Welcome & Purpose)
    User->>FlutterUI: Taps "Continue"
    FlutterUI->>User: Displays Screen 03 (Privacy Guarantees)
    User->>FlutterUI: Taps "Continue"
    FlutterUI->>User: Displays Screen 04 (3-Step Guided Folder Guide)
    User->>FlutterUI: Taps "Connect Media Folder"
    FlutterUI->>Channel: requestFolderAccess()
    Channel->>Native: Launch ACTION_OPEN_DOCUMENT_TREE with EXTRA_INITIAL_URI
    Native->>System: Opens DocumentsUI at Android/media/com.whatsapp/WhatsApp/Media
    User->>System: Taps "Use this folder" -> "Allow"
    System-->>Native: onActivityResult(treeUri)
    Native->>Native: takePersistableUriPermission(treeUri)
    Native-->>Channel: { granted: true, treeUri: "content://..." }
    Channel-->>FlutterUI: Success Result
    FlutterUI->>User: Displays Screen 05 ("Connected safely ✓")
    FlutterUI->>FlutterUI: Transitions to Screen 06 (Moments Home)
```

### Flow 1 Failure & Recovery Paths
- **User Cancels System Picker:** Native returns `granted: false`. Keeva displays Screen 04 with a gentle prompt: *"Folder connection is required to discover your statuses. Tap Connect whenever you're ready."*
- **User Selects Wrong Folder:** Native checks if the selected tree URI contains `.Statuses` or `com.whatsapp`. If completely unrelated, native flags a warning: *"Selected folder does not look like WhatsApp Media. Tap here to re-select."*

---

## 2. Flow 2: Quick-Keep Single Moment (<5s Target)

The hallmark of Keeva is an ultra-fast, frictionless path to preserve a status update before it expires.

```
                  THE 5-SECOND KEEP PROMISE
                  
   [OPEN APP]  ──►  [SEE MOMENTS]  ──►  [TAP QUICK-KEEP]  ──►  [KEPT SAFELY ✓]
     0.0s               1.2s                 2.4s                 3.1s
```

```mermaid
flowchart TD
    Start([User Launches Keeva]) --> Scan[Background Kotlin Scans Statuses]
    Scan --> Grid[Moments Grid Appears < 1.2s]
    Grid --> Decision{User Action?}
    
    Decision -->|Option A: Direct Card Keep| QuickTap[Taps Quick-Keep Icon on Card]
    Decision -->|Option B: Preview First| CardTap[Taps Card Body]
    
    CardTap --> Viewer[Immersive Media Viewer Opens]
    Viewer --> KeepBtn[Taps Signature 'Keep' Button]
    
    QuickTap --> CheckDup{Duplicate?}
    KeepBtn --> CheckDup
    
    CheckDup -->|Not Yet Saved| MediaStore[Native MediaStore Export to Pictures/Movies]
    CheckDup -->|Already Saved| DupShield[Duplicate Shield Sheet: View Saved or Keep Anyway]
    
    MediaStore --> Success[Haptic Tick + 'Kept safely ✓']
    Success --> Done([Moment Preserved in Gallery])
```

---

## 3. Flow 3: Multi-Select Batch Keep with Duplicate Shield

When a user has viewed multiple statuses (e.g., from a wedding or event) and wants to save 10 items at once without creating duplicate files in their device gallery.

```mermaid
stateDiagram-v2
    [*] --> NormalGrid: Browsing Moments
    NormalGrid --> SelectionMode: Long-press Card OR Tap "Select"
    
    state SelectionMode {
        [*] --> SelectItems: Tap Cards to Toggle
        SelectItems --> Evaluate: Compute New vs Already Kept
        Evaluate --> UpdateBar: Update Floating Bar "Keep (X new)"
    }
    
    SelectionMode --> BatchKeep: Taps "Keep (X new)"
    
    state BatchKeep {
        [*] --> FilterOut: Exclude items with existing gallery records
        FilterOut --> ExportLoop: Stream remaining files via MediaStore
        ExportLoop --> ConfirmBatch: Haptic Pulse + Toast "5 new moments kept"
    }
    
    BatchKeep --> NormalGrid: Selection Cleared Automatically
```

### Duplicate Shield Calculation Logic
If user selects 8 total items where 5 are new and 3 have existing entries in `KeptMedia`:
1. The primary button label renders: **"Keep 5 new"** (with secondary micro-caption: *"3 already in gallery"*).
2. Tapping the button saves only the 5 new items, saving precious device storage and avoiding gallery clutter.
3. If user explicitly wants duplicates, an overflow menu provides: *"Force keep all 8"*.

---

## 4. Flow 4: Immersive Media Viewing & Gesture Navigation

```mermaid
stateDiagram-v2
    [*] --> GridView: User Taps Thumbnail
    GridView --> FullViewer: Hero Zoom Animation (250ms)
    
    state FullViewer {
        [*] --> IdleControls: Controls Visible (Top bar + Keep CTA)
        IdleControls --> HiddenControls: 3s Inactivity OR Single Tap
        HiddenControls --> IdleControls: Single Tap
        
        IdleControls --> Zooming: Pinch Gesture / Double Tap
        Zooming --> IdleControls: Pinch Out to 1.0x
        
        IdleControls --> DismissDrag: Swipe Down Gesture
        DismissDrag --> GridView: Release Past 120dp (Dismiss)
        DismissDrag --> IdleControls: Release Under 120dp (Snap Back)
        
        IdleControls --> SwipeNext: Horizontal Swipe Left (Next Status)
        IdleControls --> SwipePrev: Horizontal Swipe Right (Prev Status)
    }
```

---

## 5. Flow 5: Managing Kept Media & Sharing

```mermaid
flowchart LR
    KeptTab[Open 'Kept' Tab] --> ViewGrid[Chronological Saved Moments]
    ViewGrid --> TapItem[Tap Saved Card]
    TapItem --> ActionMenu{Select Action}
    
    ActionMenu -->|Share| AndroidShare[Native Android Intent.ACTION_SEND]
    ActionMenu -->|Open Gallery| LaunchGallery[Launch System Gallery App]
    ActionMenu -->|Remove| DeleteConfirm[Confirmation Sheet: 'Remove from Kept?']
    
    DeleteConfirm --> DeleteMediaStore[Delete from MediaStore Collection]
    DeleteMediaStore --> UpdateFootprint[Storage Footprint Decrements]
```

---

## 6. Flow 6: Storage & Cache Management in Settings

```mermaid
flowchart TD
    OpenSettings[Open Settings Screen] --> StorageSection[Inspect Storage & Cache]
    StorageSection --> Metrics[Display: Thumbnails 24 MB | Videos 48 MB | Gallery 1.2 GB]
    Metrics --> TapClear[User Taps 'Clear Temporary Caches']
    TapClear --> Confirm[Dialog: Temporary playback files will be cleared. Saved gallery items unaffected.]
    Confirm --> NativePurge[Kotlin deletes internal cacheDir files]
    NativePurge --> ResetMetrics[Thumbnails: 0 MB | Videos: 0 MB]
    ResetMetrics --> Feedback[Toast: 'Cache cleared safely']
```

---

## 7. Flow 7: Permission Revocation Recovery Flow

Handles the critical edge case where a user revokes folder permission from Android OS App Settings or uninstalls WhatsApp.

```mermaid
flowchart TD
    AppLaunch[App Resumes or Launches] --> QuerySAF[Native Queries Persisted Tree URI]
    QuerySAF --> IsValid{ContentResolver Query Valid?}
    
    IsValid -->|Yes| NormalInbox[Display Moments Grid]
    IsValid -->|No / SecurityException| RevokedState[StateNotifier Enters AccessDenied State]
    
    RevokedState --> DisplayEmpty[Display Screen 04: 'Folder access needed']
    DisplayEmpty --> Explain[Explains that Android requires re-granting the folder]
    Explain --> Reconnect[User Taps 'Re-connect Folder']
    Reconnect --> LaunchSAF[Re-launch DocumentsUI Picker]
    LaunchSAF --> Success[Persisted Access Restored]
```
