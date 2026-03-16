# Cache And Memory Behavior

This document explains how memory is managed in the async image-loading sample.

## Configured cache budget

The app creates `MemoryImageCache` with a budget of roughly 28 MB.

That budget is used as the base value for cache trimming behavior.

## What gets cached

The cache stores:

- decoded `UIImage` instances
- an approximate memory cost for each image
- recent access order
- whether the image currently belongs to a visible row

## When images become eligible for eviction

An image becomes a candidate for release when:

- its row disappears from the visible SwiftUI list
- the cache is over its trimming target
- a memory warning arrives

Visible images are intentionally treated differently from non-visible images.

## Eviction policy

The cache prefers to remove:

1. non-visible images first
2. older entries before newer ones

That means rows currently visible on screen are protected as much as possible.

## When trimming runs

Trimming is triggered when:

- a new image is inserted into cache
- a row becomes non-visible
- the app receives a memory warning

## Important practical note

No iOS app gets a single universal fixed memory allowance from the system. The operating system can pressure or terminate an app based on device conditions, other running apps, image sizes, and current memory state.

So in this sample:

- the cache budget is an app-level policy
- it is not a guarantee from iOS
- the app uses that policy to keep memory under better control before the system has to intervene

## Why this matters

Without trimming, a long-scrolling image list can easily keep too many decoded images alive. That often leads to:

- higher memory usage
- less predictable performance
- more frequent app termination under pressure

This sample is designed to show a safer baseline approach.
