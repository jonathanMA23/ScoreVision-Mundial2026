import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity = 0.5

    var body: some View {
        if isActive {
            ContentView() // Cambia esto por tu vista principal
        } else {
            VStack {
                Image("Image") // agrega tu logo en Assets.xcassets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.scale = 1.0
                            self.opacity = 1.0
                        }
                    }

                Text("Cargando... ")
                    .font(.largeTitle.bold())
                    .foregroundColor(.mint)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2).delay(0.3)) {
                            self.opacity = 1.0
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
