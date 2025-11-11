enum AsyncResult<Value> {
  case idle
  case loading
  case success(Value)
  case failure(Error)
}

extension AsyncResult: Equatable where Value: Equatable {
  static func == (l: Self, r: Self) -> Bool {
    switch (l, r) {
      case (.idle, .idle), (.loading, .loading): return true
      case let (.success(a), .success(b)): return a == b
      case (.failure, .failure): return true
      default: return false
    }
  }
}
