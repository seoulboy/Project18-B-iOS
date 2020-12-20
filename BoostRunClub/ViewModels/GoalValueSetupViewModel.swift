//
//  GoalValueSetupViewModel.swift
//  BoostRunClub
//
//  Created by 조기현 on 2020/11/26.
//

import Combine
import Foundation

protocol GoalValueSetupViewModelTypes {
    var inputs: GoalValueSetupViewModelInputs { get }
    var outputs: GoalValueSetupViewModelOutputs { get }
}

protocol GoalValueSetupViewModelInputs {
    func didDeleteBackward()
    func didInputNumber(_ number: String)
    func didTapCancelButton()
    func didTapApplyButton()
}

protocol GoalValueSetupViewModelOutputs {
    var goalValueObservable: CurrentValueSubject<String, Never> { get }
    var runningEstimationObservable: AnyPublisher<String, Never> { get }
    var closeSheetSignal: PassthroughSubject<String?, Never> { get }
    var goalType: GoalType { get }
}

class GoalValueSetupViewModel: GoalValueSetupViewModelInputs, GoalValueSetupViewModelOutputs {
    var goalType: GoalType
    private var inputValue = ""

    init(goalType: GoalType, goalValue: String) {
        self.goalType = goalType
        goalValueObservable = CurrentValueSubject<String, Never>(goalValue)
    }

    deinit {
        print("[Memory \(Date())] 🌙ViewModel⭐️ \(Self.self) deallocated.")
    }

    // MARK: Inputs

    func didInputNumber(_ number: String) {
        let currentString = inputValue
        switch goalType {
        case .distance:
            let text = currentString + number
            if text ~= String.RegexPattern.distance.patternString {
                inputValue = text
                goalValueObservable.send(text)
            }
        case .time:
            guard
                !(currentString.isEmpty && number == "0"),
                currentString.count < 4
            else { return }

            inputValue = currentString + number
            var outputValue = String(repeating: "0", count: 4 - inputValue.count) + inputValue
            outputValue.insert(contentsOf: ":", at: outputValue.index(outputValue.startIndex, offsetBy: 2))
            goalValueObservable.send(outputValue)

        case .speed, .none:
            break
        }
    }

    func didDeleteBackward() {
        if !inputValue.isEmpty {
            inputValue.removeLast()
        }
        switch goalType {
        case .distance:
            goalValueObservable.send(inputValue.isEmpty ? "0" : inputValue)
        case .time:
            var outputValue = String(repeating: "0", count: 4 - inputValue.count) + inputValue
            outputValue.insert(contentsOf: ":", at: outputValue.index(outputValue.startIndex, offsetBy: 2))
            goalValueObservable.send(outputValue)
        case .speed, .none:
            break
        }
    }

    func didTapCancelButton() {
        closeSheetSignal.send(nil)
    }

    func didTapApplyButton() {
        var goalValue = goalValueObservable.value
        switch goalType {
        case .distance:
            guard let number = Float(goalValue) else {
                goalValue = "00.00"
                break
            }
            goalValue = String(format: "%.2f", number)
        case .time, .speed, .none:
            break
        }
        closeSheetSignal.send(goalValue)
    }

    // MARK: Outputs

    var closeSheetSignal = PassthroughSubject<String?, Never>()
    var goalValueObservable: CurrentValueSubject<String, Never>
    var runningEstimationObservable: AnyPublisher<String, Never> {
        return goalValueObservable.map {
            return $0
        }.eraseToAnyPublisher()
    }
}

// MARK: - Types

extension GoalValueSetupViewModel: GoalValueSetupViewModelTypes {
    var inputs: GoalValueSetupViewModelInputs { self }
    var outputs: GoalValueSetupViewModelOutputs { self }
}
