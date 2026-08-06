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

struct ContentView: View {
    @State private var dogStore = DogStore()
    @State private var selectedBreed = DogBreed.airedale
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BreedSelector(selectedBreed: $selectedBreed)
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
                        dogStore: dogStore
                    )
                }
            }
            .navigationTitle("AsyncImage Cache")
            .task(id: selectedBreed) {
                await dogStore.loadImages(for: selectedBreed)
            }
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



private struct DogLoadingView: View {
    let breed: DogBreed
    
    var body: some View {
        ProgressView("Loading \(breed.displayName)s…")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DogLoadingErrorView: View {
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

private struct DogGridView: View {
    let breed: DogBreed
    let dogStore: DogStore
    private let numberedImages: [NumberedDogImage]
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    init(
        imageURLs: [URL],
        breed: DogBreed,
        dogStore: DogStore
    ) {
        self.breed = breed
        self.dogStore = dogStore
        numberedImages = imageURLs.enumerated().map { offset, imageURL in
            NumberedDogImage(
                number: offset + 1,
                imageURL: imageURL
            )
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(numberedImages) { image in
                    DogImageCell(
                        imageURL: image.imageURL,
                        breed: breed,
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

private struct NumberedDogImage: Identifiable {
    let number: Int
    let imageURL: URL
    
    var id: URL { imageURL }
}

private struct DogImageCountFooter: View {
    let imageCount: Int
    let breed: DogBreed
    
    var body: some View {
        Text("\(imageCount) \(breed.displayName) images")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(.bar)
    }
}

private struct DogImageCell: View {
    let imageURL: URL
    let breed: DogBreed
    let sequenceNumber: Int
    
    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(url: imageURL) { phase in
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
            }
            .background(.quaternary)
            .overlay(alignment: .bottomTrailing) {
                ImageSequenceBadge(number: sequenceNumber)
            }
            .compositingGroup()
            .clipShape(.rect(cornerRadius: 12))
            .accessibilityLabel(
                "A \(breed.displayName) dog, image \(sequenceNumber)"
            )
    }
}

private struct ImageSequenceBadge: View {
    let number: Int
    
    var body: some View {
        Text(number, format: .number)
            .font(.caption.bold())
            .monospacedDigit()
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.7), in: .capsule)
            .padding(8)
            .accessibilityHidden(true)
    }
}

#Preview {
    ContentView()
}
