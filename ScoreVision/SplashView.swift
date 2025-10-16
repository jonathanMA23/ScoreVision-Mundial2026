import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            // Dark background color
            Color(red: 22 / 255, green: 48 / 255, blue: 59 / 255)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Your logo image from Assets
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                
                // App Name
                Text("ScoreVision")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 54 / 255, green: 222 / 255, blue: 184 / 255))
                
                // Loading Indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                // Loaading Text
                Text("Cargando...")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}

