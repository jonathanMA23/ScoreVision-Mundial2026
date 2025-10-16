import Foundation
import SwiftUI
import Combine


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
                
                // --- Sección 2: Selecciones Favoritas ---
                Section(header: Text("Selecciones Favoritas (IA Personalizada)")) {
                    ForEach(viewModel.equiposDisponibles) { equipo in
                        // Usamos un componente de fila personalizado.
                        SeleccionEquipoRow(
                            equipo: equipo,
                            esFavorito: viewModel.favoritasIDs.contains(equipo.id)
                        )
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
                    }
                    .tint(.green) // Personaliza el color del toggle
                    
                    if !viewModel.favoritasIDs.isEmpty && viewModel.notificacionesActivadas {
                        Text("Recibirás alertas de IA para: \(viewModel.nombresFavoritos)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 4)
                    }
                }
                
                // --- Sección 4: Cuenta ---
                Section {
                    // Usamos Buttons para acciones semánticamente correctas.
                    Button(action: { /* Lógica para ir a la cuenta */ }) {
                        Label("Gestionar Cuenta", systemImage: "person.crop.circle")
                    }
                    
                    Button(role: .destructive, action: { /* Lógica para cerrar sesión */ }) {
                        Label("Cerrar Sesión", systemImage: "arrow.backward.square")
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
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.title2.bold())
                Text("Edición Platino")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// --- Fila de Selección de Equipo ---
struct SeleccionEquipoRow: View {
    let equipo: EquipoPerfil
    let esFavorito: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(equipo.flagImageName) // Asegúrate de tener estas imágenes
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text(equipo.nombre)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: esFavorito ? "star.fill" : "star")
                .font(.title3)
                .foregroundColor(esFavorito ? .yellow : .gray.opacity(0.5))
                .scaleEffect(esFavorito ? 1.0 : 0.8) // Efecto visual sutil
        }
        .padding(.vertical, 8)
    }
}


// --- Previsualización ---
struct PerfilView_Previews: PreviewProvider {
    static var previews: some View {
        PerfilView()
            .preferredColorScheme(.dark)
    }
}
