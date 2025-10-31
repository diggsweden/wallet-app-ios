enum DeeplinkError: Error {
  case invalidScheme
  case routingFailure(routerName: String, reason: String)
}
