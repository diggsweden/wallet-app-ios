enum DeeplinkError: Error {
  case invalidScheme
  case routingFailure(router: DeeplinkRouter.Type, reason: String)
}
