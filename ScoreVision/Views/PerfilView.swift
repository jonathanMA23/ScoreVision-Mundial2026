import SwiftUI
import Kingfisher // Importante si vas a usar imágenes remotas, aunque aquí usamos locales simuladas o SF Symbols por simplicidad en el ejemplo

// --- 3. Vista Principal Mejorada ---
struct PerfilView: View {
    @StateObject private var viewModel = PerfilViewModel()
    
    var body: some View {
        NavigationView {
            List {
                // --- Sección 1: Cabecera del Usuario ---
                Section {
                    UserHeaderView(username: "ScoreVision_User")
                }
                .listRowBackground(Color.clear) // Para que se vea limpio sobre el fondo agrupado
                .listRowInsets(EdgeInsets()) // Quitar padding por defecto
                
                // --- Sección 2: Selecciones Favoritas ---
                Section(header: Text("Selecciones Favoritas (IA Personalizada)")) {
                    ForEach(viewModel.equiposDisponibles) { equipo in
                        // Usamos un componente de fila personalizado.
                        SeleccionEquipoRow(
                            equipo: equipo,
                            esFavorito: viewModel.favoritasIDs.contains(equipo.id)
                        )
                        .contentShape(Rectangle()) // Hace que toda la fila sea tappable
                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.toggleFavorito(equipo: equipo)
                            }
                        }
                    }
                }
                
                // --- Sección 3: Configuración ---
                Section(header: Text("Configuración")) {
                    // Usamos un Label para añadir un icono al Toggle.
                    Toggle(isOn: $viewModel.notificacionesActivadas) {
                        Label("Alertas de mis Favoritos", systemImage: "bell.badge.fill")
                            .foregroundColor(.primary)
                    }
                    .tint(.green) // Personaliza el color del toggle
                    
                    if !viewModel.favoritasIDs.isEmpty && viewModel.notificacionesActivadas {
                        Text("Recibirás alertas de IA para: \(viewModel.nombresFavoritos)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .listRowSeparator(.hidden)
                    }
                }
                
                // --- Sección 4: Cuenta ---
                Section {
                    // Usamos Buttons para acciones semánticamente correctas.
                    Button(action: { /* Lógica para ir a la cuenta */ }) {
                        Label("Gestionar Cuenta", systemImage: "person.crop.circle")
                            .foregroundColor(.primary)
                    }
                    
                    Button(role: .destructive, action: { /* Lógica para cerrar sesión */ }) {
                        Label("Cerrar Sesión", systemImage: "arrow.backward.square")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped) // Estilo moderno para listas de configuración
            .navigationTitle("Mi Perfil")
        }
    }
}


// --- 4. Componentes Reutilizables ---

// --- Cabecera de Usuario ---
struct UserHeaderView: View {
    let username: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .background(Circle().fill(Color.white).frame(width: 50, height: 50)) // Fondo blanco para resaltar
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                Text("Usuario PRO")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.purple) // Un toque de color premium
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .padding(.horizontal) // Padding externo para alinearse con la lista inset
    }
}

// --- Fila de Selección de Equipo ---
struct SeleccionEquipoRow: View {
    let equipo: EquipoPerfil
    let esFavorito: Bool
    
    // Helper para URL simulada de bandera (igual que en otras vistas)
    var flagUrl: URL? {
        let name = equipo.nombre.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://ui-avatars.com/api/?name=\(name)&background=random&color=fff&size=128&rounded=true&bold=true")
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Usamos Kingfisher para consistencia, o una imagen local si tienes assets
            KFImage(flagUrl)
                .placeholder { Circle().fill(Color.gray.opacity(0.3)) }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
            
            Text(equipo.nombre)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: esFavorito ? "star.fill" : "star")
                .font(.title3)
                .foregroundColor(esFavorito ? .yellow : .gray.opacity(0.3))
                .scaleEffect(esFavorito ? 1.1 : 1.0) // Efecto visual sutil
                .animation(.spring(), value: esFavorito)
        }
        .padding(.vertical, 4)
    }
}


// --- Previsualización ---
struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
            .preferredColorScheme(.dark)
    }
}
