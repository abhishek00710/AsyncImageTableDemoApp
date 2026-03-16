# Architecture

This project demonstrates async image loading in SwiftUI with a small but production-shaped architecture.

## Goals

The sample is designed to show how to combine:

- SwiftUI row visibility
- `async/await`
- actor-based shared state
- memory-aware caching
- task cancellation

## Layers

### 1. SwiftUI Views

Files:

- `AsyncImageTableDemoApp/Views/PhotoListView.swift`
- `AsyncImageTableDemoApp/Views/PhotoRowView.swift`

Responsibilities:

- render the 1,000-row list
- reflect loading, loaded, and failed states
- trigger row lifecycle with `onAppear` and `onDisappear`
- surface cache stats in the navigation bar

### 2. Row View Model

File:

- `AsyncImageTableDemoApp/ViewModels/PhotoRowViewModel.swift`

Responsibilities:

- own the per-row task
- start loading when the row appears
- cancel loading when the row disappears
- prevent stale async completions from mutating the wrong UI state

### 3. Image Pipeline Actor

File:

- `AsyncImageTableDemoApp/Services/ImagePipeline.swift`

Responsibilities:

- check cache before downloading
- deduplicate concurrent requests for the same URL
- update cache visibility state
- centralize access to the fetcher and cache

### 4. Memory Cache Actor

File:

- `AsyncImageTableDemoApp/Services/MemoryImageCache.swift`

Responsibilities:

- store images in memory
- track which URLs are currently visible
- prefer keeping visible images over non-visible ones
- evict older non-visible images when memory grows beyond the target

## Row lifecycle

1. `PhotoRowView` appears
2. `PhotoRowViewModel.onAppear()` starts a task
3. `ImagePipeline` returns a cached image or starts/joins an in-flight request
4. The image is rendered in the row
5. When the row disappears, `onDisappear()` cancels the task and marks the URL non-visible
6. The cache may evict that image later if memory pressure requires it

## Why actors are used here

The cache and pipeline both manage mutable shared state:

- cached image entries
- visibility state
- in-flight task dictionary
- total cache cost

Using actors keeps this shared state isolated and makes concurrent access much easier to reason about.
