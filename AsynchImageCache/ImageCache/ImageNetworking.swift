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

enum ImageNetworking {
  private static let megabyte = 1_024 * 1_024
  
  static let cacheDirectory = URL.cachesDirectory.appending(component: "AsyncImageDogImages")
  
  static let imageCache = URLCache(
    memoryCapacity: 64 * megabyte,
    diskCapacity: 100 * megabyte,
    directory: cacheDirectory
  )
  
  static let imageSession:URLSession = {
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = imageCache
    configuration.requestCachePolicy = .useProtocolCachePolicy
    return URLSession(configuration: configuration)
  }()
}
