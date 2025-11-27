import SwiftUI
import Charts
import Lottie
import Kingfisher

struct DetallePartidoView: View {
    let partido: Partido
    
    @Environment(\.presentationMode) var presentationMode
    @State private var tabSeleccionada = "Resumen"
    @Namespace private var animation
    @State private var mostrarCelebracion = false
    
    // --- DATOS SIMULADOS PARA GRÁFICOS (Renombrados para evitar conflictos) ---
    // Cambio: MomentumPoint -> MatchMomentumPoint
    let momentumData: [MatchMomentumPoint] = (0..<15).map { i in
        MatchMomentumPoint(minute: i * 6, strength: Double.random(in: -40...80))
    }
    
    // Cambio: StatComparison -> MatchStatComparison
    let statsComparison: [MatchStatComparison] = [
        MatchStatComparison(metric: "Goles Esp. (xG)", localValue: 2.1, visitValue: 0.9, maxScale: 3.0),
        MatchStatComparison(metric: "Posesión %", localValue: 58, visitValue: 42, maxScale: 100),
        MatchStatComparison(metric: "Pases", localValue: 412, visitValue: 305, maxScale: 500)
    ]
    // -------------------------------------------------------
    
    var body: some View {
        ZStack {
            Color(red: 2/255, green: 6/255, blue: 23/255).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navegación
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
                        .font(.caption).fontWeight(.black).tracking(2).foregroundColor(.gray)
                    Spacer()
                    Button(action: { withAnimation { mostrarCelebracion.toggle() } }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal).padding(.top, 10)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        MarcadorDinamicoView(partido: partido)
                        
                        // Tabs actualizados
                        TabsView(seleccion: $tabSeleccionada, animation: animation)
                        
                        // --- CONTENIDO DE LAS PESTAÑAS ---
                        if tabSeleccionada == "Resumen" {
                            ResumenDinamicoView(partido: partido)
                        }
                        else if tabSeleccionada == "Estadísticas" {
                            StatsAvanzadasView(momentumData: momentumData, stats: statsComparison)
                        }
                        else if tabSeleccionada == "IA Vision" {
                            IAVisionView(prediccion: partido.prediccionIA)
                        }
                        else {
                            Text("Próximamente").foregroundColor(.gray).padding(.top, 40)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            
            // Botón Flotante
            if tabSeleccionada != "IA Vision" {
                VStack {
                    Spacer()
                    Button(action: { withAnimation { tabSeleccionada = "IA Vision" } }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Ver Análisis IA ScoreVision").fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity).padding()
                        .background(LinearGradient(colors: [Color.purple, Color.blue], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white).cornerRadius(16)
                        .shadow(color: Color.purple.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal).padding(.bottom, 20)
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

// --- SUBVISTA NUEVA: Estadísticas Avanzadas (El Gráfico de Momentum) ---
struct StatsAvanzadasView: View {
    // Cambio: Tipos actualizados a MatchMomentumPoint y MatchStatComparison
    let momentumData: [MatchMomentumPoint]
    let stats: [MatchStatComparison]
    
    var body: some View {
        VStack(spacing: 20) {
            // 1. Momentum Chart
            VStack(alignment: .leading) {
                Text("MOMENTUM DE JUEGO").font(.caption).bold().foregroundColor(.secondary).padding(.bottom, 8)
                
                Chart(momentumData) { point in
                    AreaMark(
                        x: .value("Minuto", point.minute),
                        y: .value("Dominio", point.strength > 0 ? point.strength : 0)
                    )
                    .foregroundStyle(LinearGradient(colors: [.green.opacity(0.6), .green.opacity(0.1)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Minuto", point.minute),
                        y: .value("Dominio", point.strength < 0 ? point.strength : 0)
                    )
                    .foregroundStyle(LinearGradient(colors: [.blue.opacity(0.1), .blue.opacity(0.6)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                }
                .frame(height: 150)
                .chartXAxis { AxisMarks(values: .stride(by: 15)) { AxisValueLabel(format: Decimal.FormatStyle.number) } }
                .chartYAxis(.hidden)
                
                HStack {
                    Text("Visitante").font(.caption).foregroundColor(.blue)
                    Spacer()
                    Text("Local").font(.caption).foregroundColor(.green)
                }
            }
            .padding().background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal)
            
            // 2. Comparativa
            VStack(alignment: .leading, spacing: 16) {
                Text("COMPARATIVA CLAVE").font(.caption).bold().foregroundColor(.secondary)
                ForEach(stats) { stat in
                    VStack(spacing: 6) {
                        HStack {
                            Text(String(format: "%.1f", stat.localValue)).font(.caption).bold().foregroundColor(.green)
                            Spacer()
                            Text(stat.metric.uppercased()).font(.caption2).fontWeight(.heavy).foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "%.1f", stat.visitValue)).font(.caption).bold().foregroundColor(.blue)
                        }
                        GeometryReader { geo in
                            HStack(spacing: 4) {
                                ZStack(alignment: .trailing) {
                                    Capsule().fill(Color.gray.opacity(0.1))
                                    Capsule().fill(Color.green).frame(width: (stat.localValue / stat.maxScale) * (geo.size.width / 2))
                                }
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.1))
                                    Capsule().fill(Color.blue).frame(width: (stat.visitValue / stat.maxScale) * (geo.size.width / 2))
                                }
                            }
                        }.frame(height: 8)
                    }
                }
            }
            .padding().background(Color.white.opacity(0.05)).cornerRadius(16).padding(.horizontal)
            
            // Espacio final
            Color.clear.frame(height: 60)
        }
    }
}

// --- MODELOS AUXILIARES PARA GRÁFICOS (Renombrados) ---
// Se renombraron para evitar conflictos con AnalisisViewModel
struct MatchMomentumPoint: Identifiable {
    let id = UUID()
    let minute: Int
    let strength: Double
}

struct MatchStatComparison: Identifiable {
    let id = UUID()
    let metric: String
    let localValue: Double
    let visitValue: Double
    let maxScale: Double
}

// --- ACTUALIZACIÓN DE TABSVIEW ---
struct TabsView: View {
    @Binding var seleccion: String
    var animation: Namespace.ID
    
    let tabs = ["Resumen", "Alineación", "Estadísticas", "IA Vision"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(seleccion == tab ? .white : .gray)
                        .padding(.bottom, 8)
                    
                    if seleccion == tab {
                        Rectangle().fill(tab == "IA Vision" ? Color.purple : Color.green)
                            .frame(height: 3).cornerRadius(1.5)
                            .matchedGeometryEffect(id: "tabIndicator", in: animation)
                    } else {
                        Rectangle().fill(Color.clear).frame(height: 3)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { seleccion = tab } }
            }
        }
        .padding(.horizontal)
        .overlay(Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.2)), alignment: .bottom)
    }
}

// --- SUBVISTAS AUXILIARES NECESARIAS PARA QUE COMPILE ---

struct MarcadorDinamicoView: View {
    let partido: Partido
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                if partido.estado == .enVivo {
                    Circle().fill(Color.green).frame(width: 8, height: 8)
                    Text("EN VIVO • \(partido.fecha)").font(.caption).fontWeight(.bold).foregroundColor(.green)
                } else {
                    Text(partido.estado.rawValue.uppercased()).font(.caption).fontWeight(.bold).foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
            
            HStack(alignment: .center) {
                EquipoColumn(nombre: partido.equipoLocal.nombre, imagen: partido.equipoLocal.nombre.lowercased())
                if let local = partido.marcadorLocal, let visita = partido.marcadorVisitante {
                    Text("\(local):\(visita)").font(.system(size: 64, weight: .black)).foregroundColor(.white).padding(.bottom, 30)
                } else {
                    Text("VS").font(.system(size: 40, weight: .black)).foregroundColor(.gray).padding(.bottom, 30)
                }
                EquipoColumn(nombre: partido.equipoVisitante.nombre, imagen: partido.equipoVisitante.nombre.lowercased())
            }
        }
    }
}

struct EquipoColumn: View {
    let nombre: String
    let imagen: String
    // Simulación de URL de bandera
    var urlSimulada: URL? {
        let formattedName = nombre.replacingOccurrences(of: " ", with: "+")
        return URL(string: "https://ui-avatars.com/api/?name=\(formattedName)&background=random&color=fff&size=128&rounded=true&bold=true")
    }
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 4).frame(width: 80, height: 80)
                KFImage(urlSimulada).placeholder { ProgressView().tint(.white) }.resizable().aspectRatio(contentMode: .fit).frame(width: 45).clipShape(Circle())
            }
            Text(nombre).font(.headline).fontWeight(.bold).foregroundColor(.white).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResumenDinamicoView: View {
    let partido: Partido
    var body: some View {
        VStack(spacing: 20) {
            // Ejemplo de contenido de resumen
            if !partido.prediccionIA.topGoleadoresEstimados.isEmpty {
                VStack(alignment: .leading) {
                    Text("Jugadores a Seguir (IA)").font(.caption).bold().foregroundColor(.gray).padding(.horizontal)
                    ForEach(partido.prediccionIA.topGoleadoresEstimados) { jugador in
                        let playerUrl = URL(string: "https://ui-avatars.com/api/?name=\(jugador.nombre.replacingOccurrences(of: " ", with: "+"))&background=22c55e&color=fff&size=64&rounded=true")
                        EventoRow(minuto: "IA", texto: "Alta probabilidad de gol: \(jugador.nombre) (\(Int(jugador.probabilidadGol * 100))%)", tipo: .info, imageUrl: playerUrl)
                    }
                }
            }
        }
    }
}

struct IAVisionView: View {
    let prediccion: PrediccionIA
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "brain.head.profile").foregroundColor(.purple)
                    Text("PREDICCIÓN SCOREVISION").font(.headline.bold()).foregroundColor(.white)
                }
                Text("Resultado probable: \(prediccion.posibleResultado)").font(.title2.bold()).foregroundColor(.white)
                VStack(spacing: 8) {
                    HStack { Text("Local").font(.caption).foregroundColor(.gray); Spacer(); Text("\(Int(prediccion.probabilidadLocal * 100))%").font(.caption).foregroundColor(.green) }
                    ProgressView(value: prediccion.probabilidadLocal).tint(.green)
                    // ... (resto de barras)
                }
            }
            .padding().background(Color.purple.opacity(0.1)).cornerRadius(16).overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.purple.opacity(0.3), lineWidth: 1)).padding(.horizontal)
        }
    }
}

