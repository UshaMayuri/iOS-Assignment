//
//  ProductView.swift
//  iOS Assignment
//
//  Created by usha mayuri on 13/11/24.
//

import SwiftUI

struct ProductView: View {
    
    @StateObject var vm = ProductViewModel.shared
    
    @State var showAddScreen: Bool = false
    @State private var search: String = ""
    
//     the layout of the grid with fixed columns
    private let fixedColumn = [
        GridItem(.flexible(), spacing: nil,alignment: nil),
        GridItem(.flexible(), spacing: nil,alignment: nil)
    ]
    
    var filteredProducts: [Response]? {
        if search == "" {
            return vm.modelData
        } else {
            return vm.modelData?.filter({ $0.productName.localizedCaseInsensitiveContains(search) })
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    SearchBox
                    if let allProduct = filteredProducts {
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: fixedColumn, spacing:10){
                                ForEach(allProduct) { product in
                                    productCardView(card: product)
                                }
                            }
                        }
                    } else {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                   
                }
                AddButton
            }
            .task {
                do {
                    try await vm.getDetails() // Fetch product details when the view appears
                } catch {
                    print(error)
                }
            }
            .sheet(isPresented: $showAddScreen) {
                AddProductView()
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    // View for displaying individual product cards
    
    private func productCardView(card: Response) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            // For Image
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.blue.opacity(0.3))
                .frame(width: 160, height: 100)
                .overlay {
                    if card.image != "" {
                        if let imgURL = URL(string: card.image) {
                            AsyncImage(url: imgURL) { image in
                                image
                                    .resizable()
                                    .frame(width: 160, height: 100)
                                    .cornerRadius(18)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    } else {
                        Image(systemName: "photo.fill")
                    }
                }
                .padding([.top, .horizontal], 10)
            VStack {
                Text("\(card.productName)")
                    .font(.title2)
                    .fontDesign(.rounded)
                    .bold()
                
                Text(String(format: "₹ %.1f", card.price))
                    .bold()
                    .font(.body)
                    .fontDesign(.rounded)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            VStack(alignment: .leading) {
                Text("\(card.productType)")
                Text("Tax: \(String(format: "₹ %.1f", card.tax))")
                Spacer()
            }
            .font(.caption)
            .padding(.leading, 10)
            .padding(.top, 10)
        }
        .frame(width: 180,height: 230)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .stroke(.blue)
        }
    }
   
    // Search box view
    private var SearchBox: some View {
        HStack() {
            TextField("Search", text: $search)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.blue)
            }
         
        }
        .padding(.top, 10)
        .padding(.horizontal)
    }
    
    // Button to show the AddProductView
    private var AddButton: some View {
        Button {
            showAddScreen.toggle()
        } label: {
            Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50,height: 50)
                    .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.all)
    }
        
}

#Preview {
    ProductView()
}

