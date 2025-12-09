# Requirements Document

## Introduction

This feature refactors the dice roll animation system to use Swift Concurrency patterns instead of legacy GCD (DispatchQueue), adds proper cancellation support, and fixes state synchronization issues. The refactoring addresses thread safety concerns, memory leaks, and race conditions in the current implementation while maintaining the same user-facing behavior.

## Glossary

- **Die**: A single six-sided die object that can display pip values 1-6
- **Animation Task**: A Swift Concurrency Task that manages the animation lifecycle
- **Main Actor**: Swift's actor that ensures code runs on the main thread
- **Cancellation**: The ability to stop an in-flight animation before it completes
- **Task Group**: A structured concurrency construct for managing multiple concurrent operations
- **SwiftData Model**: A class marked with @Model that persists to the database
- **Transient Property**: A model property marked with @Transient that is not persisted
- **State Synchronization**: Ensuring UI state accurately reflects the underlying model state
- **DiceSack Application**: The iOS dice rolling utility app

## Requirements

### Requirement 1

**User Story:** As a developer, I want the animation system to use Swift Concurrency, so that the code is thread-safe and follows modern Swift patterns.

#### Acceptance Criteria

1. WHEN a die animates THEN the DiceSack Application SHALL use Task and async/await instead of DispatchQueue
2. WHEN a die is a SwiftData model THEN the DiceSack Application SHALL annotate the Die class with @MainActor
3. WHEN animation state changes occur THEN the DiceSack Application SHALL ensure all property access happens on the main actor
4. WHEN multiple dice animate simultaneously THEN the DiceSack Application SHALL use withTaskGroup for coordination
5. WHEN animation timing is needed THEN the DiceSack Application SHALL use Task.sleep with Duration instead of DispatchQueue.asyncAfter

### Requirement 2

**User Story:** As a developer, I want animations to be cancellable, so that memory leaks and unexpected behavior are prevented when views disappear.

#### Acceptance Criteria

1. WHEN a die starts animating THEN the DiceSack Application SHALL store the animation task in a transient property
2. WHEN a new animation starts on a die THEN the DiceSack Application SHALL cancel any existing animation task
3. WHEN a die view disappears THEN the DiceSack Application SHALL cancel the die's animation task
4. WHEN an animation is cancelled THEN the DiceSack Application SHALL set isAnimating to false immediately
5. WHEN an animation task is cancelled THEN the DiceSack Application SHALL check Task.isCancelled and exit early

### Requirement 3

**User Story:** As a developer, I want state synchronization to be correct, so that button states accurately reflect whether dice are animating.

#### Acceptance Criteria

1. WHEN checking if any die is animating THEN the DiceSack Application SHALL compute the result from the dice array
2. WHEN the ContentView tracks animation state THEN the DiceSack Application SHALL not maintain duplicate state variables
3. WHEN a die's isAnimating property changes THEN the DiceSack Application SHALL trigger SwiftUI view updates automatically
4. WHEN all dice complete animation THEN the DiceSack Application SHALL re-enable buttons without manual state management
5. WHEN the computed property isAnyDieAnimating is accessed THEN the DiceSack Application SHALL return true if and only if at least one die has isAnimating equal to true

### Requirement 4

**User Story:** As a developer, I want the DiceGroup to coordinate animations properly, so that completion is tracked without race conditions.

#### Acceptance Criteria

1. WHEN rolling all dice with animation THEN the DiceSack Application SHALL use withTaskGroup to manage concurrent animations
2. WHEN all dice animations complete THEN the DiceSack Application SHALL return from the async method automatically
3. WHEN tracking animation completion THEN the DiceSack Application SHALL not use shared mutable counters
4. WHEN locked dice are present THEN the DiceSack Application SHALL only animate unlocked dice
5. WHEN the rollAllWithAnimation method completes THEN the DiceSack Application SHALL guarantee all dice have isAnimating equal to false

### Requirement 5

**User Story:** As a developer, I want proper memory management, so that animations don't cause retain cycles or leaks.

#### Acceptance Criteria

1. WHEN storing animation tasks THEN the DiceSack Application SHALL mark the animationTask property as @Transient
2. WHEN an animation task references self THEN the DiceSack Application SHALL use weak captures where appropriate
3. WHEN a die is deallocated THEN the DiceSack Application SHALL not prevent deallocation due to strong reference cycles
4. WHEN an animation completes THEN the DiceSack Application SHALL clean up the animation task reference
5. WHEN cancelling an animation THEN the DiceSack Application SHALL set the animationTask property to nil

### Requirement 6

**User Story:** As a user, I want the animation behavior to remain unchanged, so that the refactoring doesn't affect my experience.

#### Acceptance Criteria

1. WHEN the user taps Roll THEN the DiceSack Application SHALL animate unlocked dice with the same visual effect as before
2. WHEN dice animate THEN the DiceSack Application SHALL use randomized start delays between 0 and 0.25 seconds
3. WHEN dice animate THEN the DiceSack Application SHALL use randomized durations between 0.5 and 1.0 seconds
4. WHEN dice animate THEN the DiceSack Application SHALL cycle through 10 random pip values before settling
5. WHEN animations are in progress THEN the DiceSack Application SHALL disable Roll and End Turn buttons as before
