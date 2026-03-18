# Barcode Scan + Pipeline Simplification

## Context

The app currently adds books by photographing the cover (Claude Vision → OpenLibrary → Gemini enrichment). Users want a faster flow: scan a barcode to get the ISBN and look up the book automatically.

## Changes

### 1. iOS — Scan Mode Selector

- Add a **mode selector** on the camera screen (`.camera` state in `ScanFlowView`), styled like the iOS Camera app mode picker (horizontal pill carousel above the capture button)
- Two modes: **Code-barres** (default) | **Photo**
- In Photo mode: existing `CameraView` behavior unchanged
- In Barcode mode: replace `CameraView` with `DataScannerViewController` (VisionKit, iOS 16+) configured to recognize barcodes (EAN-13, EAN-8, UPC-A)
- On barcode detection: extract ISBN string, transition to `.scanning` state

### 2. iOS — Barcode Flow

1. `DataScannerViewController` detects barcode → ISBN extracted
2. `ScanViewModel` calls `ScanAPI.analyzeBarcode(isbn:)` → `POST /books/analyze-isbn`
3. Backend returns `BookPreview` (same type as photo flow)
4. Transition to `.preview(BookPreview)` — same editable confirmation screen
5. No cover image in barcode flow
6. Confirmation via existing `POST /books/confirm` endpoint

### 3. Backend — New Endpoint `POST /books/analyze-isbn`

- **Input**: `{ isbn: string }` validated with Zod (10-17 chars)
- **Flow**:
  1. Check duplicate by ISBN (`BookQuery.findByISBN`) → 409 if exists
  2. Check ISBN cache (`useStorage('isbn-cache')`)
  3. Call Gemini + Google Search with ISBN → get all book data in one call (title, authors, publisher, date, pages, genre, synopsis, language, format, series, seriesNumber, translator, price, awards, publicRatings)
  4. Cache result by ISBN
  5. Store as `BookPreviewData` → return `BookPreview` with `previewId`

### 4. Backend — Remove OpenLibrary, Simplify Photo Pipeline

- Delete `lookupByIsbn()` function (OpenLibrary calls) from `server/system/scan/index.ts`
- Remove `OpenLibraryData` type
- Simplify `BookScanner.scan()`: Claude Vision → Gemini enrichment (no more OpenLibrary step in between)
- Gemini + Google Search becomes the single enrichment source for both flows

### 5. Pipeline Summary

| Mode | Step 1 | Step 2 | Cover Image |
|------|--------|--------|-------------|
| Photo | Claude Vision (extract from cover) | Gemini + Google Search (enrich all) | From photo |
| Barcode | ISBN from scanner | Gemini + Google Search (all data) | None |

### 6. Files to Create

- `ios/Pchook/Features/Scan/Views/ScanModePicker.swift` — mode selector component (Photo/Code-barres pill)
- `ios/Pchook/Features/Scan/Views/BarcodeScannerView.swift` — `DataScannerViewController` wrapper
- `server/routes/books/analyze-isbn.post.ts` — new ISBN analysis endpoint
- `server/system/scan/isbn-scanner.ts` — ISBN-based scan logic (Gemini lookup + cache)

### 7. Files to Modify

- `ios/Pchook/Features/Scan/ScanFlowView.swift` — integrate mode selector, swap camera/barcode views
- `ios/Pchook/Features/Scan/ScanViewModel.swift` — add `scanBarcode(isbn:)` method
- `ios/Pchook/Features/Scan/ScanAPI.swift` — add `analyzeBarcode(isbn:)` API call
- `server/system/scan/index.ts` — remove `lookupByIsbn()`, simplify `BookScanner.scan()` pipeline
- `server/system/scan/types.ts` — add ISBN cache type if needed

### 8. Not in Scope

- Cover image fetching for barcode mode
- Replacing Claude Vision for photo mode
- Changes to the confirmation flow or `BookPreview` type
