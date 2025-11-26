class URLResolvingBookmarkDataResponse {
  let url: URL
  let isStale: Bool

  init(url: URL, isStale: Bool) {
    self.url = url
    self.isStale = isStale
  }
}
