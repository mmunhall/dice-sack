# Design Document: Dice Roll Animation

## Overview

This feature adds slot machine-style animation to dice rolls using SwiftUI's native animation capabilities. Each die will animate through random pip values with randomized timing (start delay and duration) to create a natural, staggered rolling effect. The design prioritizes simplicity by leveraging SwiftUI's built-in animation system rather than custom animation engines.

The animation system will be architected to scale to 50+ dice while maintaining smooth performance. During animation, all user interactions with dice and control buttons will be disabled to prevent state conflicts.

## Architecture

### Animation State Management

The animation state will be managed at the die level using SwiftUI's `@State` and observable patterns:

- Each `Die` model will track whether it is currently animating
- The `ContentView` will observe animation states to control button availability
- Animation triggers will flow from user action (Roll button) → `DiceGroup` → individual `Die` objects

#### Animation State Lifecycle

A die can be in one of two animation states:

1. **Not Animating** (`isAnimating = false`): The die is at rest, showing a stable pip value. Users can interact with it to lock/unlock.

2. **Animating** (`isAnimating = true`): The die is actively cycling through random pip values in a slot machine effect. User interactions are blocked.

The state transition flow:
```
Not Animating → [Roll triggered] → Animating → [Duration expires] → Not Animating
```

During the "Animating" state, the die's displayed pip value changes rapidly to create the visual slot machine effect, but the final value is already determined by the initial `roll()` call. The animation is purely visual feedback.

### Component Responsibilities

**Die Model (Models.swift)**
- Add `isAnimating` property to track animation state
- Add method to trigger animation with randomized timing
- Maintain separation between animation state and persisted data

**DieView (DieView.swift)**
- Render pip values that change during animation
- Apply SwiftUI animations for pip transitions
- Handle visual state changes (no custom animation logic needed)

**ContentView (ContentView.swift)**
- Coordinate animation start across all dice
- Monitor animation completion state
- Disable/enable buttons based on animation state
- Block tap gestures on dice during animation

### Data Flow

1. User taps Roll button
2. `ContentView.rollAll()` triggers `DiceGroup.rollAll()`
3. Each unlocked `Die` starts animation with random delay and duration
4. During animation, `Die` rapidly updates its displayed pip value
5. After random duration, animation completes and die shows final value
6. When all dice complete, buttons re-enable

## Components and Interfaces

### Die Model Extensions

```swift
@Model
class Die {
    // Existing properties...
    var isAnimating: Bool = false
    
    // New method
    func animateRoll(completion: @escaping () -> Void)
}
```

The `animateRoll` method will:
- Generate random start delay (0-0.25s)
- Generate random animation duration (0.5-1.0s)
- Update pip values during animation
- Set `isAnimating = true` at start
- Set `isAnimating = false` at completion
- Call completion handler when done

### DiceGroup Extensions

```swift
@Model
class DiceGroup {
    // New method
    func rollAllWithAnimation(completion: @escaping () -> Void)
}
```

This method will coordinate animation across all unlocked dice and notify when all animations complete.

### ContentView State

```swift
@State private var isAnyDieAnimating: Bool = false
```

This computed or observed property will determine button states and gesture blocking.

## Data Models

No changes to persisted data models. Animation state is transient and not persisted to SwiftData.

### Animation Parameters (Hardcoded)

- Start delay range: 0.0 to 0.25 seconds
- Animation duration range: 0.5 to 1.0 seconds
- Easing: SwiftUI's `.easeOut` for settling effect
- Frame update rate: Driven by SwiftUI's animation system

## Correctness Properties


*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Only unlocked dice animate

*For any* dice group, when a roll is triggered, only dice that are not locked should have `isAnimating = true`, and all locked dice should maintain their current pip value with `isAnimating = false`.

**Validates: Requirements 1.1, 1.4**

### Property 2: Animation completion means settled state

*For any* die, when its animation completes, the die should have `isAnimating = false` and display a valid pip value (1-6).

**Validates: Requirements 1.3**

### Property 3: All animations complete means no dice animating

*For any* dice group, when all dice have completed their animations, every die in the group should have `isAnimating = false`.

**Validates: Requirements 1.5**

### Property 4: Buttons disabled if and only if any die animating

*For any* dice group, the Roll button and End Turn button should be disabled if and only if at least one die has `isAnimating = true`. When all dice have `isAnimating = false`, both buttons should be enabled.

