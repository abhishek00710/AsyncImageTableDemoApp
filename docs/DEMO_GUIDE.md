# Demo Guide

Use this flow if you want to explain the project in a quick interview, code review, or architecture walkthrough.

## 1. Start with the user problem

Explain that a long list of remote images should not:

- download all rows at once
- keep every image forever
- continue spending work on rows the user can no longer see

## 2. Run the app

Open the app and highlight:

- 1,000 rows in SwiftUI
- visible-only loading behavior
- live cache summary at the top

## 3. Show slow scrolling

Scroll a little and explain:

- rows start loading only when they appear
- completed images are reused on revisit

## 4. Show fast scrolling

Scroll quickly and explain:

- off-screen rows cancel work
- non-visible rows become eligible for cache eviction

## 5. Open the code

Best order:

1. `Views/PhotoListView.swift`
2. `ViewModels/PhotoRowViewModel.swift`
3. `Services/ImagePipeline.swift`
4. `Services/MemoryImageCache.swift`

## 6. Call out the key concurrency ideas

- `async/await` for remote loading
- actors for shared state
- cancellation tied to row visibility
- a separate policy for visible vs non-visible cached images

## 7. Good follow-up talking points

- how you might add disk caching
- why downsampling large images would help further
- how request prioritization could improve near-visible row loading
- how the memory policy could be tuned for different image sizes
