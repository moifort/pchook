# Barcode Scan + Pipeline Simplification

## Context

The app currently adds books by photographing the cover (Claude Vision → OpenLibrary → Gemini enrichment). Users want a faster flow: scan a barcode to get the ISBN and look up the book automatically.

## Changes

### 1. iOS — Scan Mode Selector

- Add a **mode selector** on the camera screen (`.camera` state in `ScanFlowView`), styled like the iOS Camera app mode picker (horizontal pill carousel above the capture button)
- Two modes: **Code-barres** (default) | **Photo**
- In Photo mode: existing `CameraView` behavior unchanged
- In Barcode mode: replace `CameraView` with `DataScannerViewController` (VisionKit, iOS 16+) configured to recognize barcodes (EAN-13, EAN-8, UPC-A)
- On barcode detection: validate the scanned string is an ISBN (10 or 13 digits). If not (EAN-8, UPC-A, other), show an inline error "Ce code-barres n'est pas un ISBN". Only send valid ISBNs to the backend.
- Mode state: stored as `@State` local to `ScanFlowView` (not in `ScanViewModel` — it's a UI concern)

### 2. iOS — Barcode Flow

1. `DataScannerViewController` detects barcode → ISBN extracted and validated client-side
2. `ScanViewModel` calls `ScanAPI.analyzeBarcode(isbn:)` → `POST /books/analyze-isbn`
3. Backend returns `BookPreview` (same type as photo flow) or 409 with `{ status: 409, data: { bookId, title, authors } }` for duplicates
4. On 200: transition to `.preview(BookPreview)` — same editable confirmation screen
5. On 409: transition to `.duplicate(bookId, title, authors)` — existing duplicate screen
6. No cover image in barcode flow
7. Confirmation via existing `POST /books/confirm` endpoint

### 3. Backend — New Endpoint `POST /books/analyze-isbn`

- **Input**: `{ isbn: string }` validated with Zod: `z.object({ isbn: z.string().regex(/^\d{10}(\d{3})?$/) })`
- **409 response**: `{ status: 409, data: { bookId: string, title: string, authors: string[] } }`
- **200 response**: `{ status: 200, data: BookPreview }`
- **Flow**:
  1. Construct branded `ISBN` via primitive constructor from `server/domain/book/primitives.ts`
  2. Check duplicate by ISBN (`BookQuery.findByISBN(isbn)`) → 409 if exists. Project 409 payload from `Book`: `{ bookId: book.id, title: String(book.title), authors: book.authors.map(String) }`
  3. Check ISBN cache (`useStorage('isbn-cache')`) with type `CachedIsbnResult`
  4. Call Gemini + Google Search with ISBN → get all book data in one call (title, authors, publisher, date, pages, genre, synopsis, language, format, series, seriesNumber, translator, price, awards, publicRatings)
  5. Cache result by ISBN
  6. Store as `BookPreviewData` → return `BookPreview` with `previewId`

### 4. Backend — Remove OpenLibrary, Simplify Pipelines

- Delete `lookupByIsbn()` function and `OpenLibraryData` type from `server/system/scan/index.ts`
- Simplify `BookScanner.scan()`: Claude Vision → Gemini enrichment (no more OpenLibrary step in between)
- Remove `lookupByIsbn` import and usage from `server/system/scan/share-import.ts` (lines 4, 182-193) — Gemini already provides all the data that OpenLibrary was enriching
- Gemini + Google Search becomes the single enrichment source for all flows (photo, barcode, URL share)

### 5. Pipeline Summary

| Mode | Step 1 | Step 2 | Cover Image |
|------|--------|--------|-------------|
| Photo | Claude Vision (extract from cover) | Gemini + Google Search (enrich all) | From photo |
| Barcode | ISBN from scanner | Gemini + Google Search (all data) | None |
| URL Share | Gemini + Google Search (extract + enrich) | — | None |

### 6. Files to Create

- `ios/Pchook/Features/Scan/Views/ScanModePicker.swift` — mode selector component (Photo/Code-barres pill)
- `ios/Pchook/Features/Scan/Views/BarcodeScannerView.swift` — `DataScannerViewController` wrapper via `UIViewControllerRepresentable`. Coordinator must be `@MainActor` for Swift 6 strict concurrency compliance when bridging `DataScannerViewControllerDelegate` callbacks
- `server/routes/books/analyze-isbn.post.ts` — new ISBN analysis endpoint
- `server/routes/books/analyze-isbn.post.feat.test.ts` — feature test: happy path (returns preview), duplicate detection (409), Gemini failure (500)
- `server/system/scan/isbn-scanner.ts` — `export namespace IsbnScanner { scan(isbn: ISBN): Promise<ScanResult> }` — ISBN-based scan logic (Gemini lookup + cache)

### 7. Files to Modify

- `ios/Pchook/Features/Scan/ScanFlowView.swift` — add `@State scanMode` (barcode default), integrate mode selector, swap camera/barcode views based on mode
- `ios/Pchook/Features/Scan/ScanViewModel.swift` — add `scanBarcode(isbn:)` method
- `ios/Pchook/Features/Scan/ScanAPI.swift` — add `analyzeBarcode(isbn:)` API call with 409 handling
- `server/system/scan/index.ts` — remove `lookupByIsbn()`, `OpenLibraryData`, simplify `BookScanner.scan()` pipeline
- `server/system/scan/share-import.ts` — remove `lookupByIsbn` import and usage (lines 4, 182-193), return `extracted` directly
- `server/system/scan/types.ts` — add `CachedIsbnResult { isbn: ISBN, result: ScanResult, cachedAt: Date }` (branded `ISBN` type from `server/domain/book/types.ts`)

### 8. Not in Scope

- Cover image fetching for barcode mode
- Replacing Claude Vision for photo mode
- Changes to the confirmation flow or `BookPreview` type
