//
//  ContentView.swift
//  GitHubProfile
//
//  Created by Apple on 02/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GHUser?
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } placeholder: {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }
            Text(user?.name ?? "Shubham")
            Text(user?.bio ?? "My bio")
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GHError.failedToParseURL {
                print("Failed to parse url")
            } catch GHError.invalidResponse {
                print("Invalid Response")
            } catch GHError.invalidData {
                print("Invalid data")
            } catch {
                
            }
        }
    }
    
    private func getUser() async throws -> GHUser {
        let endpoint = "https://api.github.com/users/sks123git"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.failedToParseURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
            
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(GHUser.self, from: data)
        } catch {
            throw GHError.invalidData
        }
    }
}

#Preview {
    ContentView()
}

struct GHUser: Codable {
    let avatarUrl: String?
    let name: String?
    let bio: String?
}

enum GHError: Error {
    case failedToParseURL
    case invalidResponse
    case invalidData
}