struct EventoRow: View {
    let minuto: String
    let texto: String
    let tipo: TipoEvento
    var imageUrl: URL? = nil
    enum TipoEvento { case gol, tarjeta, info }
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Text(minuto).font(.custom("Menlo", size: 14)).foregroundColor(.gray).frame(width: 30, alignment: .trailing).padding(.top, 4)
            VStack(alignment: .leading) {
                HStack {
                    if let url = imageUrl {
                        KFImage(url).resizable().placeholder { Circle().fill(Color.gray.opacity(0.3)) }.aspectRatio(contentMode: .fill).frame(width: 24, height: 24).clipShape(Circle())
                    }
                    Text(texto).font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                }
            }
            .padding().frame(maxWidth: .infinity, alignment: .leading)
            .background(tipo == .gol ? Color.green.opacity(0.1) : tipo == .tarjeta ? Color.blue.opacity(0.1) : Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView { UIView(frame: .zero) }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        uiView.subviews.forEach({ $0.removeFromSuperview() })
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        NSLayoutConstraint.activate([animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor), animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor)])
    }
}

// MARK: - PREVISUALIZACIÓN CON DATOS DE PRUEBA
struct DetallePartidoView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock Data de un Partido
        let mockPrediccion = PrediccionIA(
            posibleResultado: "2-1",
            probabilidadLocal: 0.55,
            probabilidadEmpate: 0.25,
            probabilidadVisitante: 0.20,
            topGoleadoresEstimados: [
                EstimacionJugador(nombre: "S. Giménez", golesEstimados: 0.8, probabilidadGol: 0.75),
                EstimacionJugador(nombre: "H. Lozano", golesEstimados: 0.5, probabilidadGol: 0.60)
            ],
            factoresClave: ["Localía pesa", "Rival con bajas en defensa"]
        )
        
        let mockPartido = Partido(
            equipoLocal: Equipo(id: 1, nombre: "México", codigoFIFA: "MEX", rankingIA: 8),
            equipoVisitante: Equipo(id: 2, nombre: "Alemania", codigoFIFA: "ALM", rankingIA: 20),
            marcadorLocal: 2,
            marcadorVisitante: 1,
            fecha: "90+5'",
            estadio: "Estadio Azteca",
            estado: .enVivo,
            prediccionIA: mockPrediccion
        )
        
        // Vista Previa
        DetallePartidoView(partido: mockPartido)
            .preferredColorScheme(.dark)
    }
}
