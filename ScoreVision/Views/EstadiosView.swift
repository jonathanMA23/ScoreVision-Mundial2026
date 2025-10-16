// --- 3. Vista Principal Mejorada ---

import SwiftUI
import MapKit
struct EstadiosView: View {
    @StateObject private var viewModel = EstadiosViewModel()
    
    var body: some View {
        NavigationView {
            // Using a ScrollView allows for a more custom layout than a List.
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.estadios) { estadio in
                        EstadioCardView(estadio: estadio)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground)) // Subtle background color
            .navigationTitle("Sedes del Mundial")
        }
    }
}

// --- 4. Vista de Tarjeta Personalizada (Corregida) ---
struct EstadioCardView: View {
    let estadio: Estadio
    
    // No need for a @State region anymore with the new Map API if it's static
    private var initialPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: estadio.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- CÓDIGO CORREGIDO ---
            // 1. The Map view now uses a trailing closure for its content.
            // 2. The 'annotationItems' parameter is removed.
            Map(initialPosition: initialPosition) {
                // 3. Use the new Marker view directly inside the closure.
                // 4. Customize it with modifiers like .tint().
                Marker(estadio.nombre, coordinate: estadio.coordinate)
                    .tint(.green)
            }
            .frame(height: 150)
            
            // Details section with stadium information (no changes here)
            VStack(alignment: .leading, spacing: 8) {
                Text(estadio.nombre)
                    .font(.title2.bold())
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("\(estadio.ciudad), \(estadio.pais)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "person.3.fill")
                    Text("Capacidad: \(estadio.capacidadFormatted)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(.regularMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
    }
}

// --- 5. Previsualización ---
struct EstadiosView_Previews: PreviewProvider {
    static var previews: some View {
        EstadiosView()
            .preferredColorScheme(.dark)
    }
}
