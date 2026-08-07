//
//----------------------------------------------
// Original project: AsynchImageCache
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.


import Foundation
import Observation

@Observable
class AsyncImageCacheController {
  private let cache: URLCache
  private let cacheDirectory: URL
  private(set) var diskUsage = 0
  
  
  init(cache: URLCache, cacheDirectory: URL) {
    self.cache = cache
    self.cacheDirectory = cacheDirectory
    refreshDiskUsage()
    
    print("AsyncImage cache Location:")
    print(cacheDirectory.path(percentEncoded: false))
  }
  
  private func refreshDiskUsage() {
    diskUsage = cache.currentDiskUsage
  }
  
  func clearCache() {
    cache.removeAllCachedResponses()
    refreshDiskUsage()
  }
  var formattedDiskUsage: String {
    ByteCountFormatter.string(fromByteCount: Int64(diskUsage), countStyle: .file)
  }
  
  var formattedDiskCapacity: String {
    ByteCountFormatter.string(fromByteCount: Int64(cache.diskCapacity), countStyle: .file)
  }
  
  func monitorDiskUsage() async {
    while !Task.isCancelled {
      refreshDiskUsage()
      
      do {
        try await Task.sleep(for: .milliseconds(250))
      } catch {
        return
      }
    }
  }
}
