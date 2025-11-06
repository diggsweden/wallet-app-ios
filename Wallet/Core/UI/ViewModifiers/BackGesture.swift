import SwiftUI

struct BackGesture: ViewModifier {
  let isEnabled: Bool
  let onDrag: () -> Void

  private let gestureStartEdgeWidth: CGFloat = 24
  private let popThreshold: CGFloat = 110
  private let velocityThreshold: CGFloat = 900
  @GestureState private var isDragging = false

  func body(content: Content) -> some View {
    content
      .simultaneousGesture(isEnabled ? backSwipeGesture : nil)
  }

  private var backSwipeGesture: some Gesture {
    DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .updating($isDragging) { _, state, _ in
        state = true
      }
      .onEnded { value in
        guard value.startLocation.x <= gestureStartEdgeWidth else {
          return
        }

        let x = max(0, value.translation.width)

        let gestureDuration = max(0.001, value.time.timeIntervalSinceNow.magnitude)
        let horizontalVelocity = x / gestureDuration

        if x >= popThreshold || horizontalVelocity >= velocityThreshold {
          onDrag()
        }
      }
  }
}

extension View {
  func backGesture(
    isEnabled: Bool = true,
    onDrag: @escaping () -> Void
  ) -> some View {
    modifier(BackGesture(isEnabled: isEnabled, onDrag: onDrag))
  }
}
