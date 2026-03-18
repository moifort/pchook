# Barcode Scan + Pipeline Simplification — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add barcode scanning mode to the iOS scan flow and simplify the backend enrichment pipeline by removing OpenLibrary in favor of Gemini-only enrichment.

**Architecture:** The backend gets a new `POST /books/analyze-isbn` endpoint that looks up books via Gemini + Google Search from an ISBN. The existing photo and URL share pipelines are simplified by removing the OpenLibrary step. On iOS, the camera screen adds a mode selector (barcode default / photo) using VisionKit's `DataScannerViewController` for barcode scanning.

**Tech Stack:** TypeScript/Nitro (backend), SwiftUI/VisionKit (iOS), Gemini API with Google Search grounding, bun:test with BDD DSL

**Spec:** `docs/superpowers/specs/2026-03-18-barcode-scan-design.md`

---

## Task 1: Add `CachedIsbnResult` type

**Files:**
- Modify: `server/system/scan/types.ts`

- [ ] **Step 1: Add the new cache type**

In `server/system/scan/types.ts`, add the import for `ISBN` type and the new `CachedIsbnResult` type after `CachedUrlImportResult`:

```typescript
import type { ISBN } from '~/domain/book/types'

// ... existing types ...

export type CachedIsbnResult = {
  isbn: ISBN
  result: ScanResult
  cachedAt: Date
}
```

- [ ] **Step 2: Verify typecheck**

Run: `bun tsc --noEmit`
Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add server/system/scan/types.ts
git commit -m "feat(scan): add CachedIsbnResult type"
```

---

## Task 2: Create `IsbnScanner` namespace

**Files:**
- Create: `server/system/scan/isbn-scanner.ts`
- Create: `server/system/scan/isbn-repository.ts`

- [ ] **Step 1: Create the ISBN cache repository**

Create `server/system/scan/isbn-repository.ts` following the pattern from `server/system/scan/repository.ts`:

```typescript
import type { ISBN } from '~/domain/book/types'
import type { CachedIsbnResult } from '~/system/scan/types'

const storage = () => useStorage('isbn-cache')

export const findBy = (isbn: ISBN) => storage().getItem<CachedIsbnResult>(isbn)

export const save = async (entry: CachedIsbnResult) => {
  await storage().setItem(String(entry.isbn), entry)
  return entry
}
```

- [ ] **Step 2: Create the ISBN scanner**

Create `server/system/scan/isbn-scanner.ts`. This calls Gemini + Google Search to get all book data from an ISBN:

```typescript
import type { ISBN } from '~/domain/book/types'
import { createLogger } from '~/system/logger'
import { buildBookJsonSchema, callGemini, normalizeBookFormat } from '~/system/scan/gemini'
import * as repository from '~/system/scan/isbn-repository'
import type { ScanResult } from '~/system/scan/types'

const log = createLogger('isbn-scanner')

const lookupWithGemini = async (isbn: ISBN) => {
  const prompt = `Pour le livre avec l'ISBN ${isbn}, recherche et retourne toutes les informations suivantes au format JSON strict (sans markdown, sans backticks) :

${buildBookJsonSchema(true)}

Recherche les données les plus récentes et précises possibles sur Wikipedia, Goodreads, Babelio, Sens Critique, Amazon et d'autres sources fiables. Toutes les valeurs textuelles en français.`

  const parsed = await callGemini(prompt)

  const title = parsed.title as string | undefined
  const authors = parsed.authors as string[] | undefined
  if (!title || !authors?.length) {
    throw new Error(`Gemini could not find book data for ISBN ${isbn}`)
  }

  return {
    title,
    authors,
    publisher: parsed.publisher as string | undefined,
    publishedDate: parsed.publishedDate as string | undefined,
    pageCount: parsed.pageCount as number | undefined,
    genre: parsed.genre as string | undefined,
    synopsis: parsed.synopsis as string | undefined,
    isbn: (parsed.isbn as string) ?? String(isbn),
    language: parsed.language as string | undefined,
    format: normalizeBookFormat(parsed.format as string | undefined),
    series: parsed.series as string | undefined,
    seriesNumber: parsed.seriesNumber as number | undefined,
    translator: parsed.translator as string | undefined,
    estimatedPrice: parsed.estimatedPrice as number | undefined,
    duration: parsed.duration as string | undefined,
    narrators: (parsed.narrators as string[]) ?? undefined,
    awards: (parsed.awards as { name: string; year?: number }[]) ?? [],
    publicRatings:
      (parsed.publicRatings as {
        source: string
        score: number
        maxScore: number
        voterCount: number
      }[]) ?? [],
  } satisfies ScanResult
}

