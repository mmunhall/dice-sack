# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dice Sack is an iOS dice rolling application built with SwiftUI and SwiftData. It allows users to roll multiple dice, lock individual dice between rolls, and view roll history.

## Build & Development Commands

### Building and Running
- Open the project in Xcode: `open DiceSack.xcodeproj`
- Build: `xcodebuild -scheme DiceSack -configuration Debug build`
- Run in simulator: Open Xcode and use Cmd+R, or select a simulator via the Xcode GUI
- Clean build folder: `xcodebuild clean -scheme DiceSack`

### Testing
This project does not currently have a test suite configured.

## Architecture

### Data Model (SwiftData)
The app uses SwiftData for persistence with two core models defined in `Models.swift`:

- **Die** (`@Model`): Represents a single die
  - Properties: `id`, `sides`, `value`, `locked` (all private(set) except id)
  - Key behavior: `roll()` only works if die is not locked
  - Locking: `toggleLock()` allows users to keep specific dice between rolls

- **DiceGroup** (`@Model`): Represents a collection of dice from a single turn
  - Has cascade delete relationship to dice
  - Stores `date` for history tracking
  - `rollAll()` rolls all unlocked dice in the group

### View Architecture
The app follows standard SwiftUI patterns with environment-based data flow:

- **DiceSackApp.swift**: App entry point, sets up `.modelContainer(for: DiceGroup.self)` for SwiftData
- **ContentView.swift**: Main rolling interface
  - Uses `@Environment(\.modelContext)` to access SwiftData
  - Manages current `diceGroup` state
  - `endTurn()` saves the current group to history via `modelContext.insert()`
  - Green felt background for dice table aesthetic

- **DieView.swift**: Individual die rendering
  - Custom die face drawing using positioned Circles (1-6 pips)
  - Visual feedback: locked dice appear gray, unlocked appear white
  - Tap gesture toggles lock state via `die.toggleLock()`
  - Contains unused timer-based animation code for rolling effect

- **RollHistoryView.swift**: Sheet view showing past rolls
  - Uses `@Query(sort: \DiceGroup.date, order: .reverse)` to fetch history
  - Displays all past DiceGroups in a grid
  - "Clear history" button deletes all rolls from SwiftData

### Key Patterns

**State Management**: The app uses a hybrid approach:
- SwiftData models (`Die`, `DiceGroup`) for persistent data
- `@State` in views for transient UI state (e.g., `showingHistory`)
- `@Environment(\.modelContext)` for database operations

**Data Flow**:
1. User rolls dice → `rollAll()` updates Die values
2. User ends turn → `endTurn()` inserts DiceGroup into modelContext
3. History view queries all DiceGroups via `@Query` macro

**UI Composition**: Each die is individually interactive (can be locked) while the main "Roll" button triggers group behavior via `diceGroup.rollAll()`

## Project Configuration

- **Target**: iOS 18.5+
- **Swift Version**: 5.0
- **Bundle ID**: dev.unrequited.DiceSack
- **Development Team**: UD788QN6R5
- **Supported Devices**: iPhone and iPad (TARGETED_DEVICE_FAMILY = "1,2")
- **Previews**: Enabled for SwiftUI previews
