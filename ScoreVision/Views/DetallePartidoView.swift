import SwiftUI
import Charts
import Lottie
import Kingfisher // 1. IMPORTANTE: Importamos Kingfisher para gestión de imágenes

struct DetallePartidoView: View {
    // Recibimos el modelo real
    let partido: Partido
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSeleccionada = "Resumen"
    @Namespace private var animation // Namespace para animaciones suaves
    
    // Estado para activar animaciones de Lottie
    @State private var mostrarCelebracion = false
    
    var body: some View {
        ZStack {
            // 1. Fondo "Slate 950"
            Color(red: 2/255, green: 6/255, blue: 23/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 2. Barra de Navegación Personalizada
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    Text(partido.estadio.uppercased())
                        .font(.caption)
                        .fontWeight(.black)
                        .tracking(2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    Spacer()
                    
                    Button(action: {
                        withAnimation { mostrarCelebracion.toggle() }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 3. Marcador Dinámico con Kingfisher
                        MarcadorDinamicoView(partido: partido)
                        
                        // 4. Pestañas
                        TabsView(seleccion: $tabSeleccionada, animation: animation)
                        
                        // 5. Contenido Cambiante
                        if tabSeleccionada == "Resumen" {
                            ResumenDinamicoView(partido: partido)
                        } else if tabSeleccionada == "IA Vision" {
                            IAVisionView(prediccion: partido.prediccionIA)
                        } else {
                            VStack {
                                LottieView(filename: "loading_animation", loopMode: .loop)
                                    .frame(width: 150, height: 150)
                                Text("Próximamente")
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            
            // Botón Flotante (Call to Action)
            if tabSeleccionada != "IA Vision" {
                VStack {
                    Spacer()
                    Button(action: { withAnimation { tabSeleccionada = "IA Vision" } }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Ver Análisis IA ScoreVision")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            // OVERLAY: Animación de Celebración
            if mostrarCelebracion {
                LottieView(filename: "confetti", loopMode: .playOnce)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            mostrarCelebracion = false
                        }
                    }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Subvistas

struct MarcadorDinamicoView: View {
    let partido: Partido
    
    var body: some View {
        VStack {
            // Tiempo / Estado
            HStack(spacing: 4) {
                if partido.estado == .enVivo {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("EN VIVO • \(partido.fecha)")
                        .font(.caption).fontWeight(.bold).foregroundColor(.green)
                } else {
                    Text(partido.estado.rawValue.uppercased())
                        .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
            
            HStack(alignment: .center) {
                // Local
                EquipoColumn(nombre: partido.equipoLocal.nombre)
                
                // Marcador Central
                if let local = partido.marcadorLocal, let visita = partido.marcadorVisitante {
                    Text("\(local):\(visita)")
                        .font(.system(size: 64, weight: .black))
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                } else {
                    Text("VS")
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.gray)
                        .padding(.bottom, 30)
                }
                
                // Visitante
                EquipoColumn(nombre: partido.equipoVisitante.nombre)
            }
        }
    }
}

struct EquipoColumn: View {
    let nombre: String
    
    // Generamos una URL simulada basada en el nombre para la demo
    // En producción usarías: URL(string: equipo.urlBandera)
    var urlSimulada: URL? {
        // Usamos ui-avatars para generar un escudo con las iniciales y colores aleatorios
        let formattedName = nombre.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://ui-avatars.com/api/?name=\(formattedName)&background=random&color=fff&size=128&rounded=true&bold=true")
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                // --- IMPLEMENTACIÓN DE KINGFISHER ---
                KFImage(urlSimulada)
                    .placeholder {
                        // Lo que se muestra mientras carga
                        ProgressView()
                            .tint(.white)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45)
                    .clipShape(Circle()) // Forzamos forma circular
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            Text(nombre)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResumenDinamicoView: View {
    let partido: Partido
    
    // Datos simulados para el gráfico
    struct MomentumData: Identifiable {
        let id = UUID()
        let minuto: Int
        let valor: Int
        let esLocal: Bool
    }
    
    let datosGrafico: [MomentumData] = (0..<15).map { i in
        MomentumData(minuto: i * 6, valor: Int.random(in: 30...90), esLocal: Bool.random())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Gráfica de Dominio con Swift Charts
            VStack(alignment: .leading) {
                HStack {
                    Text("MOMENTUM DEL PARTIDO")
                        .font(.caption).fontWeight(.bold).foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "chart.bar.fill").foregroundColor(.purple)
                }
                .padding(.bottom, 10)
                
                Chart {
                    ForEach(datosGrafico) { dato in
                        BarMark(
                            x: .value("Minuto", dato.minuto),
                            y: .value("Dominio", dato.valor)
                        )
                        .foregroundStyle(dato.esLocal ? Color.green : Color.blue)
                        .cornerRadius(4)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 70)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Goleadores Estimados (Si no hay eventos reales)
            if !partido.prediccionIA.topGoleadoresEstimados.isEmpty {
                VStack(alignment: .leading) {
                    Text("Jugadores a Seguir (IA)")
                        .font(.caption).bold().foregroundColor(.gray).padding(.horizontal)
                    
                    ForEach(partido.prediccionIA.topGoleadoresEstimados) { jugador in
                        // Generamos URL de foto de jugador simulada
                        let playerUrl = URL(string: "https://ui-avatars.com/api/?name=\(jugador.nombre.replacingOccurrences(of: " ", with: "+"))&background=22c55e&color=fff&size=64&rounded=true")
                        
                        EventoRow(
                            minuto: "IA",
                            texto: "Alta probabilidad de gol: \(jugador.nombre) (\(Int(jugador.probabilidadGol * 100))%)",
                            tipo: .info,
                            imageUrl: playerUrl // Pasamos la URL a la fila
                        )
                    }
                }
            }
            
            Color.clear.frame(height: 80)
        }
    }
}

struct IAVisionView: View {
    let prediccion: PrediccionIA
    
    var body: some View {
        VStack(spacing: 20) {
            // Tarjeta de Probabilidad
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "brain.head.profile").foregroundColor(.purple)
                    Text("PREDICCIÓN SCOREVISION").font(.headline.bold()).foregroundColor(.white)
                }
                
                Text("Resultado probable: \(prediccion.posibleResultado)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // Barras de porcentaje
                VStack(spacing: 8) {
                    HStack { Text("Local").font(.caption).foregroundColor(.gray); Spacer(); Text("\(Int(prediccion.probabilidadLocal * 100))%").font(.caption).foregroundColor(.green) }
                    ProgressView(value: prediccion.probabilidadLocal).tint(.green)
                    
                    HStack { Text("Empate").font(.caption).foregroundColor(.gray); Spacer(); Text("\(Int(prediccion.probabilidadEmpate * 100))%").font(.caption).foregroundColor(.white) }
                    ProgressView(value: prediccion.probabilidadEmpate).tint(.gray)
                    
                    HStack { Text("Visitante").font(.caption).foregroundColor(.gray); Spacer(); Text("\(Int(prediccion.probabilidadVisitante * 100))%").font(.caption).foregroundColor(.blue) }
                    ProgressView(value: prediccion.probabilidadVisitante).tint(.blue)
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.3), lineWidth: 1))
            .padding(.horizontal)
            
            // Factores Clave
            VStack(alignment: .leading, spacing: 10) {
                Text("Factores Clave").font(.headline).foregroundColor(.white).padding(.horizontal)
                
                ForEach(prediccion.factoresClave, id: \.self) { factor in
                    HStack {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        Text(factor).foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            
            Color.clear.frame(height: 80)
        }
    }
}

// MARK: - Componentes Auxiliares

struct TabsView: View {
    @Binding var seleccion: String
    var animation: Namespace.ID
    
    let tabs = ["Resumen", "Alineación", "Estadísticas", "IA Vision"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(seleccion == tab ? .white : .gray)
                        .padding(.bottom, 8)
                    
                    if seleccion == tab {
                        Rectangle()
                            .fill(tab == "IA Vision" ? Color.purple : Color.green)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                            .matchedGeometryEffect(id: "tabIndicator", in: animation)
                    } else {
                        Rectangle().fill(Color.clear).frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation { seleccion = tab }
                }
                .overlay(
                    tab == "IA Vision" ?
                        Text("PRO")
                        .font(.system(size: 8, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.purple)
                        .cornerRadius(4)
                        .foregroundColor(.white)
                        .offset(x: 20, y: -15)
                    : nil
                )
            }
        }
        .padding(.horizontal)
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

struct EventoRow: View {
    let minuto: String
    let texto: String
    let tipo: TipoEvento
    var imageUrl: URL? = nil // Nuevo parámetro opcional para la imagen
    
    enum TipoEvento { case gol, tarjeta, info }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(minuto)
                .font(.custom("Menlo", size: 14))
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .trailing)
                .padding(.top, 4)
            
            VStack(alignment: .leading) {
                HStack {
                    // Si hay URL, mostramos la imagen con Kingfisher
                    if let url = imageUrl {
                        KFImage(url)
                            .resizable()
                            .placeholder { Circle().fill(Color.gray.opacity(0.3)) }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                            .clipShape(Circle())
                    }
                    Text(texto)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                tipo == .gol ? Color.green.opacity(0.1) :
                tipo == .tarjeta ? Color.blue.opacity(0.1) : Color.white.opacity(0.05)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        tipo == .gol ? Color.green.opacity(0.3) :
                        tipo == .tarjeta ? Color.blue.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

// MARK: - Wrapper de Lottie para SwiftUI

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        uiView.subviews.forEach({ $0.removeFromSuperview() })
        
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor)
        ])
    }
}

// MARK: - PREVISUALIZACIÓN CON DATOS DE PRUEBA
struct DetallePartidoView_Previews: PreviewProvider {
    static var previews: some View {
        // Ejemplo: Argentina vs Canadá (Basado en el JSON)
        let mockPrediccion = PrediccionIA(
            posibleResultado: "2-0",
            probabilidadLocal: 0.80,
            probabilidadEmpate: 0.15,
            probabilidadVisitante: 0.05,
            topGoleadoresEstimados: [
                EstimacionJugador(nombre: "Lautaro Martínez", golesEstimados: 0.8, probabilidadGol: 0.65)
            ],
            factoresClave: ["Strong offense"]
        )
        
        let mockPartido = Partido(
            equipoLocal: Equipo(id: 5, nombre: "Argentina", codigoFIFA: "ARG", rankingIA: 2),
            equipoVisitante: Equipo(id: 6, nombre: "Canadá", codigoFIFA: "CAN", rankingIA: 49),
            marcadorLocal: 2,
            marcadorVisitante: 0,
            fecha: "14 Oct",
            estadio: "Mercedes-Benz",
            estado: .finalizado,
            prediccionIA: mockPrediccion
        )
        
        DetallePartidoView(partido: mockPartido)
            .preferredColorScheme(.dark)
    }
}
