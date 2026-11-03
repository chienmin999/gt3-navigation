<!--
Sync Impact Report:
- Version change: Initial scaffold -> 1.0.0
- Principles defined:
  1. Clean Architecture & Layer Decoupling
  2. Native Android 13+ & Modern Jetpack Ecosystem
  3. AndroidX Media3 (ExoPlayer) Video Streaming
  4. Resilient Source Parsing & Stream Extraction
  5. Critical-Path Testing
- Sections defined: Technology Stack & Constraints, Development Workflow & Quality Gates, Governance
-->

# HH3D Android Constitution

## Core Principles

### I. Clean Architecture & Layer Decoupling
The application MUST strictly adhere to Clean Architecture with three isolated layers:
- **Presentation Layer**: Built with Jetpack Compose, ViewModels, and StateFlow. Responsible solely for UI rendering and capturing user interactions.
- **Domain Layer**: Pure Kotlin business logic containing UseCases, Domain Models, and Repository Interfaces. Free from Android framework dependencies.
- **Data Layer**: Contains Repository implementations, Remote Data Sources (HTML parsers / stream resolvers via Jsoup & OkHttp), and Local Data Sources (Room DB).
- **Dependency Rule**: Dependencies flow inward. Presentation and Data depend on Domain; Domain depends on nothing external.

### II. Native Android 13+ & Modern Jetpack Ecosystem
- The codebase MUST be 100% Kotlin utilizing Coroutines and Flow for asynchronous operations.
- UI MUST be built natively with Jetpack Compose and Material 3, optimized for Android 13 (API level 33) and above.
- Dependency Injection MUST be managed centrally using Dagger Hilt.

### III. AndroidX Media3 (ExoPlayer) Video Streaming
- Video playback MUST be powered by `androidx.media3:media3-exoplayer` and `media3-ui`.
- Media player lifecycle MUST be strictly tied to Activity/Compose lifecycles (proper prepare, pause, buffer handling, release on teardown).
- Controls MUST provide a modern player experience (play/pause, timeline scrubber, quality selection, fullscreen toggle, speed adjustments).

### IV. Resilient Source Parsing & Stream Extraction
- Web scraping and link extraction from sources (such as yanhh3d) MUST be encapsulated inside dedicated Remote Data Sources.
- The extraction engine MUST handle network timeouts, anti-scraping headers, DOM mutations, and malformed links gracefully with typed Result/Domain error wrapping.
- Direct video streaming URLs (m3u8/mp4) MUST be validated before delegating to the media player.

### V. Critical-Path Testing
- Testing MUST focus on critical operational paths:
  - Unit tests for all Domain UseCases and business logic.
  - Unit/Contract tests for HTML parsers and video link extractors.
  - Repository data mapping and Room database migrations/DAO tests.
- UI components and boilerplate wiring are exempt from mandatory unit tests unless regression-prone.

## Technology Stack & Constraints

- **Platform Target**: Android (minSdkVersion: 26, targetSdkVersion: 33+)
- **Language**: Kotlin
- **UI Toolkit**: Jetpack Compose, Material 3, Accompanist / Navigation Compose
- **Media Engine**: AndroidX Media3 (ExoPlayer, HLS, UI)
- **Dependency Injection**: Dagger Hilt
- **Asynchronous / State**: Kotlin Coroutines, StateFlow, SharedFlow
- **Network & Parsing**: OkHttp 4.x, Jsoup
- **Local Persistence**: Room Database (SQLite)
- **Image Loading**: Coil (Compose)

## Development Workflow & Quality Gates

- **Spec-Driven Process**: Every feature cycle begins with specification (`/speckit-specify`), architectural planning (`/speckit-plan`), task breakdown (`/speckit-tasks`), and implementation (`/speckit-implement`).
- **Review Gates**: No code shall bypass Clean Architecture boundaries or introduce domain leaks.
- **Critical Path Verification**: Any change to parser logic or data mapping MUST verify parser tests against real/mocked payloads.

## Governance

This Constitution serves as the single source of truth for architectural standards, code quality, and technical boundaries across the HH3D Android project. Any amendment requires rationale documentation and a semantic version bump.

**Version**: 1.0.0 | **Ratified**: 2026-11-03 | **Last Amended**: 2026-11-03