export namespace IsbnScanner {
  export const scan = async (isbn: ISBN) => {
    const cached = await repository.findBy(isbn)
    if (cached) {
      log.info('Cache hit for ISBN', String(isbn))
      return cached.result
    }

    log.info('Looking up ISBN with Gemini...', String(isbn))
    const result = await lookupWithGemini(isbn)

    await repository.save({
      isbn,
      result,
      cachedAt: new Date(),
    })

    return result
  }
}
```

- [ ] **Step 3: Verify typecheck**

Run: `bun tsc --noEmit`
Expected: PASS

- [ ] **Step 4: Commit**

```bash
git add server/system/scan/isbn-scanner.ts server/system/scan/isbn-repository.ts
git commit -m "feat(scan): add IsbnScanner namespace for ISBN-based Gemini lookup"
```

---

## Task 3: Create `POST /books/analyze-isbn` endpoint + feature test

**Files:**
- Create: `server/routes/books/analyze-isbn.post.ts`
- Create: `server/routes/books/analyze-isbn.post.feat.test.ts`

- [ ] **Step 1: Write the feature test**

Create `server/routes/books/analyze-isbn.post.feat.test.ts` following the pattern from `analyze.post.feat.test.ts`:

```typescript
import { expect, mock } from 'bun:test'
import type { ScanResult } from '~/system/scan/types'

const fakeScanResult: ScanResult = {
  title: 'Dune',
  authors: ['Frank Herbert'],
  publisher: 'Pocket',
  publishedDate: '1965-08-01',
  pageCount: 928,
  genre: 'Science-fiction',
  synopsis: "Sur la planète désertique Arrakis, l'épice est la substance la plus précieuse de l'univers.",
  isbn: '9782266320481',
  language: 'FR',
  format: 'pocket',
  series: 'Dune',
  seriesNumber: 1,
  translator: undefined,
  estimatedPrice: 9.7,
  awards: [{ name: 'Prix Hugo', year: 1966 }],
  publicRatings: [{ source: 'Babelio', score: 4.3, maxScore: 5, voterCount: 12000 }],
}

mock.module('~/system/scan/isbn-scanner', () => ({
  IsbnScanner: {
    scan: async () => fakeScanResult,
  },
}))

mock.module('~/system/suggestion/index', () => ({
  SuggestionGenerator: {
    generate: async () => [],
  },
}))

import analyzeIsbnHandler from '~/routes/books/analyze-isbn.post'
import confirmHandler from '~/routes/books/confirm.post'
import { and, feature, given, scenario, then, when } from '~/test/bdd'
import { mockEvent } from '~/test/setup'

