import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            PartidosView()
                .tabItem {
                    Label("Partidos", systemImage: "sportscourt.fill")
                }

            EquipoView()
                .tabItem {
                    Label("Equipo", systemImage: "tshirt.fill")
                }
            
            AnalisisView()
                .tabItem {
                    Label("Análisis", systemImage: "chart.bar.xaxis")
                }
                
            EstadiosView()
                .tabItem {
                    Label("Estadios", systemImage: "map.fill")
                }
            // Pestaña 2: Perfil
                    PerfilView()
                        .tabItem {
                            Label("Perfil", systemImage: "person.fill")
                        }
                }

        }
    }


// Previsualización
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
