//
//  ScrumTimer.swift
//  Scrumdinger
//
//  Created by Chris Lattman on 2/9/21.
//

import Foundation

@_cdecl("printFunc")
func printFunc(argString: Optional<UnsafePointer<CChar>>) {
    print(String(cString: argString!))
}

let printFuncPointer: Optional<@convention(c) (Optional<UnsafePointer<CChar>>) -> Void> = printFunc

/// Keeps time for a daily scrum meeting. Keep track of the total meeting time, the time for each speaker, and the name of the current speaker.
class ScrumTimer: ObservableObject {
    /// A struct to keep track of meeting attendees during a meeting.
    struct Speaker: Identifiable {
        /// The attendee name.
        let name: String
        /// True if the attendee has completed their turn to speak.
        var isCompleted: Bool
        /// Id for Identifiable conformance.
        let id = UUID()
    }
    /// The name of the meeting attendee who is speaking.
    @Published var activeSpeaker = ""
    /// The number of seconds since the beginning of the meeting.
    @Published var secondsElapsed = 0
    /// The number of seconds until all attendees have had a turn to speak.
    @Published var secondsRemaining = 0
    /// All meeting attendees, listed in the order they will speak.
    var speakers: [Speaker] = []

    /// The scrum meeting length.
    var lengthInMinutes: Int
    /// A closure that is executed when a new attendee begins speaking.
    var speakerChangedAction: (() -> Void)?

    private var timer: Timer?
    private var timerStopped = false
    private var frequency: TimeInterval { 1.0 / 60.0 }
    private var lengthInSeconds: Int { lengthInMinutes * 60 }
    private var secondsPerSpeaker: Int {
        (lengthInMinutes * 60) / speakers.count
    }
    private var secondsElapsedForSpeaker: Int = 0
    private var speakerIndex: Int = 0
    private var speakerText: String {
        return "Speaker \(speakerIndex + 1): " + speakers[speakerIndex].name
    }
    private var startDate: Date?
    
    /**
     Initialize a new timer. Initializing a time with no arguments creates a ScrumTimer with no attendees and zero length.
     Use `startScrum()` to start the timer.
     
     - Parameters:
        - lengthInMinutes: The meeting length.
        -  attendees: The name of each attendee.
     */
    init(lengthInMinutes: Int = 0, attendees: [String] = []) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.isEmpty ? [Speaker(name: "Player 1", isCompleted: false)] : attendees.map { Speaker(name: $0, isCompleted: false) }
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
    /// Start the timer.
    func startScrum() {
        changeToSpeaker(at: 0)
    }
    /// Stop the timer.
    func stopScrum() {
        timer?.invalidate()
        timer = nil
        timerStopped = true
    }
    /// Advance the timer to the next speaker.
    func skipSpeaker() {
        var frac1 = Fraction(
            numerator: 10,
            denominator: 13,
            str: ("Hello" as NSString).utf8String,
            print_func: printFuncPointer
        )
        var frac2 = Fraction(
            numerator: 9,
            denominator: 17,
            str: ("World!" as NSString).utf8String,
            print_func: printFuncPointer
        )
        let retval = fraction_multiply(&frac1, &frac2)
        print("10/13 * 9/17 = \(frac1.numerator)/\(frac1.denominator)")
        print("Error code = \(retval)")
        changeToSpeaker(at: speakerIndex + 1)
    }

    private func changeToSpeaker(at index: Int) {
        if index > 0 {
            let previousSpeakerIndex = index - 1
            speakers[previousSpeakerIndex].isCompleted = true
        }
        secondsElapsedForSpeaker = 0
        guard index < speakers.count else { return }
        speakerIndex = index
        activeSpeaker = speakerText

        secondsElapsed = index * secondsPerSpeaker
        secondsRemaining = lengthInSeconds - secondsElapsed
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: frequency, repeats: true) { [weak self] timer in
            if let self = self, let startDate = self.startDate {
                let secondsElapsed = Date().timeIntervalSince1970 - startDate.timeIntervalSince1970
                self.update(secondsElapsed: Int(secondsElapsed))
            }
        }
    }

    private func update(secondsElapsed: Int) {
        secondsElapsedForSpeaker = secondsElapsed
        self.secondsElapsed = secondsPerSpeaker * speakerIndex + secondsElapsedForSpeaker
        guard secondsElapsed <= secondsPerSpeaker else {
            return
        }
        secondsRemaining = max(lengthInSeconds - self.secondsElapsed, 0)

        guard !timerStopped else { return }

        if secondsElapsedForSpeaker >= secondsPerSpeaker {
            changeToSpeaker(at: speakerIndex + 1)
            speakerChangedAction?()
        }
    }
    
    /**
     Reset the timer with a new meeting length and new attendees.
     
     - Parameters:
         - lengthInMinutes: The meeting length.
         - attendees: The name of each attendee.
     */
    func reset(lengthInMinutes: Int, attendees: [String]) {
        self.lengthInMinutes = lengthInMinutes
        self.speakers = attendees.isEmpty ? [Speaker(name: "Player 1", isCompleted: false)] : attendees.map { Speaker(name: $0, isCompleted: false) }
        secondsRemaining = lengthInSeconds
        activeSpeaker = speakerText
    }
}

extension DailyScrum {
    /// A new `ScrumTimer` using the meeting length and attendees in the `DailyScrum`.
    var timer: ScrumTimer {
        ScrumTimer(lengthInMinutes: lengthInMinutes, attendees: attendees)
    }
}