feature('POST /books/analyze-isbn', () => {
  scenario('analyzes an ISBN and returns a preview', async () => {
    given('a valid ISBN')
    const event = mockEvent({ body: { isbn: '9782266320481' } })

    when('POST /books/analyze-isbn is called')
    const result = await analyzeIsbnHandler(event as never)

    then('a preview is returned with book data')
    expect(result.status).toBe(200)
    expect(result.data.previewId).toBeString()
    expect(result.data.title).toBe('Dune')
    expect(result.data.authors).toEqual(['Frank Herbert'])
    expect(result.data.genre).toBe('Science-fiction')
  })

  scenario('returns 409 when ISBN already exists in library', async () => {
    given('a first book has been confirmed with this ISBN')
    const firstAnalyze = mockEvent({ body: { isbn: '9782266320481' } })
    const firstResult = await analyzeIsbnHandler(firstAnalyze as never)
    const firstConfirm = mockEvent({
      body: { previewId: firstResult.data.previewId, status: 'to-read' },
    })
    await confirmHandler(firstConfirm as never)

    when('POST /books/analyze-isbn is called with the same ISBN')
    const event = mockEvent({ body: { isbn: '9782266320481' } })
    const result = await analyzeIsbnHandler(event as never)

    then('it returns 409 with the existing book info')
    expect(result.status).toBe(409)
    expect(result.data.title).toBeDefined()
  })

  scenario('analyzes ISBN then confirms to create a book', async () => {
    given('a preview has been created from an ISBN scan')
    const analyzeEvent = mockEvent({ body: { isbn: '9782266320481' } })
    const analyzeResult = await analyzeIsbnHandler(analyzeEvent as never)
    const { previewId } = analyzeResult.data

    when('POST /books/confirm is called with the preview ID')
    const confirmEvent = mockEvent({ body: { previewId, status: 'to-read' } })
    const result = await confirmHandler(confirmEvent as never)

    then('a book is created with the scan result data')
    expect(result.status).toBe(201)
    expect(String(result.data.title)).toBe('Dune')
  })

  scenario('returns 500 when Gemini lookup fails', async () => {
    given('Gemini will fail for this ISBN')
    const { mock: isbnMock } = mock.module('~/system/scan/isbn-scanner', () => ({
      IsbnScanner: {
        scan: async () => {
          throw new Error('Gemini API unavailable')
        },
      },
    }))

    when('POST /books/analyze-isbn is called')
    const event = mockEvent({ body: { isbn: '9782266320481' } })

    then('it throws an error')
    expect(analyzeIsbnHandler(event as never)).rejects.toThrow()

    // Restore normal mock for other tests
    isbnMock.module('~/system/scan/isbn-scanner', () => ({
      IsbnScanner: { scan: async () => fakeScanResult },
    }))
  })
})
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bun test server/routes/books/analyze-isbn.post.feat.test.ts`
Expected: FAIL — module `~/routes/books/analyze-isbn.post` not found

- [ ] **Step 3: Create the endpoint**

Create `server/routes/books/analyze-isbn.post.ts`:

```typescript
import { z } from 'zod'
import { ISBN } from '~/domain/book/primitives'
import { BookQuery } from '~/domain/book/query'
import { IsbnScanner } from '~/system/scan/isbn-scanner'
import * as previewRepository from '~/system/scan/preview-repository'

const bodySchema = z.object({
  isbn: z.string().regex(/^\d{10}(\d{3})?$/),
})

export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  const { isbn: rawIsbn } = bodySchema.parse(body)
  const isbn = ISBN(rawIsbn)

  const existing = await BookQuery.findByISBN(isbn)
  if (existing) {
    setResponseStatus(event, 409)
    return {
      status: 409,
      data: {
        bookId: String(existing.id),
        title: String(existing.title),
        authors: existing.authors.map(String),
      },
    } as const
  }

  const scanResult = await IsbnScanner.scan(isbn)
  const previewId = crypto.randomUUID()

  await previewRepository.save({
    previewId,
    scanResult,
    createdAt: new Date(),
  })

  return { status: 200, data: { previewId, ...scanResult } } as const
})
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bun test server/routes/books/analyze-isbn.post.feat.test.ts`
Expected: PASS (4 scenarios)

- [ ] **Step 5: Verify full typecheck + all tests + lint**

Run: `bunx nitro prepare && bun tsc --noEmit && bun test && bunx biome check`
Expected: all PASS

- [ ] **Step 6: Commit**

```bash
git add server/routes/books/analyze-isbn.post.ts server/routes/books/analyze-isbn.post.feat.test.ts
git commit -m "feat(scan): add POST /books/analyze-isbn endpoint with feature test"
```

---

## Task 4: Remove OpenLibrary from photo scan pipeline

**Files:**
- Modify: `server/system/scan/index.ts`

- [ ] **Step 1: Remove `lookupByIsbn` and `OpenLibraryData`, simplify `BookScanner.scan`**

In `server/system/scan/index.ts`:

1. Delete the `OpenLibraryData` type (lines 115-120)
2. Delete the entire `lookupByIsbn` function (lines 122-159)
3. In `BookScanner.scan`, remove the OpenLibrary step. Replace lines 226-235:

```typescript
// BEFORE:
const isbnData = await lookupByIsbn(scanResult.isbn)
const withIsbn: ScanResult = isbnData
  ? {
      ...scanResult,
      publisher: isbnData.publisher ?? scanResult.publisher,
      pageCount: isbnData.pageCount ?? scanResult.pageCount,
      publishedDate: isbnData.publishedDate ?? scanResult.publishedDate,
      synopsis: scanResult.synopsis ?? isbnData.synopsis,
    }
  : scanResult

