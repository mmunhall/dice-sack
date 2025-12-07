# Implementation Plan

- [x] 1. Add animation state and timing to Die model
  - Add `isAnimating` boolean property to `Die` class (transient, not persisted)
  - Add `animateRoll(completion:)` method that:
    - Generates random start delay (0-0.25s) and duration (0.5-1.0s)
    - Sets `isAnimating = true` at start
    - Cycles through random pip values during animation
    - Sets `isAnimating = false` and calls completion when done
  - Ensure `isAnimating` is marked as transient for SwiftData (use `@Transient` attribute)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2_

- [ ]* 1.1 Write property test for animation state transitions
  - **Property 2: Animation completion means settled state**
  - **Validates: Requirements 1.3**

- [ ]* 1.2 Write property test for locked dice behavior
  - **Property 1: Only unlocked dice animate**
  - **Validates: Requirements 1.1, 1.4**

- [x] 2. Implement animation coordination in DiceGroup
  - Add `rollAllWithAnimation(completion:)` method to `DiceGroup`
  - Start all unlocked dice animations simultaneously (delays handled per-die)
  - Track completion of all individual die animations
  - Call completion handler only when all dice finish animating
  - _Requirements: 1.1, 1.5, 2.3_

- [ ]* 2.1 Write property test for group animation completion
  - **Property 3: All animations complete means no dice animating**
  - **Validates: Requirements 1.5**

- [ ] 3. Update DieView to animate pip value changes
  - Add `.animation(.easeOut, value: die.value)` modifier to pip rendering
  - Ensure view reactively updates as die's value changes during animation
  - Test that pip transitions are smooth and visible
  - _Requirements: 1.2, 2.5_

- [ ] 4. Add animation state tracking to ContentView
  - Add computed property `isAnyDieAnimating` that checks if any die in `diceGroup.dice` has `isAnimating = true`
  - Update `rollAll()` to call `diceGroup.rollAllWithAnimation(completion:)` instead of `diceGroup.rollAll()`
  - In completion handler, trigger view update to re-enable buttons
  - _Requirements: 1.1, 3.1, 3.2_

- [ ] 5. Implement button state management during animation
  - Disable Roll button when `isAnyDieAnimating` is true
  - Disable End Turn button when `isAnyDieAnimating` is true
  - Apply `.opacity(0.5)` or similar dimmed visual state to disabled buttons
  - Ensure buttons re-enable automatically when all animations complete
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ]* 5.1 Write property test for button state logic
  - **Property 4: Buttons disabled if and only if any die animating**
  - **Validates: Requirements 3.1, 3.2, 3.4**

- [ ] 6. Block dice lock interactions during animation
  - Modify `DieView` tap gesture to check if die is animating before calling `onTap()`
  - Alternatively, modify `ContentView` to pass no-op closure when `isAnyDieAnimating` is true
  - Verify that tapping animating dice has no effect on lock state
  - _Requirements: 3.5_

- [ ]* 6.1 Write property test for lock toggle blocking
  - **Property 5: Animating dice ignore lock toggles**
  - **Validates: Requirements 3.5**

- [ ] 7. Verify SwiftData persistence compatibility
  - Confirm `isAnimating` is marked as `@Transient` and not persisted
  - Test that calling `endTurn()` (which persists via `modelContext.insert()`) works correctly
  - Verify no crashes or data corruption when persisting dice
  - _Requirements: 4.3_

- [ ]* 7.1 Write property test for persistence during animation
  - **Property 6: Persistence doesn't interfere with animation**
  - **Validates: Requirements 4.3**

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 9. Performance testing with multiple dice
  - Test animation smoothness with 6 dice (current count)
  - Test animation smoothness with 50+ dice (future scalability)
  - Profile frame rates and identify any performance bottlenecks
  - _Requirements: 4.1, 4.2_

- [ ]* 10. Integration testing
  - Test complete roll flow: button tap → animation → settled → buttons enabled
  - Test rapid button taps to ensure proper state management
  - Test mixed locked/unlocked dice scenarios
  - _Requirements: 1.1, 1.3, 1.4, 1.5, 3.1, 3.2, 3.4, 3.5_
