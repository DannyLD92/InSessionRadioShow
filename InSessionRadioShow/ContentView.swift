//
//  ContentView.swift
//  InSessionRadioShow
//
//  Created by MARITZA  DAVID GALINDO on 15/03/25.
//

import SwiftUI
import AVFoundation
import MediaPlayer

class AudioPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false // Estado de la reproducción
    
    func setupAudioSession() {
        do {
            // Establecer el audio session en modo playback (reproducción)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            
            // Activar el audio session
            try AVAudioSession.sharedInstance().setActive(true)
            
            print("Audio session configurado para reproducción")
        } catch {
            print("Error al configurar el audio session: \(error)")
        }
    }
    func playPauseAudio(from url: String) {
        
        guard let audioURL = URL(string: url) else {
            print("URL inválida")
            return
        }

        if isPlaying {
            pauseAudio()
        } else {
            playAudio(from: audioURL)
            
        }
    }

    private func playAudio(from url: URL) {
        if player == nil {
            player = AVPlayer(url: url)
        }

        player?.play()
        isPlaying = true
        setupAudioSession()
    }

    private func pauseAudio() {
        player?.pause()
        isPlaying = false
    }

    // Opcional: Detectar cuando el audio ha terminado
    func addObserverForAudioFinish() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(audioSessionInterrupted(_:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    @objc func audioDidFinish() {
        isPlaying = false
    }
    
    @objc func audioSessionInterrupted(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeRawValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeRawValue) else {
            return
        }
        
        switch type {
        case .began:
            // Pausar el audio si es necesario
            print("Interrupción de audio (llamada telefónica)")
            
        case .ended:
            // Reanudar la reproducción si es necesario
            print("Interrupción de audio terminada")
            // Aquí podrías reanudar el audio si lo habías pausado
        @unknown default:
            break
        }
    }
}

struct ContentView: View {
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    let backgroundImageURL = "https://i.imgur.com/Lc0iDhj.jpeg"
    let playImageURL = "https://i.imgur.com/jpGkzQ8.png"
    let pauseImageURL = "https://i.imgur.com/9mG3FJM.png"

    var body: some View {
        ZStack{
            Color.black
                .edgesIgnoringSafeArea(.all)
            AsyncImage(url: URL(string: backgroundImageURL)) { image in
                            image
                                .resizable() // Para ajustar el tamaño de la imagen
                                .scaledToFill() // Rellenar toda la pantalla
                                //.edgesIgnoringSafeArea(.all) // Ignorar los márgenes y cubrir toda la pantalla
                        } placeholder: {
                            Color.gray // Mostrar un color de fondo mientras carga la imagen
                        }
            VStack{
                
                // Sección de textos en la parte superior

                    Text("InSessionRadioShow")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                        // Espacio en la parte superior
                    
                    Text("ON AIR")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                         // Espacio debajo del texto anterior
                    
                    Text("Madrid, España")
                        .font(.title2)
                        .foregroundColor(.yellow) // Espacio debajo del texto anterior
                
                .padding() // Padding alrededor de los textos
                
                Spacer() // Empuja los textos hacia la parte superior
                
                VStack {
                    Button(action: {
                        // Reemplaza la URL con la de tu archivo de audio
                        audioPlayer.playPauseAudio(from: "https://cloud8.vsgtech.co/8074/stream")
                    }) {
                        
                        AsyncImage(url: URL(string: audioPlayer.isPlaying ? pauseImageURL : playImageURL)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200) // Ajusta el tamaño de la imagen según sea necesario
                            
                        } placeholder: {
                            ProgressView() // Mostrar un indicador de carga mientras la imagen se descarga
                        }
                    }
                    .padding(.top, 100)
                    Spacer()
                    Spacer()
                }
            }
            .padding()
            Spacer()
            .onAppear {
                // Añadir observador para detectar cuando el audio termina
                audioPlayer.addObserverForAudioFinish()
            }
        }
    }
}

@main
struct AudioPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

