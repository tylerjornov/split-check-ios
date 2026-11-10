# Split Check iOS

Native SwiftUI iOS app to split restaurant checks fairly — inspired by [this concept](https://x.com/benlouisx/status/2119196838159122553).

Tap a person, then tap the items they had. Shared items split equally. Tax and tip are split proportionally based on what each person ordered.

## Features

- Clean native iOS UI matching the concept
- Assign items to people with one tap
- Automatic equal split for shared dishes
- Proportional tax & tip
- Live totals
- Sample Lucia Trattoria receipt

## How to run

1. Create a new SwiftUI iOS App project in Xcode (named SplitCheck or anything).
2. Delete the default `ContentView.swift`.
3. Drag these files into the project:
   - `SplitCheckApp.swift` (replace the existing App file if needed)
   - `Models.swift`
   - `ContentView.swift`
4. Build and run on simulator or device (iOS 17+).

Or open the files and copy into your project.

## License

MIT
