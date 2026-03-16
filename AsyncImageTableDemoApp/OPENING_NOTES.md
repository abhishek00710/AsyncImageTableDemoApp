# Opening Notes

Open `AsyncImageTableDemo.xcodeproj` in Xcode and run the `AsyncImageTableDemo` scheme.

## What to look for in the simulator

- Scrolling does not start all 1,000 image downloads at once
- Images appear only for rows that become visible
- Fast scrolling cancels work for cells that leave the screen
- Returning to recently viewed rows often reuses cached images immediately
- The navigation prompt shows rough cache/visibility stats in real time

## Best files to read first

- `AsyncImageTableDemo/Views/PhotoListView.swift`
- `AsyncImageTableDemo/ViewModels/PhotoRowViewModel.swift`
- `AsyncImageTableDemo/Services/ImagePipeline.swift`
- `AsyncImageTableDemo/Services/MemoryImageCache.swift`
