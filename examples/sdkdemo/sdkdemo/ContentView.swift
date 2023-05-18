//
//  ContentView.swift
//  sdkdemo
//
//  Created by Mateusz Worotyński on 18/05/2023.
//

import SwiftUI

struct ContentView: View {
  
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
