import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "location.circle")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("GPS Coordinate Converter")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
