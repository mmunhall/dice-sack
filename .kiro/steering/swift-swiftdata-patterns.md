# Swift Concurrency and SwiftData Patterns

This document provides canonical patterns for handling concurrency, state management, and SwiftData integration in the DiceSack project. Follow these patterns when designing and implementing features to avoid race conditions, memory leaks, and thread safety issues.

## SwiftData Model Patterns

### Pattern 1: Main Actor Isolation for Models

**Rule:** All `@Model` classes MUST be annotated with `@MainActor` to ensure thread-safe access.

**Correct:**
```swift
@MainActor
@Model
class Die {
    var value: Int
    var locked: Bool
    
    func roll() {
        // All property access is main-actor isolated
        self.value = Int.random(in: 1...6)
    }
}
```

**Incorrect:**
```swift
@Model
class Die {
    var value: Int
    
    func roll() {
        // ❌ No actor isolation - potential data races
        DispatchQueue.global().async {
            self.value = Int.random(in: 1...6)  // Crash risk!
        }
    }
}
```

**Why:** SwiftData's model context is not thread-safe. All model operations must occur on the main actor to prevent data corruption and crashes.

### Pattern 2: Transient Properties for Non-Persisted State

**Rule:** Use `@Transient` for properties that should not be persisted to the database.

**Correct:**
```swift
@MainActor
@Model
class Die {
    var value: Int  // Persisted
    
    @Transient
    var isAnimating: Bool = false  // Not persisted
}
```

**Why:** Animation state, UI state, and computed values should not be saved to the database. They should be recalculated or reset when the app launches.

### Pattern 3: Model Container Registration

**Rule:** Register ALL `@Model` classes in the model container, including related models.

**Correct:**
```swift
@main
struct DiceSackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DiceGroup.self, Die.self])
    }
}
```

**Incorrect:**
```swift
// ❌ Only registering DiceGroup, but Die is also a @Model
.modelContainer(for: DiceGroup.self)
```

**Why:** SwiftData needs to know about all model types to properly manage relationships and persistence.

## Async Operations and Animation

### Pattern 4: Use Task for Async Work, Not DispatchQueue

**Rule:** Prefer Swift Concurrency (`Task`, `async/await`) over legacy GCD (`DispatchQueue`).

**Correct:**
```swift
@MainActor
func animateRoll() async {
    let delay = Duration.milliseconds(Int.random(in: 0...250))
    try? await Task.sleep(for: delay)
    
    for _ in 1...10 {
        self.value = Int.random(in: 1...6)
        try? await Task.sleep(for: .milliseconds(50))
    }
}
```

**Incorrect:**
```swift
func animateRoll() {
    // ❌ Using legacy GCD
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        self.value = Int.random(in: 1...6)
    }
}
```

**Why:** `Task` provides proper cancellation, structured concurrency, and integrates with Swift's actor system. `DispatchQueue` doesn't provide actor isolation guarantees.

### Pattern 5: Cancellable Animations

**Rule:** Store animation tasks and provide cancellation mechanisms.

**Correct:**
```swift
@MainActor
@Model
class Die {
    @Transient
    var animationTask: Task<Void, Never>?
    
    func startAnimation() {
        animationTask?.cancel()  // Cancel any existing animation
        
        animationTask = Task {
            for step in 1...10 {
                guard !Task.isCancelled else { return }
                self.value = Int.random(in: 1...6)
                try? await Task.sleep(for: .milliseconds(50))
            }
        }
    }
    
    func stopAnimation() {
        animationTask?.cancel()
        animationTask = nil
    }
}
```

**Why:** Animations should be cancellable when views disappear or when new animations start. This prevents memory leaks and unexpected behavior.

### Pattern 6: Completion Counting Without Race Conditions

**Rule:** Use main-actor isolation or task groups for tracking multiple async operations.

**Correct Option A: Main Actor Method**
```swift
@MainActor
func rollAllWithAnimation() async {
    await withTaskGroup(of: Void.self) { group in
        for die in dice where !die.locked {
            group.addTask {
                await die.animateRoll()
            }
        }
    }
    // All animations complete here
}
```

**Correct Option B: Actor-Isolated Counter**
```swift
@MainActor
func rollAllWithAnimation(completion: @escaping () -> Void) {
    var completedCount = 0  // Main-actor isolated
    let totalCount = dice.filter { !$0.locked }.count
    
    for die in dice where !die.locked {
        Task {
            await die.animateRoll()
            completedCount += 1
            if completedCount == totalCount {
                completion()
            }
        }
    }
}
```

**Incorrect:**
```swift
func rollAllWithAnimation(completion: @escaping () -> Void) {
    var completedCount = 0  // ❌ Not thread-safe!
    
    for die in dice {
        DispatchQueue.main.async {
            die.animateRoll {
                completedCount += 1  // ❌ Race condition!
                if completedCount == totalCount {
                    completion()
                }
            }
        }
    }
}
```

**Why:** Multiple closures modifying the same variable creates a race condition. Use structured concurrency or ensure main-actor isolation.

## State Management

### Pattern 7: Single Source of Truth

**Rule:** Computed properties must actually compute. Don't duplicate state.