log.info('Enriching with Gemini...', withIsbn.title)
const enrichedResult = await enrichWithGemini(withIsbn)

// AFTER:
log.info('Enriching with Gemini...', scanResult.title)
const enrichedResult = await enrichWithGemini(scanResult)
```

- [ ] **Step 2: Verify typecheck**

Run: `bun tsc --noEmit`
Expected: PASS

- [ ] **Step 3: Run existing tests to ensure nothing broke**

Run: `bun test`
Expected: all PASS

- [ ] **Step 4: Commit**

```bash
git add server/system/scan/index.ts
git commit -m "refactor(scan): remove OpenLibrary from photo scan pipeline"
```

---

## Task 5: Remove OpenLibrary from URL share pipeline

**Files:**
- Modify: `server/system/scan/share-import.ts`

- [ ] **Step 1: Remove `lookupByIsbn` import and usage**

In `server/system/scan/share-import.ts`:

1. Remove line 4: `import { lookupByIsbn } from '~/system/scan/index'`
2. Replace lines 182-193 (the ISBN lookup + merge) with just returning `extracted` directly:

```typescript
// BEFORE:
const isbnData = await lookupByIsbn(extracted.isbn)
log.info('ISBN lookup result', isbnData ?? 'no data')

const scanResult: ScanResult = isbnData
  ? {
      ...extracted,
      publisher: isbnData.publisher ?? extracted.publisher,
      pageCount: isbnData.pageCount ?? extracted.pageCount,
      publishedDate: isbnData.publishedDate ?? extracted.publishedDate,
      synopsis: extracted.synopsis ?? isbnData.synopsis,
    }
  : extracted

// AFTER:
const scanResult = extracted
```

- [ ] **Step 2: Verify typecheck + tests + lint**

Run: `bun tsc --noEmit && bun test && bunx biome check`
Expected: all PASS

- [ ] **Step 3: Commit**

```bash
git add server/system/scan/share-import.ts
git commit -m "refactor(scan): remove OpenLibrary from URL share pipeline"
```

---

## Task 6: iOS — `BarcodeScannerView` (VisionKit wrapper)

**Files:**
- Create: `ios/Pchook/Features/Scan/Views/BarcodeScannerView.swift`

- [ ] **Step 1: Create the `DataScannerViewController` wrapper**

Create `ios/Pchook/Features/Scan/Views/BarcodeScannerView.swift`:

```swift
import SwiftUI
import VisionKit

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeDetected: @MainActor (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .upce])],
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if !uiViewController.isScanning {
            context.coordinator.reset()
            try? uiViewController.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeDetected: onBarcodeDetected)
    }

    @MainActor
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onBarcodeDetected: @MainActor (String) -> Void
        private var hasDetected = false

        init(onBarcodeDetected: @escaping @MainActor (String) -> Void) {
            self.onBarcodeDetected = onBarcodeDetected
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !hasDetected else { return }
            for item in addedItems {
                if case .barcode(let barcode) = item, let value = barcode.payloadStringValue {
                    hasDetected = true
                    dataScanner.stopScanning()
                    onBarcodeDetected(value)
                    return
                }
            }
        }

        func reset() {
            hasDetected = false
        }
    }
}
```

- [ ] **Step 2: Verify iOS build**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Pchook.xcodeproj -scheme Pchook -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add ios/Pchook/Features/Scan/Views/BarcodeScannerView.swift
git commit -m "feat(ios): add BarcodeScannerView with VisionKit DataScanner"
```

---

