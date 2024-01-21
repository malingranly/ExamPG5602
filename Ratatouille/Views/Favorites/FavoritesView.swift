//
//  FavoritesView.swift
//  Ratatouille

import SwiftUI

struct FavoritesView: View {
    /// Variables
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var shouldReload: Bool = false

    /// Fetch requests
    @FetchRequest(
        entity: Meal.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Meal.idMeal, ascending: true)
        ]
    ) var savedMeals: FetchedResults<Meal>

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !viewModel.savedMeals.isEmpty {
                    MealListView(meals: viewModel.savedMeals)
                        .id(shouldReload)
                        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                            DispatchQueue.main.async {
                                shouldReload.toggle()
                            }
                        }
                } else {
                    Spacer()
                    VStack {
                        Text("Ingen matoppskrifter")
                            .font(.title)
                            .padding()

                        Image(systemName: "square.stack.3d.up.slash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                Spacer()
            }
            .navigationTitle("Favoritter")
            .onAppear {
                viewModel.fetchSavedMealsFromCoreData()
                print("Saved meals in ViewModel: \(viewModel.savedMeals)")
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
