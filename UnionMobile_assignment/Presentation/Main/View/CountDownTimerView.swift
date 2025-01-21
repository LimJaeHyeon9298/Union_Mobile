//
//  CountDownTimerView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import SwiftUI
import Combine

class CountdownTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    private var timer: AnyCancellable?
    private let targetDate: Date
    
    init(targetDate: Date) {
        self.targetDate = targetDate
        updateTimeRemaining()
    }
    
    func start() {
        updateTimeRemaining()
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimeRemaining()
            }
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
    
    public func updateTimeRemaining() {
        let now = Date()
        if targetDate > now {
            timeRemaining = targetDate.timeIntervalSince(now)
        } else {
            timeRemaining = 0
            stop()
        }
    }
    
    deinit {
        stop()
    }
}

struct CountdownTimerView: View {
    @StateObject private var timer: CountdownTimer
    @Environment(\.scenePhase) private var scenePhase
    
    init(targetDate: Date) {
        _timer = StateObject(wrappedValue: CountdownTimer(targetDate: targetDate))
    }
    
    var body: some View {
        HStack(spacing: 8) {
            TimeBlockView(value: days, label: "DAY")
            
            Text(":")
                .font(.system(size: 40, weight: .bold))
                .offset(y: -10)
                .foregroundStyle(.white)
            
            TimeBlockView(value: hours, label: "HR")
            
            Text(":")
                .font(.system(size: 40, weight: .bold))
                .offset(y: -10)
                .foregroundStyle(.white)
                
            TimeBlockView(value: minutes, label: "MIN")
            
            Text(":")
                .font(.system(size: 40, weight: .bold))
                .offset(y: -10)
                .foregroundStyle(.white)
                
            TimeBlockView(value: seconds, label: "SEC")
        }
        .onAppear {
            timer.start()
        }
        .onDisappear {
            timer.stop()
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                timer.start()
            case .background, .inactive:
                timer.stop()
            @unknown default:
                break
            }
        }
    }
    
    private var days: Int {
        Int(timer.timeRemaining) / (24 * 3600)
    }
    
    private var hours: Int {
        (Int(timer.timeRemaining) % (24 * 3600)) / 3600
    }
    
    private var minutes: Int {
        (Int(timer.timeRemaining) % 3600) / 60
    }
    
    private var seconds: Int {
        Int(timer.timeRemaining) % 60
    }
}

struct TimeBlockView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(String(format: "%02d", value))")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