## Task 7: iOS — `ScanModePicker` component

**Files:**
- Create: `ios/Pchook/Features/Scan/Views/ScanModePicker.swift`

- [ ] **Step 1: Create the mode picker**

Create `ios/Pchook/Features/Scan/Views/ScanModePicker.swift`, styled like the iOS Camera app mode selector:

```swift
import SwiftUI

enum ScanMode: String, CaseIterable {
    case barcode
    case photo

    var label: String {
        switch self {
        case .barcode: "Code-barres"
        case .photo: "Photo"
        }
    }
}

struct ScanModePicker: View {
    @Binding var selectedMode: ScanMode

    var body: some View {
        HStack(spacing: 24) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                } label: {
                    Text(mode.label)
                        .font(.subheadline.weight(selectedMode == mode ? .bold : .regular))
                        .foregroundStyle(selectedMode == mode ? .yellow : .white)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        ScanModePicker(selectedMode: .constant(.barcode))
    }
}
```

- [ ] **Step 2: Verify iOS build**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Pchook.xcodeproj -scheme Pchook -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Commit**

```bash
git add ios/Pchook/Features/Scan/Views/ScanModePicker.swift
git commit -m "feat(ios): add ScanModePicker component"
```

---

## Task 8: iOS — `ScanAPI.analyzeBarcode` + `ScanViewModel.scanBarcode`

**Files:**
- Modify: `ios/Pchook/Features/Scan/ScanAPI.swift`
- Modify: `ios/Pchook/Features/Scan/ScanViewModel.swift`

- [ ] **Step 1: Add `analyzeBarcode` to `ScanAPI`**

In `ios/Pchook/Features/Scan/ScanAPI.swift`, add the supporting types and the `analyzeBarcode` method.

The endpoint returns either 200 (`BookPreview`) or 409 (`DuplicateInfo`). Since `APIClient.postWithStatus` decodes a single generic type `T`, we use a custom `Decodable` enum that branches on the presence of `bookId` (409) vs `previewId` (200):

Add these types outside the `ScanAPI` enum:

```swift
struct AnalyzeIsbnRequest: Encodable, Sendable {
    let isbn: String
}

struct DuplicateInfo: Decodable, Sendable {
    let bookId: String
    let title: String
    let authors: [String]
}

enum AnalyzeIsbnResponseData: Decodable, Sendable {
    case preview(BookPreview)
    case duplicate(DuplicateInfo)

    private enum CodingKeys: String, CodingKey {
        case bookId, previewId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.bookId) {
            self = .duplicate(try DuplicateInfo(from: decoder))
        } else {
            self = .preview(try BookPreview(from: decoder))
        }
    }
}

enum AnalyzeBarcodeResult {
    case preview(BookPreview)
    case duplicate(bookId: String, title: String, authors: [String])
}
```

Add the method inside `enum ScanAPI`:

```swift
    static func analyzeBarcode(isbn: String) async throws -> AnalyzeBarcodeResult {
        let (_, response): (Int, APIResponse<AnalyzeIsbnResponseData>) = try await APIClient.shared.postWithStatus(
            "/books/analyze-isbn",
            body: AnalyzeIsbnRequest(isbn: isbn),
            allowedStatuses: [200, 409]
        )
        switch response.data {
        case .preview(let preview):
            return .preview(preview)
        case .duplicate(let info):
            return .duplicate(bookId: info.bookId, title: info.title, authors: info.authors)
        }
    }
```

This approach requires zero changes to `APIClient`. The `AnalyzeIsbnResponseData` enum auto-detects the response shape based on whether `bookId` or `previewId` is present in the JSON.

- [ ] **Step 2: Add `scanBarcode` to `ScanViewModel`**

In `ios/Pchook/Features/Scan/ScanViewModel.swift`, add the `scanBarcode` method:

```swift
    func scanBarcode(_ isbn: String) {
        step = .scanning
        error = nil

        Task {
            do {
                let result = try await ScanAPI.analyzeBarcode(isbn: isbn)
                switch result {
                case .preview(let preview):
                    self.step = .preview(preview)
                case .duplicate(let bookId, let title, let authors):
                    self.step = .duplicate(bookId: bookId, title: title, authors: authors)
                }
            } catch {
                self.error = reportError(error)
                self.step = .camera
            }
        }
    }
```