**Correct:**
```swift
struct ContentView: View {
    @State private var diceGroup: DiceGroup
    
    var isAnyDieAnimating: Bool {
        diceGroup.dice.contains { $0.isAnimating }  // ✓ Computes from source
    }
}
```

**Incorrect:**
```swift
struct ContentView: View {
    @State private var diceGroup: DiceGroup
    @State private var isAnimating: Bool = false  // ❌ Duplicate state
    
    var isAnyDieAnimating: Bool {
        isAnimating  // ❌ Doesn't check actual dice state
    }
}
```

**Why:** Duplicate state can get out of sync. Always derive state from the single source of truth.

### Pattern 8: Proper Closure Captures

**Rule:** Use `[weak self]` or `[unowned self]` to prevent retain cycles in async closures.

**Correct:**
```swift
func scheduleWork() {
    Task { [weak self] in
        try? await Task.sleep(for: .seconds(1))
        guard let self else { return }
        self.updateValue()
    }
}
```

**Incorrect:**
```swift
func scheduleWork() {
    Task {
        // ❌ Strong capture of self - potential retain cycle
        try? await Task.sleep(for: .seconds(1))
        self.updateValue()
    }
}
```

**Why:** If the object is deallocated while the task is running, strong captures can cause memory leaks or crashes.

### Pattern 9: Nested Closure Captures

**Rule:** Recursive or nested closures must also use weak captures.

**Correct:**
```swift
func animateStep(step: Int) {
    guard step < 10 else { return }
    
    Task { [weak self] in
        try? await Task.sleep(for: .milliseconds(50))
        guard let self else { return }
        self.value = Int.random(in: 1...6)
        self.animateStep(step: step + 1)  // Recursive call with weak self
    }
}
```

**Incorrect:**
```swift
func animateStep(step: Int) {
    Task { [weak self] in
        guard let self else { return }
        // ...
        Task {
            self.animateStep(step: step + 1)  // ❌ Nested strong capture
        }
    }
}
```

## SwiftUI Integration

### Pattern 10: View Lifecycle Handling

**Rule:** Clean up async work when views disappear.

**Correct:**
```swift
struct DieView: View {
    let die: Die
    
    var body: some View {
        // View content
            .onDisappear {
                die.stopAnimation()
            }
    }
}
```

**Why:** Views can disappear while animations are running. Clean up to prevent crashes and memory leaks.

### Pattern 11: SwiftUI Animation Modifiers

**Rule:** Use SwiftUI's animation system for view animations, not manual state updates.

**Correct:**
```swift
struct DieView: View {
    let die: Die
    
    var body: some View {
        DieContent(value: die.value)
            .animation(.easeOut(duration: 0.3), value: die.value)
    }
}
```

**Why:** SwiftUI's animation system is optimized for view updates and handles timing automatically.

## Testing Patterns

### Pattern 12: Testing Async Code

**Rule:** Use async test methods and await async operations.

**Correct:**
```swift
@Test
func testDieAnimation() async throws {
    let die = Die(sides: 6)
    
    await die.animateRoll()
    
    #expect(die.value >= 1 && die.value <= 6)
    #expect(die.isAnimating == false)
}
```

### Pattern 13: Testing Concurrency Properties

**Rule:** Test for race conditions by running operations concurrently.

**Correct:**
```swift
@Test
func testConcurrentRolls() async throws {
    let diceGroup = DiceGroup([Die(sides: 6), Die(sides: 6)])
    
    await withTaskGroup(of: Void.self) { group in
        for _ in 1...100 {
            group.addTask {
                await diceGroup.rollAllWithAnimation()
            }
        }
    }
    
    // Verify no crashes or data corruption
    #expect(diceGroup.dice.allSatisfy { !$0.isAnimating })
}
```

## Common Pitfalls to Avoid

### ❌ Pitfall 1: Mixing GCD and Swift Concurrency
Don't use `DispatchQueue` when working with actors or `@MainActor` code.

### ❌ Pitfall 2: Forgetting @Transient
Animation state, UI flags, and computed values should be `@Transient`.

### ❌ Pitfall 3: Shared Mutable State
Avoid variables that multiple async operations modify without synchronization.

### ❌ Pitfall 4: No Cancellation
Always provide a way to cancel long-running async operations.

### ❌ Pitfall 5: Ignoring View Lifecycle
Clean up timers, tasks, and observers in `onDisappear`.

## Design Checklist

When designing a feature that involves concurrency or SwiftData, verify:

- [ ] All `@Model` classes are annotated with `@MainActor`
- [ ] Transient properties are marked with `@Transient`
- [ ] All model types are registered in the model container
- [ ] Async operations use `Task` and `async/await`, not `DispatchQueue`
- [ ] Animations are cancellable
- [ ] No shared mutable state without synchronization
- [ ] Closures use appropriate capture semantics (`[weak self]`)
- [ ] View lifecycle is handled (cleanup in `onDisappear`)
- [ ] Computed properties actually compute from source of truth
- [ ] Race conditions are prevented in completion counting

## References

- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Main Actor Documentation](https://developer.apple.com/documentation/swift/mainactor)
