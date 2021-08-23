import Foundation
import Combine

@available(iOS 13.0, *)
fileprivate protocol DispatchTimerProtocol: Cancellable, Publisher {
    var publisher: PassthroughSubject<Self.Output, Self.Failure> { get }
    
    /// Resumes the dispatch source.
    func resume()
    /// Suspends the dispatch source.
    func suspend()
    /// Activates the dispatch source.
    func activate()
}

/// Dispatch Timer mimics the "DispatchSourceTimer API", but in a way that prevents the crash that occurs when you repeatedly call resume on a timer that has already been resumed.
@available(iOS 13.0, *)
public final class DispatchTimer: DispatchTimerProtocol {
    
    public enum Error: Swift.Error {
        case cancelled
    }

    public typealias Output = Void
    public typealias Failure = Error
    
    private let deadline: TimeInterval
    private let repeating: TimeInterval
    
    /// An event handler for the dispatch source timer when the timer expires.
    public let publisher = PassthroughSubject<Output, Failure>()
    
    /// Dispatch source timer activity detection state.
    private var state: State = .suspended
    private enum State { case suspended, resumed }

    public init(_ deadline: TimeInterval = 0, repeating: TimeInterval = 1) {
        self.deadline = deadline
        self.repeating = repeating
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + deadline, repeating: repeating)
        timer.setEventHandler(handler: { [weak self] in
            guard let self = self else { return }
            self.publisher.send()
        })
        return timer
    }()

    deinit {
        cancel()
    }

    /// Start Timer if state == .suspended
    public func resume() {
        guard state == .suspended else { return }
        state = .resumed
        timer.resume()
    }
    
    /// Stop Timer if state == .resumed
    public func suspend() {
        guard state == .resumed else { return }
        state = .suspended
        timer.suspend()
    }
    
    /// Activate Timer if state == .suspended
    public func activate() {
        guard state == .suspended else { return }
        state = .resumed
        timer.activate()
    }
    
}

// MARK: - DispatchTimer extension for Cancellable protocol
@available(iOS 13.0, *)
extension DispatchTimer {
    /// Implementations of Cancellable must implement this method.
    public func cancel() {
        timer.setEventHandler { }
        // If the timer is suspended, a non-resume cancel call causes a failure.
        resume()
        timer.cancel()
        publisher.send(completion: .failure(.cancelled))
    }
    
}

// MARK: - DispatchTimer extension for Publisher protocol
@available(iOS 13.0, *)
extension DispatchTimer {
    /// Implementations of Publisher must implement this method.
    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        publisher.receive(subscriber: subscriber)
    }
    
}
