//
//  EditCategoryView.swift
//  Ratatouille

import SwiftUI

struct EditCategoryView: View {
    /// Variables
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isAddingCategorySheetPresented = false
    @State private var newCategoryName = ""
    @State private var selectedCategory: Category?
    @State private var isEditingCategorySheetPresented = false
    
    /// Fetch requests
    @FetchRequest(
        entity: Category.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Category.strCategory, ascending: true)
        ], predicate: NSPredicate(format: "isArchived == %@", NSNumber(value: false))
    ) var categories: FetchedResults<Category>
   
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.id) { category in
                    NavigationLink(
                        destination: EditCategoryInCoreDataView(category: category, isSheetPresented: $isEditingCategorySheetPresented)
                    ) {
                        Text(category.strCategory ?? "Unknown Category")
                    }
                    .swipeActions {
                        Button {
                            viewContext.perform {
                                category.isArchived = true
                                try? viewContext.save()
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox.circle")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            selectedCategory = category
                            isEditingCategorySheetPresented.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                }
                .onDelete { indexSet in
                    viewContext.perform {
                        for index in indexSet {
                            let category = categories[index]
                            viewContext.delete(category)
                        }
                        try? viewContext.save()
                    }
                }
            }
            .navigationTitle("Redigere kategorier")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isAddingCategorySheetPresented.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .padding(6)
                            .frame(width: 24, height: 24)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $isAddingCategorySheetPresented) {
                if let selectedCategory = selectedCategory {
                    EditCategoryInCoreDataView(category: selectedCategory, isSheetPresented: $isEditingCategorySheetPresented)
                        .environment(\.managedObjectContext, viewContext)
                } else {
                    AddCategoryView(isSheetPresented: $isAddingCategorySheetPresented, newCategoryName: $newCategoryName)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
}

struct EditCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        EditCategoryView()
    }
}
