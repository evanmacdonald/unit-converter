# GPS Unit Converter — Project Context

## Overview

Single-page SwiftUI iOS app that converts GPS coordinates between 6 formats (DD, DDM, DMS, UTM, MGRS, Plus Codes). Full CI/CD pipeline deploys to TestFlight on every PR and App Store on demand.

## Project Status

### Merged

- **PR #1**: Xcode project skeleton + GitHub Actions CI (build + test on PR)
- **PR #2**: DD, DDM, DMS coordinate converters with TDD (23 tests)
- **PR #3**: Full CI/CD pipeline — fastlane, TestFlight on PR, App Store manual deploy
- **PR #4**: UTM + MGRS converters (TDD) — transverse Mercator projection math
- **PR #5**: Plus Codes / Open Location Code converter (TDD) — full codes only in v1, 18 tests
- **PR #6**: UI + ViewModel — format picker, input field, output rows with copy buttons
- **PR #6a**: Clear/reset button — toolbar button resets all converter state

### Remaining (in order)
- **PR #7**: Polish + App Store metadata, re-enable auto App Store deploy

## Architecture

- **Canonical model**: `Coordinate(latitude: Double, longitude: Double)` in decimal degrees
- **Protocol**: `CoordinateConverter` with `parse(_:) -> Coordinate?` and `format(_:) -> String`
- **Each format** has its own converter enum conforming to the protocol
- **SwiftUI** with `@Observable` (iOS 17+), **XCTest** for unit tests

## Development Workflow

- **TDD**: Write failing tests first (RED), then implement (GREEN)
- **PR-based**: All code submitted as PRs for review
- **CI on PR**: GitHub Actions builds, runs tests, deploys to TestFlight
- **App Store**: `release.yml` is manual-only (`workflow_dispatch`) until ready for production

## CI/CD Pipeline

### Workflows

| Trigger | Workflow | What happens |
|---|---|---|
| PR to main | `pr.yml` | Build + test + deploy to TestFlight |
| Manual (Actions tab) | `release.yml` | Deploy to App Store |

To re-enable auto App Store deploy, change `release.yml` trigger from `workflow_dispatch` to `push: branches: [main]`.

### GitHub Secrets Required

| Secret | Purpose |
|---|---|
| `MATCH_PASSWORD` | Decrypt certificates in private repo |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 `username:PAT` for cloning certs repo |
| `ASC_KEY_ID` | App Store Connect API Key ID |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID |
| `ASC_KEY_CONTENT` | Base64-encoded .p8 private key |

### Code Signing

- **fastlane match** with encrypted cert repo: `github.com/evanmacdonald/ios-certificates` (private)
- Debug: automatic signing (local dev)
- Release: manual signing with match provisioning profile (CI)
- Build numbers: `GITHUB_RUN_NUMBER` (monotonically increasing)

## Project Structure

```
UnitConverter/
  UnitConverterApp.swift          # @main entry point
  ContentView.swift               # Single-page UI (placeholder, built in PR #6)
  Assets.xcassets/                # App icon
  Models/
    Coordinate.swift              # Canonical lat/lon model
    CoordinateFormat.swift        # Enum of 6 formats
  Converters/
    CoordinateConverter.swift     # Protocol
    DDConverter.swift             # Decimal Degrees
    DDMConverter.swift            # Degrees Decimal Minutes
    DMSConverter.swift            # Degrees Minutes Seconds
    UTMConverter.swift            # Universal Transverse Mercator
    MGRSConverter.swift           # Military Grid Reference System
    PlusCodeConverter.swift       # Open Location Code (Plus Codes)
UnitConverterTests/
  Converters/
    DDConverterTests.swift
    DDMConverterTests.swift
    DMSConverterTests.swift
    UTMConverterTests.swift
    MGRSConverterTests.swift
    PlusCodeConverterTests.swift
.github/workflows/
  pr.yml                          # Build + test + TestFlight
  release.yml                     # App Store (manual trigger)
fastlane/
  Fastfile                        # test, beta, release lanes
  Appfile                         # Bundle ID, team ID
  Matchfile                       # Certs repo URL
```

## Local Development

```bash
# Build and run in simulator
xcrun simctl boot "iPhone 17"
open -a Simulator
xcodebuild build -project UnitConverter.xcodeproj -scheme UnitConverter \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/UnitConverter-*/Build/Products/Debug-iphonesimulator/UnitConverter.app
xcrun simctl launch booted com.evanmacdonald.unit-converter

# Run tests
xcodebuild test -project UnitConverter.xcodeproj -scheme UnitConverter \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO
```

## Key Design Decisions

| Decision | Choice | Why |
|---|---|---|
| Project type | Xcode .xcodeproj | Most portable, produces signable .app |
| State management | `@Observable` (iOS 17+) | Modern pattern, no `@Published` boilerplate |
| Code signing (CI) | fastlane match | Certs in Git, works across machines |
| Build numbers | `GITHUB_RUN_NUMBER` | Monotonically increasing, no manual management |
| Plus Codes | Full codes only in v1 | Short codes need geocoding — add later |
| UTM/MGRS | Pure Swift | No external dependencies |

## Reproducing This Pipeline for New Projects

1. Copy `.github/workflows/`, `fastlane/`, and `Gemfile` to new project
2. Update `fastlane/Appfile` (bundle ID, team ID)
3. Update `fastlane/Matchfile` (app_identifier)
4. Update `fastlane/Fastfile` (project/scheme names, provisioning profile name)
5. Register new bundle ID at developer.apple.com
6. Create app record in App Store Connect
7. Run `fastlane match appstore` to generate profile for the new app
8. Set GitHub Secrets on the new repo
