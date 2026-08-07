//
//----------------------------------------------
// Original project: AsynchImageCache
// by  Stewart Lynch on 2026-08-05
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions. All rights reserved.


import SwiftUI

struct DogBreedsView: View {
  @State private var dogStore = DogStore()
  @State private var selectedBreed = DogBreed.airedale
  @State private var requestMode = ImageRequestMode.httpRules
  @State private var imageCache = AsyncImageCacheController(
    cache: ImageNetworking.imageCache,
    cacheDirectory: ImageNetworking.cacheDirectory
  )
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        BreedSelector(selectedBreed: $selectedBreed)
        CachePolicySelector(requestMode: $requestMode)
        CacheStatusView(
          diskUsage: imageCache.formattedDiskUsage,
          diskCapacity: imageCache.formattedDiskCapacity
        )
        Divider()
        if dogStore.isLoading && dogStore.imageURLs.isEmpty {
          DogLoadingView(breed: selectedBreed)
        } else if let errorMessage = dogStore.errorMessage {
          DogLoadingErrorView(errorMessage: errorMessage) {
            Task {
              await dogStore.loadImages(for: selectedBreed)
            }
          }
        } else {
          DogGridView(
            imageURLs: dogStore.imageURLs,
            breed: selectedBreed,
            requestMode: requestMode,
            dogStore: dogStore
          )
        }
      }
      .navigationTitle("AsyncImage Cache")
      .toolbar {
        Button(role: .destructive) {
          imageCache.clearCache()
        }
      }
      .task(id: selectedBreed) {
        await dogStore.loadImages(for: selectedBreed)
      }
    }
    .asyncImageURLSession(ImageNetworking.imageSession)
    .task {
      await imageCache.monitorDiskUsage()
    }
  }
}

private struct BreedSelector: View {
  @Binding var selectedBreed: DogBreed
  
  var body: some View {
    HStack {
      Label("Breed", systemImage: "dog")
        .font(.headline)
      Spacer()
      Picker("Breed", selection: $selectedBreed) {
        ForEach(DogBreed.allCases) { breed in
          Text(breed.displayName)
            .tag(breed)
        }
      }
      .pickerStyle(.menu)
    }
    .padding(.horizontal)
    .padding(.vertical, 10)
  }
}

private struct DogGridView: View {
  let breed: DogBreed
  let requestMode: ImageRequestMode
  let dogStore: DogStore
  private let numberedImages: [NumberedDogImage]
  
  private let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
  ]
  
  init(
    imageURLs: [URL],
    breed: DogBreed,
    requestMode: ImageRequestMode,
    dogStore: DogStore
  ) {
    self.breed = breed
    self.requestMode = requestMode
    self.dogStore = dogStore
    numberedImages = imageURLs.enumerated().map { offset, imageURL in
      NumberedDogImage(
        number: offset + 1,
        imageURL: imageURL
      )
    }
  }
  
 private struct NumberedDogImage: Identifiable {
    let number: Int
    let imageURL: URL
    
    var id: URL { imageURL }
  }

  
  var body: some View {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(numberedImages) { image in
          DogImageCell(
            imageURL: image.imageURL,
            breed: breed,
            requestMode: requestMode,
            sequenceNumber: image.number
          )
        }
      }
      .padding(12)
    }
    .refreshable {
      await dogStore.loadImages(for: breed)
    }
    .safeAreaInset(edge: .bottom) {
      DogImageCountFooter(
        imageCount: numberedImages.count,
        breed: breed
      )
    }
  }
}

private struct DogImageCell: View {
  let breed: DogBreed
  let sequenceNumber: Int
  let request: URLRequest
  
  init(
    imageURL: URL,
    breed: DogBreed,
    requestMode: ImageRequestMode,
    sequenceNumber: Int
  ) {
    self.breed = breed
    self.sequenceNumber = sequenceNumber
    self.request = URLRequest(
      url: imageURL,
      cachePolicy: requestMode.cachePolicy,
      timeoutInterval: 15
    )
  }
  
  var body: some View {
    Color.clear
      .aspectRatio(1, contentMode: .fit)
      .overlay {
        AsyncImage(request: request) { phase in
          switch phase {
          case .empty:
            ProgressView()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          case let .success(image):
            image
              .resizable()
              .scaledToFill()
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          case .failure:
            Image(systemName: "photo.badge.exclamationmark")
              .font(.largeTitle)
              .foregroundStyle(.secondary)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          @unknown default:
            EmptyView()
          }
        }
        .id(request)
      }
      .background(.quaternary)
      .overlay(alignment: .bottomTrailing) {
        ImageSequenceBadge(number: sequenceNumber)
      }
      .compositingGroup()
      .clipShape(.rect(cornerRadius: 12))
  }
}

private struct CachePolicySelector: View {
    @Binding var requestMode: ImageRequestMode

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Request policy")
                    .font(.headline)

                Spacer()

                Picker("Request policy", selection: $requestMode) {
                    ForEach(ImageRequestMode.allCases) { mode in
                        Text(mode.title)
                            .tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            Text(requestMode.explanation)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

#Preview {
  DogBreedsView()
}