**Validates: Requirements 3.1, 3.2, 3.4**

### Property 5: Animating dice ignore lock toggles

*For any* die with `isAnimating = true`, calling `toggleLock()` should not change the die's `locked` state.

**Validates: Requirements 3.5**

### Property 6: Persistence doesn't interfere with animation

*For any* dice group, persisting the group to SwiftData while dice are animating should complete successfully without changing any die's `isAnimating` state or causing data corruption.

**Validates: Requirements 4.3**

**Explanation:** This property ensures that saving dice to SwiftData (which happens when "End Turn" is pressed) doesn't break if animation is somehow still running. The concern is that SwiftData persists the `Die` objects, but `isAnimating` is transient state that should not be saved to the database. We need to ensure:
- Saving a `DiceGroup` while dice are animating doesn't crash
- The animation state isn't accidentally persisted (which would cause dice to appear "stuck" animating on next app launch)
- The animation continues running smoothly after persistence completes

In normal operation, the buttons are disabled during animation, so this scenario shouldn't occur. However, the property tests that even if it did happen (due to a bug or race condition), the system handles it gracefully without data corruption or crashes.

## Error Handling

### Animation State Conflicts

- If a roll is triggered while dice are already animating, the request should be ignored (buttons are disabled, preventing this scenario)
- If persistence is attempted during animation, it should proceed without blocking or corrupting animation state

### Invalid Animation Parameters

- Random delay and duration values are generated programmatically and constrained to valid ranges
- No user input validation needed for animation parameters

### SwiftUI Animation Failures

- Rely on SwiftUI's animation system robustness
- If animation fails to complete, ensure cleanup sets `isAnimating = false` to prevent permanent button lockout

## Testing Strategy

### Unit Testing

Unit tests will verify:
- Animation state transitions (not animating → animating → not animating)
- Locked dice behavior (never animate, value unchanged)
- Button state logic based on animation state
- Lock toggle blocking during animation

### Property-Based Testing

We'll use Swift Testing framework's property-based testing capabilities (or a library like SwiftCheck if needed) to verify the correctness properties:

- **Property 1**: Generate random dice groups with mixed locked/unlocked states, trigger roll, verify only unlocked dice animate
- **Property 2**: Generate random dice, complete animation, verify settled state
- **Property 3**: Generate random dice groups, complete all animations, verify no dice animating
- **Property 4**: Generate random dice groups with various animation states, verify button states match
- **Property 5**: Generate random animating dice, attempt lock toggle, verify state unchanged
- **Property 6**: Generate random dice groups, persist during animation, verify no interference

Each property test should run a minimum of 100 iterations with randomized inputs.

### Integration Testing

- Test complete roll flow: button tap → animation → settled state → buttons re-enabled
- Test with maximum expected dice count (50+) to verify performance
- Test rapid user interactions (multiple taps) to ensure proper state management

### Manual Testing

- Visual verification of animation smoothness and easing
- Verification of staggered completion timing
- UI responsiveness during animation

## Implementation Notes

### SwiftUI Animation Approach

Use SwiftUI's native animation modifiers:
- `.animation(.easeOut(duration: randomDuration), value: pipValue)` for smooth transitions
- `withAnimation` blocks for coordinated state changes
- Avoid custom `CAAnimation` or manual frame-by-frame updates

### Performance Considerations

- Animation state is transient and not persisted
- Use `@State` for animation flags to minimize view updates
- Leverage SwiftUI's efficient diffing for pip value changes
- Consider `LazyVGrid` performance with 50+ animated dice

### Timing Implementation

```swift
// Pseudocode for animation timing
let startDelay = Double.random(in: 0.0...0.25)
let duration = Double.random(in: 0.5...1.0)

DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
    // Start animation with duration
    withAnimation(.easeOut(duration: duration)) {
        // Animate pip changes
    }
}
```

### State Management

- Use completion handlers or async/await to track when individual dice finish
- Aggregate completion state at `DiceGroup` level
- Update button states reactively based on animation state

## Future Enhancements

These are explicitly out of scope for this implementation:

- Sound effects for rolling
- Haptic feedback
- User-configurable animation speed
- Option to disable animations
- Accessibility support for reduced motion preferences
- Custom easing curves or animation styles