- [ ] **Step 3: Verify iOS build**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Pchook.xcodeproj -scheme Pchook -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 4: Commit**

```bash
git add ios/Pchook/Features/Scan/ScanAPI.swift ios/Pchook/Features/Scan/ScanViewModel.swift
git commit -m "feat(ios): add barcode analysis API call and ViewModel method"
```

---

## Task 9: iOS — Integrate mode selector into `ScanFlowView`

**Files:**
- Modify: `ios/Pchook/Features/Scan/ScanFlowView.swift`

- [ ] **Step 1: Add mode state and integrate components**

In `ios/Pchook/Features/Scan/ScanFlowView.swift`:

1. Add `@State private var scanMode: ScanMode = .barcode` alongside existing `@State` properties
2. In the `.camera` case, replace the camera ZStack content to switch between modes
3. Add the `ScanModePicker` above the capture button area
4. In barcode mode, show `BarcodeScannerView` instead of `CameraView`
5. Hide the capture button and photo picker in barcode mode (scanner auto-detects)
6. Add ISBN validation: only 10 or 13 digit strings are valid ISBNs

The `.camera` case should become:

```swift
case .camera:
    ZStack {
        if scanMode == .photo {
            CameraView(onCapture: { data in
                viewModel.capturePhoto(data)
            }, shouldCapture: $shouldCapture)
                .ignoresSafeArea()
            ViewfinderOverlay()
        } else {
            BarcodeScannerView { barcode in
                if isValidISBN(barcode) {
                    viewModel.scanBarcode(barcode)
                } else {
                    viewModel.error = "Ce code-barres n'est pas un ISBN"
                }
            }
            .ignoresSafeArea()
        }

        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .accessibilityIdentifier("scan-close-button")
                Spacer()
            }
            .padding()
            Spacer()
        }

        VStack {
            Spacer()

            ScanModePicker(selectedMode: $scanMode)
                .padding(.bottom, 16)

            if scanMode == .photo {
                HStack {
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(.ultraThinMaterial, in: .circle)
                    }
                    .accessibilityIdentifier("scan-photo-picker")
                    Spacer()
                    Button {
                        shouldCapture = true
                    } label: {
                        Circle()
                            .stroke(.white, lineWidth: 4)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .fill(.white)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    .accessibilityIdentifier("scan-capture-button")
                    Spacer()
                    Color.clear.frame(width: 56, height: 56)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            } else {
                Color.clear.frame(height: 100)
                    .padding(.bottom, 32)
            }
        }
    }
```

Add the ISBN validation helper as a private function:

```swift
private func isValidISBN(_ code: String) -> Bool {
    let digits = code.filter(\.isNumber)
    return digits.count == 10 || digits.count == 13
}
```

- [ ] **Step 2: Verify iOS build**

Run: `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Pchook.xcodeproj -scheme Pchook -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build`
Expected: BUILD SUCCEEDED

- [ ] **Step 3: Run all backend checks to ensure nothing regressed**

Run: `bun tsc --noEmit && bun test && bunx biome check`
Expected: all PASS

- [ ] **Step 4: Commit**

```bash
git add ios/Pchook/Features/Scan/ScanFlowView.swift
git commit -m "feat(ios): integrate barcode scanner mode into ScanFlowView"
```

---

## Planned Commits Summary

1. `feat(scan): add CachedIsbnResult type`
2. `feat(scan): add IsbnScanner namespace for ISBN-based Gemini lookup`
3. `feat(scan): add POST /books/analyze-isbn endpoint with feature test`
4. `refactor(scan): remove OpenLibrary from photo scan pipeline`
5. `refactor(scan): remove OpenLibrary from URL share pipeline`
6. `feat(ios): add BarcodeScannerView with VisionKit DataScanner`
7. `feat(ios): add ScanModePicker component`
8. `feat(ios): add barcode analysis API call and ViewModel method`
9. `feat(ios): integrate barcode scanner mode into ScanFlowView`
