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

import SwiftUI

struct DogLoadingView: View {
  let breed: DogBreed
  
  var body: some View {
    ProgressView("Loading \(breed.displayName)s…")
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct DogLoadingErrorView: View {
  let errorMessage: String
  let retryAction: () -> Void
  
  var body: some View {
    ContentUnavailableView {
      Label("Unable to Load Dogs", systemImage: "wifi.exclamationmark")
    } description: {
      Text(errorMessage)
    } actions: {
      Button("Try Again", action: retryAction)
    }
  }
}
