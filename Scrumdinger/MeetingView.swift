//
//  ContentView.swift
//  Scrumdinger
//
//  Created by Jessica Soares on 06/10/2023.
//

import SwiftUI
import SwiftData
import AVFoundation

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    @StateObject var scrumTimer = ScrumTimer()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(scrum.theme.mainColor)
            VStack {
                MeetingHeaderView(secondsElapsed: scrumTimer.secondsElapsed,
                                  secondsRemaining: scrumTimer.secondsRemaining,
                                  theme: scrum.theme)
                MeetingTimerView(speakers: scrumTimer.speakers, isRecording: isRecording, theme: scrum.theme)
                MeetingFooterView(speakers: scrumTimer.speakers, skipAction: scrumTimer.skipSpeaker)
            }
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
        .onAppear {
            startScrum()
            
            
            // Carregue o arquivo de som "ding.mp3" da pasta "Assets.xcassets"
            if let soundURL = Bundle.main.url(forResource: "ding", withExtension: "mp3") {
                let localPlayer = AVPlayer(url: soundURL)
                self.player = localPlayer
                localPlayer.seek(to: .zero)
                localPlayer.play()
            }
            
            scrumTimer.speakerChangedAction = { [self] in
                if let player = self.player {
                    player.seek(to: .zero)
                    player.play()
                }
            }
            
            scrumTimer.startScrum()
        }
        .onDisappear {
            endScrum()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    private func startScrum() {
            scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
            scrumTimer.speakerChangedAction = {
                player?.seek(to: .zero)
                player!.play()
            }
            speechRecognizer.resetTranscript()
            speechRecognizer.startTranscribing()
            isRecording = true
            scrumTimer.startScrum()
        }
    
    private func endScrum() {
            scrumTimer.stopScrum()
            speechRecognizer.stopTranscribing()
            isRecording = false
            let newHistory = History(attendees: scrum.attendees,
                        transcript: speechRecognizer.transcript)
            scrum.history.insert(newHistory, at: 0)
        }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}



