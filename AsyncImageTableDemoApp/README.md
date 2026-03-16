# Async Image Table Demo

This sample app demonstrates a practical async/await image-loading architecture for a large SwiftUI `List`.

## What it shows

- 1,000 SwiftUI rows with deterministic remote image URLs
- image downloads that begin only for visible rows
- cancellation when cells leave the screen
- in-flight request coalescing so duplicate downloads are avoided
- actor-backed in-memory caching
- visibility-aware eviction when cache memory exceeds a configured budget

## Architecture

- `PhotoRowView` and `PhotoRowViewModel` start work in `onAppear` and cancel it in `onDisappear`
- `ImagePipeline` is an actor that coordinates cache reads and in-flight downloads
- `MemoryImageCache` is an actor that protects visible images and evicts old off-screen images first

## Teaching angle

This project is useful for demonstrating that async/await image loading is not just about "fetch data and set image". A production-shaped solution also needs:

- cancellation
- cell reuse protection
- in-flight task deduplication
- cache trimming under memory pressure
