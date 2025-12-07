# Implementation Plan

- [ ] 1. Add animation state to Die model
  - Add `isAnimating` boolean property to `Die` class
  - Ensure `isAnimating` is not persisted to SwiftData (transient state only)
  - Add `animateRoll(completion:)` method with random delay and duration
  - _Requirements: 1.1, 1.3, 1.4_

- [ ]* 1.1 Write property test for animation state transitions
  - **Property 2: Animation completion means settled state**
  - **Validates: Requirements 1.3**

- [ ]* 1.2 Write property test for locked dice behavior
  - **Property 1: Only unlocked dice animate**
  - **Validates: Requirements 1.1, 1.4**

- [ ] 2. Implement animation coordination in DiceGroup
  - Add `rollAllWithAnimation(completion:)` method to `DiceGroup`
  - Coordinate animation start across all unlocked dice
  - Track completion of all individual die animations
  - Call completion handler when all dice finish
  - _Requirements: 1.1, 1.5_

- [ ]* 2.1 Write property test for group animation completion
  - **Property 3: All animations complete means no dice animating**
  - **Validates: Requirements 1.5**

- [ ] 3. Update DieView to display animating pip values
  - Modify `DieView` to observe die's pip value changes during animation
  - Apply SwiftUI `.easeOut` animation to pip transitions
  - Ensure view updates smoothly as pip values change
  - _Requirements: 1.2_

- [ ] 4. Add animation state tracking to ContentView
  - Add computed property or state to track if any die is animating
  - Update `rollAll()` to use `rollAllWithAnimation` instead of `rollAll()`
  - _Requirements: 1.1, 3.1, 3.2_

- [ ] 5. Implement button state management
  - Disable Roll button when any die is animating
  - Disable End Turn button when any die is animating
  - Apply dimmed visual state to disabled buttons
  - Re-enable buttons when all animations complete
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ]* 5.1 Write property test for button state logic
  - **Property 4: Buttons disabled if and only if any die animating**
  - **Validates: Requirements 3.1, 3.2, 3.4**

- [ ] 6. Block dice interactions during animation
  - Modify tap gesture handling in `ContentView` to check animation state
  - Prevent `toggleLock()` calls on any die while animations are active
  - _Requirements: 3.5_

- [ ]* 6.1 Write property test for lock toggle blocking
  - **Property 5: Animating dice ignore lock toggles**
  - **Validates: Requirements 3.5**

- [ ] 7. Ensure SwiftData persistence compatibility
  - Verify `isAnimating` is not included in SwiftData schema
  - Test that persisting during animation doesn't cause issues
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
