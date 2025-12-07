## Project Structure

```
DiceSack/
├── DiceSackApp.swift          # App entry point with SwiftData model container
├── ContentView.swift          # Main view with dice grid and controls
├── DieView.swift              # Individual die component with pip rendering
├── RollHistoryView.swift      # Sheet view for viewing past rolls
├── Models.swift               # Data models (Die, DiceGroup)
└── Assets.xcassets/           # App icons and color assets
```

## Architecture Patterns

- SwiftUI declarative UI with `@State` and `@Environment` for state management
- SwiftData `@Model` classes for persistence with `@Relationship` cascade deletes
- View composition: reusable `DieView` component used in both main and history views
- Model layer separates business logic (rolling, locking) from presentation

## Code Conventions

- File headers include creation date and author
- Models use `private(set)` for controlled mutation
- `#if DEBUG` blocks provide example instances for previews
- SwiftUI previews included for all views
- Explicit initialization with default parameters for view components
- Guard statements for early returns (e.g., locked dice can't roll)
