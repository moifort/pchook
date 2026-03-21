# Project Directives

## Build & Verification Commands

- **Backend typecheck**: `bun tsc --noEmit`
- **Regenerate types** (if routes changed): `bunx nitro prepare` (run before `bun tsc`)
- **iOS build**:
  ```
  DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -project ios/Pchook.xcodeproj -scheme Pchook -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' build
  ```
- **Unit tests**: `bun test`
- **Test coverage**: `bun test --coverage`
- **Linter**: `bunx biome check`
- **Runtime**: always use `bun`/`bunx`, never `npm`/`npx`

## Development Workflow

1. Always verify the build before committing (backend `bun tsc --noEmit` + `xcodebuild` depending on what was touched)
2. Run `bunx nitro prepare` before `bun tsc` if routes were added/modified
3. Run tests before committing: `bun test`
4. Run `bunx biome check --write` to auto-fix formatting and lint
5. Fix remaining lint errors. `biome-ignore` is exceptional — only when justified, with an explanation in the comment

## Commit Strategy

- **Conventional Commits**: `type(scope): description` — types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`
- **Scopes**: domain name for business changes (`feat(book): ...`, `feat(review): ...`), technical name otherwise (`fix(migration): ...`, `chore(deps): ...`). Omit scope if too broad
- **Commit after each verified task**: all checks pass (build + tests + lint) before committing
- **Fine granularity, functional coherence**: each commit = one logical change. Small enough to identify bugs via `git bisect` or commit history, but coherent enough to stand on its own

## Backend Patterns (TypeScript/Nitro)

- Domain architecture: `server/domain/{domain}/types.ts`, `primitives.ts`, `repository.ts`, `command.ts`, `query.ts`
- **`business-rules.ts`** (optional): pure functions (no IO, no async) extracted from complex commands. Function names ARE the business concept (`wineStatus`, `readyToDrink` — never `computeX`, `getX`, `calculateX`). Must have 100% test coverage (`business-rules.unit.test.ts`)
- **`use-case.ts`** (optional): multi-domain orchestrations when a route needs to coordinate several commands/queries. Names carry business intent (`addWithTasting`, `removeCompletely` — never `handleX`, `processX`). No direct storage access.
- **Read models**: `server/read-model/{domain}/` — composite views assembling multiple domains for display needs. Mirror the `domain/` structure. Only import public Query/Command namespaces, never repositories.
- Branded types with `ts-brand` + Zod validation constructors in `primitives.ts`
- Discriminated unions for expected business outcomes only (not technical errors). `throw` for impossible states (incoherent data → 500 + alert)
- File-based storage: `useStorage('namespace')`
- **Naming**: function names carry the business concept, not the technical pattern. The name IS the rule or action.
- **BDD DSL**: `server/test/bdd.ts` — `feature()`, `scenario()`, `given()`, `when()`, `then()`, `and()` over `bun:test`. Feature tests use `.feat.test.ts` suffix.
- Formatter: Biome (spaces, single quotes, no semicolons, line width 100)
- **External API files**: `server/domain/{domain}/{api-name}.api.ts` — isolate SDK/HTTP calls + response validation. Returns typed data or throws. Symmetric test: `{api-name}.api.int.test.ts`
- Logging: `createLogger(tag)` from `~/system/logger` — never use raw `console.log/error`

See [docs/architecture.md](docs/architecture.md) for full architecture overview.
See [docs/domain-guide.md](docs/domain-guide.md) for step-by-step domain creation.

## Backend Testing

- **Framework**: `bun:test` (native, zero dependencies)
- **Test files co-located** next to the file under test (no `__test__/` directories)
- **Suffixes** (highest to lowest level):
  - `*.feat.test.ts` — feature tests (business scenarios at route level)
  - `*.int.test.ts` — integration tests (domain queries/commands, with mocked storage IO)
  - `*.unit.test.ts` — unit tests (primitives, pure functions without IO)
- **Infrastructure**: `server/test/setup.ts` (mock useStorage in-memory) + preloaded via `bunfig.toml`
- **Coverage**: `bun test --coverage`

## Database Migrations

- Location: `server/system/migration/`
- Forward-only sequential migrations, no rollback
- Meta tracked in `useStorage('migration-meta')` (key `state`)
- Nitro plugin (`server/plugins/migration.ts`) runs migrations at boot, `process.exit(1)` on failure
- To add a migration: create `server/system/migration/migrations/NNNN-name.ts`, register in `migrations/index.ts`

See [docs/migrations.md](docs/migrations.md) for full guide.

## iOS Patterns (SwiftUI)

- Target: iOS 26.0, Swift 6 (strict concurrency)
- `@MainActor` on ViewModels, `Sendable` on model types
- Feature structure: `ios/Pchook/Features/{Feature}/` with `atoms/`, `molecules/`, `organisms/`, `pages/` subdirectories
- Shared atoms: `ios/Pchook/Shared/Components/` — cross-feature reusable views (badges, ratings, labeled rows)
- **Primitive-first views**: leaf views receive only primitives (`String`, `Int`, `Bool`, `Date?`, simple enums, closures) — never domain structs. Use nested `Item` structs for 5+ parameters
- **Previews as Storybook**: every component must be previewable in isolation without a running server. Pages (coordinators) are the exception
- Xcode uses `fileSystemSynchronizedGroups` (no need to manually add files)
- `DEVELOPER_DIR` required because `xcode-select` may point to CommandLineTools
- **Image generation**: use the `/image-gen` skill to generate iOS app icons or any other image assets. Use the same icon for both iOS and CasaOS

See [docs/ios-guide.md](docs/ios-guide.md) for full iOS guide.

## Code Style

- **Never type return values** — let TypeScript infer
- **Full variable names** — `migration` not `m`
- **Destructure in callbacks** — `({ version }) => version`
- **Inline single-line guards** — `if (...) return ...` on one line
- **`as const` on all literal returns**
- **Use `Date` type** — not `string` for dates
- **Use lodash-es** — `sortBy`, `keyBy`, `uniq` with destructured callbacks
- **Never `switch`** — use `match()` from `ts-pattern` with `.exhaustive()`
- **Never `for`/`while` loops** — use `map`/`filter`/`reduce`, chaining, and lodash-es utilities for readability
- **Arrays never optional** — `[]` is the neutral state, never `null`/`undefined`/`nil`

See [docs/code-style.md](docs/code-style.md) for full rules with examples.

## API Keys & Token

The API token is used for authentication when `NITRO_API_TOKEN` is set. To rotate the token, update it in:
- `.env` (`NITRO_API_TOKEN=...`)
- `ios/Pchook/Shared/Secrets.swift` (gitignored)
- `ios/PchookUITests/Support/TestSecrets.swift` (gitignored)

See `.example` files next to the Secrets files for the expected format.

External API keys required for book scanning and suggestion generation:
- `NITRO_ANTHROPIC_API_KEY` — Claude API key for cover image analysis (vision)
- `NITRO_GOOGLE_API_KEY` — Gemini API key for book data enrichment and suggestion generation
- `NITRO_HARDCOVER_API_TOKEN` — Hardcover API token for community ratings and cover images (get from hardcover.app > Settings > API)
