import SwiftUI
import MapKit

// --- 3. Vista Principal Mejorada ---
struct EstadiosView: View {
    @StateObject private var viewModel = EstadiosViewModel()
    
    // Definimos el orden de los países
    let paises = ["Canadá", "México", "Estados Unidos"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo oscuro global para coincidir con el tema de la app
                Color(red: 2/255, green: 6/255, blue: 23/255).ignoresSafeArea()
                
                ScrollView {
                    // LazyVStack con pinnedViews permite que los encabezados se queden fijos al hacer scroll
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        
                        ForEach(paises, id: \.self) { pais in
                            Section(header: CountryHeader(titulo: pais)) {
                                VStack(spacing: 20) {
                                    ForEach(viewModel.estadiosPorPais(pais)) { estadio in
                                        EstadioCardView(estadio: estadio)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 30) // Espacio entre el último estadio y el siguiente país
                            }
                        }
                        
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Sedes del Mundial")
            .navigationBarTitleDisplayMode(.inline)
            // Forzamos el estilo oscuro en la barra de navegación para que se vea bien
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 2/255, green: 6/255, blue: 23/255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// --- Header de País Personalizado ---
struct CountryHeader: View {
    let titulo: String
    
    var body: some View {
        HStack {
            Text(titulo.uppercased())
                .font(.headline)
                .fontWeight(.black)
                .tracking(2)
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            // Degradado para el fondo del header
            LinearGradient(
                colors: [
                    Color(red: 2/255, green: 6/255, blue: 23/255), // Mismo color que el fondo
                    Color(red: 2/255, green: 6/255, blue: 23/255).opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// --- 4. Vista de Tarjeta Personalizada ---
struct EstadioCardView: View {
    let estadio: Estadio
    
    // Posición inicial del mapa centrada en el estadio
    private var initialPosition: MapCameraPosition {
        .region(MKCoordinateRegion(
            center: estadio.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Mapa interactivo pequeño
            Map(initialPosition: initialPosition) {
                Marker(estadio.nombre, coordinate: estadio.coordinate)
                    .tint(.purple) // Color temático
            }
            .frame(height: 150)
            // Deshabilitamos la interacción completa para que no interfiera con el scroll
            // pero permitimos ver el mapa.
            .disabled(true)
            
            // Información del Estadio
            VStack(alignment: .leading, spacing: 10) {
                Text(estadio.nombre)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text("Ubicación:")
                            .font(.caption).bold().foregroundColor(.gray)
                        Text(estadio.ciudad)
                            .font(.caption).foregroundColor(.white)
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "person.3.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text("Capacidad:")
                            .font(.caption).bold().foregroundColor(.gray)
                        Text(estadio.capacidadFormatted)
                            .font(.caption).foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05)) // Fondo translúcido
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// --- 5. Previsualización ---
struct EstadiosView_Previews: PreviewProvider {
    static var previews: some View {
        EstadiosView()
            .preferredColorScheme(.dark)
    }
}
