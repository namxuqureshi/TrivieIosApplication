//
//  LoafClass.swift
//  TriviaApp
//
//  Created by Namxu Ihseruq on 06/03/2021.
//

import Foundation
import UIKit

final public class Loaf {
    
    // MARK: - Specifiers
    
    /// Define a custom style for the loaf.
    public struct Style {
        /// Specifies the position of the icon on the loaf. (Default is `.left`)
        ///
        /// - left: The icon will be on the left of the text
        /// - right: The icon will be on the right of the text
        public enum IconAlignment {
            case left
            case right
        }
        
        /// Specifies the width of the Loaf. (Default is `.fixed(280)`)
        ///
        /// - fixed: Specified as pixel size. i.e. 280
        /// - screenPercentage: Specified as a ratio to the screen size. This value must be between 0 and 1. i.e. 0.8
        public enum Width {
            case fixed(CGFloat)
            case screenPercentage(CGFloat)
        }
        
        /// The background color of the loaf.
        let backgroundColor: UIColor
        
        /// The color of the label's text
        let textColor: UIColor
        
        /// The color of the icon (Assuming it's rendered as template)
        let tintColor: UIColor
        
        /// The font of the label
        let font: UIFont
        
        /// The icon on the loaf
        let icon: UIImage?
        
        /// The alignment of the text within the Loaf
        let textAlignment: NSTextAlignment
        
        /// The position of the icon
        let iconAlignment: IconAlignment
        
        /// The width of the loaf
        let width: Width
        
        public init(backgroundColor: UIColor, textColor: UIColor = .white, tintColor: UIColor = .white, font: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium), icon: UIImage? = Icon.info, textAlignment: NSTextAlignment = .left, iconAlignment: IconAlignment = .left, width: Width = .fixed(280)) {
            self.backgroundColor = backgroundColor
            self.textColor = textColor
            self.tintColor = tintColor
            self.font = font
            self.icon = icon
            self.textAlignment = textAlignment
            self.iconAlignment = iconAlignment
            self.width = width
        }
    }
    
    /// Defines the loaf's status. (Default is `.info`)
    ///
    /// - success: Represents a success message
    /// - error: Represents an error message
    /// - warning: Represents a warning message
    /// - info: Represents an info message
    /// - custom: Represents a custom loaf with a specified style.
    public enum State {
        case success
        case error
        case warning
        case info
        case custom(Style)
    }
    
    /// Defines the loaction to display the loaf. (Default is `.bottom`)
    ///
    /// - top: Top of the display
    /// - bottom: Bottom of the display
    public enum Location {
        case top
        case bottom
    }
    
    /// Defines either the presenting or dismissing direction of loaf. (Default is `.vertical`)
    ///
    /// - left: To / from the left
    /// - right: To / from the right
    /// - vertical: To / from the top or bottom (depending on the location of the loaf)
    public enum Direction {
        case left
        case right
        case vertical
    }
    
    /// Defines the duration of the loaf presentation. (Default is .`avergae`)
    ///
    /// - short: 2 seconds
    /// - average: 4 seconds
    /// - long: 8 seconds
    /// - custom: A custom duration (usage: `.custom(5.0)`)
    public enum Duration {
        case short
        case average
        case long
        case custom(TimeInterval)
        
        var length: TimeInterval {
            switch self {
            case .short:   return 2.0
            case .average: return 4.0
            case .long:    return 8.0
            case .custom(let timeInterval):
                return timeInterval
            }
        }
    }
    
    /// Icons used in basic states
    public enum Icon {
        public static let success = Icons.imageOfSuccess().withRenderingMode(.alwaysTemplate)
        public static let error = Icons.imageOfError().withRenderingMode(.alwaysTemplate)
        public static let warning = Icons.imageOfWarning().withRenderingMode(.alwaysTemplate)
        public static let info = Icons.imageOfInfo().withRenderingMode(.alwaysTemplate)
    }
    
    // Reason a Loaf was dismissed
    public enum DismissalReason {
        case tapped
        case timedOut
    }
    
    // MARK: - Properties
    public typealias LoafCompletionHandler = ((DismissalReason) -> Void)?
    var message: String
    var state: State
    var location: Location
    var duration: Duration = .average
    var presentingDirection: Direction
    var dismissingDirection: Direction
    var completionHandler: LoafCompletionHandler = nil
    weak var sender: UIViewController?
    
    // MARK: - Public methods
    public init(_ message: String,
                state: State = .info,
                location: Location = .bottom,
                presentingDirection: Direction = .vertical,
                dismissingDirection: Direction = .vertical,
                sender: UIViewController) {
        self.message = message
        self.state = state
        self.location = location
        self.presentingDirection = presentingDirection
        self.dismissingDirection = dismissingDirection
        self.sender = sender
    }
    
    /// Show the loaf for a specified duration. (Default is `.average`)
    ///
    /// - Parameter duration: Length the loaf will be presented
    public func show(_ duration: Duration = .average, completionHandler: LoafCompletionHandler = nil) {
        self.duration = duration
        self.completionHandler = completionHandler
        LoafManager.shared.queueAndPresent(self)
    }
    
    /// Manually dismiss a currently presented Loaf
    ///
    /// - Parameter animated: Whether the dismissal will be animated
    public static func dismiss(sender: UIViewController, animated: Bool = true){
        guard LoafManager.shared.isPresenting else { return }
        guard let vc = sender.presentedViewController as? LoafViewController else { return }
        vc.dismiss(animated: animated) {
            vc.delegate?.loafDidDismiss()
        }
    }
}

final fileprivate class LoafManager: LoafDelegate {
    static let shared = LoafManager()
    
    fileprivate var queue = Queue<Loaf>()
    fileprivate var isPresenting = false
    
    fileprivate func queueAndPresent(_ loaf: Loaf) {
        queue.enqueue(loaf)
        presentIfPossible()
    }
    
    func loafDidDismiss() {
        isPresenting = false
        presentIfPossible()
    }
    
    fileprivate func presentIfPossible() {
        guard isPresenting == false, let loaf = queue.dequeue(), let sender = loaf.sender else { return }
        isPresenting = true
        let loafVC = LoafViewController(loaf)
        loafVC.delegate = self
        sender.presentToast(loafVC)
    }
}

protocol LoafDelegate: AnyObject {
    func loafDidDismiss()
}

final class LoafViewController: UIViewController {
    var loaf: Loaf
    
    let label = UILabel()
    let imageView = UIImageView(image: nil)
    var font = UIFont.systemFont(ofSize: 14, weight: .medium)
    var textAlignment: NSTextAlignment = .left
    var transDelegate: UIViewControllerTransitioningDelegate
    weak var delegate: LoafDelegate?
    
    init(_ toast: Loaf) {
        self.loaf = toast
        self.transDelegate = Manager(loaf: toast, size: .zero)
        super.init(nibName: nil, bundle: nil)
        
        var width: CGFloat?
        if case let Loaf.State.custom(style) = loaf.state {
            self.font = style.font
            self.textAlignment = style.textAlignment
            
            switch style.width {
            case .fixed(let value):
                width = value
            case .screenPercentage(let percentage):
                guard 0...1 ~= percentage else { return }
                width = UIScreen.main.bounds.width * percentage
            }
        }
        
        let height = max(toast.message.heightWithConstrainedWidth(width: 240, font: font) + 12, 40)
        preferredContentSize = CGSize(width: width ?? 280, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.text = loaf.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.font = font
        label.textAlignment = textAlignment
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        switch loaf.state {
        case .success:
            imageView.image = Loaf.Icon.success
            view.backgroundColor = UIColor(hexString: "#2ecc71")
            constrainWithIconAlignment(.left)
        case .warning:
            imageView.image = Loaf.Icon.warning
            view.backgroundColor = UIColor(hexString: "##f1c40f")
            constrainWithIconAlignment(.left)
        case .error:
            imageView.image = Loaf.Icon.error
            view.backgroundColor = UIColor(hexString: "##e74c3c")
            constrainWithIconAlignment(.left)
        case .info:
            imageView.image = Loaf.Icon.info
            view.backgroundColor = UIColor(hexString: "##34495e")
            constrainWithIconAlignment(.left)
        case .custom(style: let style):
            imageView.image = style.icon
            view.backgroundColor = style.backgroundColor
            imageView.tintColor = style.tintColor
            label.textColor = style.textColor
            label.font = style.font
            constrainWithIconAlignment(style.iconAlignment, showsIcon: imageView.image != nil)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loaf.duration.length, execute: {
            self.dismiss(animated: true) { [weak self] in
                self?.delegate?.loafDidDismiss()
                self?.loaf.completionHandler?(.timedOut)
            }
        })
    }
    
    @objc private func handleTap() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.loafDidDismiss()
            self?.loaf.completionHandler?(.tapped)
        }
    }
    
    private func constrainWithIconAlignment(_ alignment: Loaf.Style.IconAlignment, showsIcon: Bool = true) {
        view.addSubview(label)
        
        if showsIcon {
            view.addSubview(imageView)
            
            switch alignment {
            case .left:
                NSLayoutConstraint.activate([
                    imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 28),
                    imageView.widthAnchor.constraint(equalToConstant: 28),
                    
                    label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            case .right:
                NSLayoutConstraint.activate([
                    imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                    imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                    imageView.heightAnchor.constraint(equalToConstant: 28),
                    imageView.widthAnchor.constraint(equalToConstant: 28),
                    
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                    label.trailingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: -4),
                    label.topAnchor.constraint(equalTo: view.topAnchor),
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
            }
        } else {
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: view.topAnchor),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
    }
}

private struct Queue<T> {
    fileprivate var array = [T]()
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if array.isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
//        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
//
//        if hexFormatted.hasPrefix("#") {
//            hexFormatted = String(hexFormatted.dropFirst())
//        }
//        assert(hexFormatted.count == 6, "Invalid hex code used.")
//        var rgbValue: UInt64 = 0
//        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
//
//        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//                  alpha: alpha)
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
}

extension UIViewController{
    func presentToast(_ smartToastViewController: LoafViewController) {
        smartToastViewController.transDelegate = Manager(loaf: smartToastViewController.loaf, size: smartToastViewController.preferredContentSize)
        smartToastViewController.transitioningDelegate = smartToastViewController.transDelegate
        smartToastViewController.modalPresentationStyle = .custom
        smartToastViewController.view.clipsToBounds = true
        smartToastViewController.view.layer.cornerRadius = 6
        present(smartToastViewController, animated: true)
    }
}


class Icons: NSObject {
    
    
    //MARK: - Canvas Drawings
    
    /// Page 1
    
    class func drawInfo(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 299, height: 302), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 299, height: 302), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 299, y: resizedFrame.height / 302)
        
        /// info
        do {
            context.saveGState()
            
            /// Path
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 15, y: 105))
            path.addCurve(to: CGPoint(x: 30, y: 90.13), controlPoint1: CGPoint(x: 23.28, y: 105), controlPoint2: CGPoint(x: 30, y: 98.34))
            path.addLine(to: CGPoint(x: 30, y: 14.87))
            path.addCurve(to: CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 30, y: 6.66), controlPoint2: CGPoint(x: 23.28, y: 0))
            path.addCurve(to: CGPoint(x: 0, y: 14.87), controlPoint1: CGPoint(x: 6.72, y: 0), controlPoint2: CGPoint(x: 0, y: 6.66))
            path.addLine(to: CGPoint(x: 0, y: 90.13))
            path.addCurve(to: CGPoint(x: 15, y: 105), controlPoint1: CGPoint(x: 0, y: 98.34), controlPoint2: CGPoint(x: 6.72, y: 105))
            path.close()
            context.saveGState()
            context.translateBy(x: 135, y: 121)
            UIColor.white.setFill()
            path.fill()
            context.restoreGState()
            
            /// Oval
            let oval = UIBezierPath()
            oval.move(to: CGPoint(x: 15, y: 30))
            oval.addCurve(to: CGPoint(x: 30, y: 15), controlPoint1: CGPoint(x: 23.28, y: 30), controlPoint2: CGPoint(x: 30, y: 23.28))
            oval.addCurve(to: CGPoint(x: 15, y: 0), controlPoint1: CGPoint(x: 30, y: 6.72), controlPoint2: CGPoint(x: 23.28, y: 0))
            oval.addCurve(to: CGPoint(x: 0, y: 15), controlPoint1: CGPoint(x: 6.72, y: 0), controlPoint2: CGPoint(x: 0, y: 6.72))
            oval.addCurve(to: CGPoint(x: 15, y: 30), controlPoint1: CGPoint(x: 0, y: 23.28), controlPoint2: CGPoint(x: 6.72, y: 30))
            oval.close()
            context.saveGState()
            context.translateBy(x: 135, y: 75)
            UIColor.white.setFill()
            oval.fill()
            context.restoreGState()
            
            /// Shape
            let shape = UIBezierPath()
            shape.move(to: CGPoint(x: 149.5, y: 302))
            shape.addCurve(to: CGPoint(x: 299, y: 151), controlPoint1: CGPoint(x: 232.07, y: 302), controlPoint2: CGPoint(x: 299, y: 234.39))
            shape.addCurve(to: CGPoint(x: 149.5, y: 0), controlPoint1: CGPoint(x: 299, y: 67.61), controlPoint2: CGPoint(x: 232.07, y: 0))
            shape.addCurve(to: CGPoint(x: 0, y: 151), controlPoint1: CGPoint(x: 66.93, y: 0), controlPoint2: CGPoint(x: 0, y: 67.61))
            shape.addCurve(to: CGPoint(x: 43.79, y: 257.77), controlPoint1: CGPoint(x: 0, y: 191.05), controlPoint2: CGPoint(x: 15.75, y: 229.46))
            shape.addCurve(to: CGPoint(x: 149.5, y: 302), controlPoint1: CGPoint(x: 71.82, y: 286.09), controlPoint2: CGPoint(x: 109.85, y: 302))
            shape.close()
            shape.move(to: CGPoint(x: 149.5, y: 30.2))
            shape.addCurve(to: CGPoint(x: 269.1, y: 151), controlPoint1: CGPoint(x: 215.55, y: 30.2), controlPoint2: CGPoint(x: 269.1, y: 84.28))
            shape.addCurve(to: CGPoint(x: 149.5, y: 271.8), controlPoint1: CGPoint(x: 269.1, y: 217.72), controlPoint2: CGPoint(x: 215.55, y: 271.8))
            shape.addCurve(to: CGPoint(x: 29.9, y: 151), controlPoint1: CGPoint(x: 83.45, y: 271.8), controlPoint2: CGPoint(x: 29.9, y: 217.72))
            shape.addCurve(to: CGPoint(x: 149.5, y: 30.2), controlPoint1: CGPoint(x: 29.9, y: 84.28), controlPoint2: CGPoint(x: 83.45, y: 30.2))
            shape.close()
            context.saveGState()
            UIColor.white.setFill()
            shape.fill()
            context.restoreGState()
            
            context.restoreGState()
        }
        
        context.restoreGState()
    }
    
    class func drawSuccess(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 304, height: 302), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 304, height: 302), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 304, y: resizedFrame.height / 302)
        
        /// success
        do {
            context.saveGState()
            
            /// Group
            do {
                context.saveGState()
                
                /// Shape
                let shape = UIBezierPath()
                shape.move(to: CGPoint(x: 152.07, y: 0))
                shape.addCurve(to: CGPoint(x: 0, y: 150.88), controlPoint1: CGPoint(x: 68.24, y: 0), controlPoint2: CGPoint(x: 0, y: 67.71))
                shape.addCurve(to: CGPoint(x: 152.07, y: 301.63), controlPoint1: CGPoint(x: 0, y: 234.06), controlPoint2: CGPoint(x: 68.25, y: 301.63))
                shape.addCurve(to: CGPoint(x: 304, y: 150.88), controlPoint1: CGPoint(x: 235.88, y: 301.63), controlPoint2: CGPoint(x: 304, y: 234.05))
                shape.addCurve(to: CGPoint(x: 152.07, y: 0), controlPoint1: CGPoint(x: 304, y: 67.72), controlPoint2: CGPoint(x: 235.89, y: 0))
                shape.addLine(to: CGPoint(x: 152.07, y: 0))
                shape.close()
                shape.move(to: CGPoint(x: 152.07, y: 18.69))
                shape.addCurve(to: CGPoint(x: 285.17, y: 150.88), controlPoint1: CGPoint(x: 225.7, y: 18.69), controlPoint2: CGPoint(x: 285.17, y: 77.81))
                shape.addCurve(to: CGPoint(x: 152.07, y: 282.95), controlPoint1: CGPoint(x: 285.17, y: 223.96), controlPoint2: CGPoint(x: 225.71, y: 282.95))
                shape.addCurve(to: CGPoint(x: 18.83, y: 150.88), controlPoint1: CGPoint(x: 78.42, y: 282.95), controlPoint2: CGPoint(x: 18.83, y: 223.95))
                shape.addCurve(to: CGPoint(x: 152.07, y: 18.69), controlPoint1: CGPoint(x: 18.83, y: 77.82), controlPoint2: CGPoint(x: 78.43, y: 18.69))
                shape.close()
                context.saveGState()
                context.translateBy(x: -0, y: 0.22)
                shape.usesEvenOddFillRule = true
                UIColor.white.setFill()
                shape.fill()
                context.restoreGState()
                
                /// Path
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 153.03, y: 0.01))
                path.addCurve(to: CGPoint(x: 146.56, y: 2.84), controlPoint1: CGPoint(x: 150.58, y: 0.08), controlPoint2: CGPoint(x: 148.26, y: 1.1))
                path.addLine(to: CGPoint(x: 59.81, y: 89.03))
                path.addLine(to: CGPoint(x: 16.17, y: 45.61))
                path.addCurve(to: CGPoint(x: 7.03, y: 43.09), controlPoint1: CGPoint(x: 13.81, y: 43.2), controlPoint2: CGPoint(x: 10.31, y: 42.23))
                path.addCurve(to: CGPoint(x: 0.31, y: 49.73), controlPoint1: CGPoint(x: 3.75, y: 43.94), controlPoint2: CGPoint(x: 1.18, y: 46.48))
                path.addCurve(to: CGPoint(x: 2.83, y: 58.8), controlPoint1: CGPoint(x: -0.55, y: 52.98), controlPoint2: CGPoint(x: 0.41, y: 56.45))
                path.addLine(to: CGPoint(x: 53.14, y: 108.85))
                path.addCurve(to: CGPoint(x: 59.81, y: 111.6), controlPoint1: CGPoint(x: 54.91, y: 110.61), controlPoint2: CGPoint(x: 57.31, y: 111.6))
                path.addCurve(to: CGPoint(x: 66.47, y: 108.85), controlPoint1: CGPoint(x: 62.31, y: 111.6), controlPoint2: CGPoint(x: 64.71, y: 110.61))
                path.addLine(to: CGPoint(x: 159.88, y: 16.04))
                path.addCurve(to: CGPoint(x: 161.98, y: 5.69), controlPoint1: CGPoint(x: 162.67, y: 13.35), controlPoint2: CGPoint(x: 163.5, y: 9.24))
                path.addCurve(to: CGPoint(x: 153.03, y: 0), controlPoint1: CGPoint(x: 160.47, y: 2.15), controlPoint2: CGPoint(x: 156.91, y: -0.11))
                path.addLine(to: CGPoint(x: 153.03, y: 0.01))
                path.close()
                context.saveGState()
                context.translateBy(x: 70.64, y: 95.19)
                path.usesEvenOddFillRule = true
                UIColor.white.setFill()
                path.fill()
                context.restoreGState()
                
                context.restoreGState()
            }
            
            context.restoreGState()
        }
        
        context.restoreGState()
    }
    
    class func drawError(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 302, height: 302), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 302, height: 302), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 302, y: resizedFrame.height / 302)
        
        /// error
        do {
            context.saveGState()
            
            /// Shape
            let shape = UIBezierPath()
            shape.move(to: CGPoint(x: 151, y: 302))
            shape.addCurve(to: CGPoint(x: 0, y: 151), controlPoint1: CGPoint(x: 67.74, y: 302), controlPoint2: CGPoint(x: 0, y: 234.26))
            shape.addCurve(to: CGPoint(x: 151, y: 0), controlPoint1: CGPoint(x: 0, y: 67.74), controlPoint2: CGPoint(x: 67.74, y: 0))
            shape.addCurve(to: CGPoint(x: 302, y: 151), controlPoint1: CGPoint(x: 234.26, y: 0), controlPoint2: CGPoint(x: 302, y: 67.74))
            shape.addCurve(to: CGPoint(x: 151, y: 302), controlPoint1: CGPoint(x: 302, y: 234.26), controlPoint2: CGPoint(x: 234.26, y: 302))
            shape.close()
            shape.move(to: CGPoint(x: 151, y: 17.76))
            shape.addCurve(to: CGPoint(x: 17.76, y: 151), controlPoint1: CGPoint(x: 77.52, y: 17.76), controlPoint2: CGPoint(x: 17.76, y: 77.52))
            shape.addCurve(to: CGPoint(x: 151, y: 284.24), controlPoint1: CGPoint(x: 17.76, y: 224.48), controlPoint2: CGPoint(x: 77.52, y: 284.24))
            shape.addCurve(to: CGPoint(x: 284.24, y: 151), controlPoint1: CGPoint(x: 224.48, y: 284.24), controlPoint2: CGPoint(x: 284.24, y: 224.48))
            shape.addCurve(to: CGPoint(x: 151, y: 17.76), controlPoint1: CGPoint(x: 284.24, y: 77.52), controlPoint2: CGPoint(x: 224.48, y: 17.76))
            shape.close()
            context.saveGState()
            UIColor.white.setFill()
            shape.fill()
            context.restoreGState()
            
            /// Path
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 102.24, y: 88.96))
            path.addCurve(to: CGPoint(x: 102.22, y: 102.26), controlPoint1: CGPoint(x: 105.92, y: 92.63), controlPoint2: CGPoint(x: 105.92, y: 98.59))
            path.addLine(to: CGPoint(x: 102.22, y: 102.26))
            path.addCurve(to: CGPoint(x: 88.89, y: 102.24), controlPoint1: CGPoint(x: 98.55, y: 105.93), controlPoint2: CGPoint(x: 92.57, y: 105.91))
            path.addLine(to: CGPoint(x: 2.76, y: 16.05))
            path.addCurve(to: CGPoint(x: 2.78, y: 2.73), controlPoint1: CGPoint(x: -0.92, y: 12.36), controlPoint2: CGPoint(x: -0.92, y: 6.42))
            path.addLine(to: CGPoint(x: 2.78, y: 2.73))
            path.addCurve(to: CGPoint(x: 16.11, y: 2.77), controlPoint1: CGPoint(x: 6.47, y: -0.92), controlPoint2: CGPoint(x: 12.43, y: -0.92))
            path.addLine(to: CGPoint(x: 102.24, y: 88.96))
            path.close()
            context.saveGState()
            context.translateBy(x: 99, y: 99)
            UIColor.white.setFill()
            path.fill()
            context.restoreGState()
            
            /// Path
            let path2 = UIBezierPath()
            path2.move(to: CGPoint(x: 2.76, y: 88.96))
            path2.addCurve(to: CGPoint(x: 2.78, y: 102.26), controlPoint1: CGPoint(x: -0.92, y: 92.63), controlPoint2: CGPoint(x: -0.92, y: 98.59))
            path2.addLine(to: CGPoint(x: 2.78, y: 102.26))
            path2.addCurve(to: CGPoint(x: 16.11, y: 102.24), controlPoint1: CGPoint(x: 6.45, y: 105.93), controlPoint2: CGPoint(x: 12.44, y: 105.91))
            path2.addLine(to: CGPoint(x: 102.24, y: 16.03))
            path2.addCurve(to: CGPoint(x: 102.22, y: 2.72), controlPoint1: CGPoint(x: 105.92, y: 12.35), controlPoint2: CGPoint(x: 105.92, y: 6.4))
            path2.addLine(to: CGPoint(x: 102.22, y: 2.72))
            path2.addCurve(to: CGPoint(x: 88.9, y: 2.77), controlPoint1: CGPoint(x: 98.53, y: -0.91), controlPoint2: CGPoint(x: 92.58, y: -0.91))
            path2.addLine(to: CGPoint(x: 2.76, y: 88.96))
            path2.close()
            context.saveGState()
            context.translateBy(x: 99, y: 99)
            UIColor.white.setFill()
            path2.fill()
            context.restoreGState()
            
            context.restoreGState()
        }
        
        context.restoreGState()
    }
    
    class func drawWarning(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 327, height: 302), resizing: ResizingBehavior = .aspectFit) {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 327, height: 302), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 327, y: resizedFrame.height / 302)
        
        /// warning
        do {
            context.saveGState()
            
            /// Shape
            let shape = UIBezierPath()
            shape.move(to: CGPoint(x: 46.99, y: 302))
            shape.addLine(to: CGPoint(x: 280.19, y: 302))
            shape.addCurve(to: CGPoint(x: 319.42, y: 234.89), controlPoint1: CGPoint(x: 319.86, y: 302), controlPoint2: CGPoint(x: 338.6, y: 269.32))
            shape.addLine(to: CGPoint(x: 201.73, y: 26.15))
            shape.addCurve(to: CGPoint(x: 125.02, y: 26.15), controlPoint1: CGPoint(x: 182.12, y: -8.72), controlPoint2: CGPoint(x: 144.63, y: -8.72))
            shape.addLine(to: CGPoint(x: 7.76, y: 234.89))
            shape.addCurve(to: CGPoint(x: 46.99, y: 302), controlPoint1: CGPoint(x: -11.85, y: 269.75), controlPoint2: CGPoint(x: 7.33, y: 302))
            shape.close()
            shape.move(to: CGPoint(x: 36.1, y: 251.01))
            shape.addLine(to: CGPoint(x: 153.35, y: 42.27))
            shape.addCurve(to: CGPoint(x: 172.97, y: 42.27), controlPoint1: CGPoint(x: 159.02, y: 32.25), controlPoint2: CGPoint(x: 165.99, y: 29.63))
            shape.addLine(to: CGPoint(x: 290.66, y: 251.01))
            shape.addCurve(to: CGPoint(x: 279.76, y: 269.32), controlPoint1: CGPoint(x: 297.63, y: 263.65), controlPoint2: CGPoint(x: 290.66, y: 269.32))
            shape.addLine(to: CGPoint(x: 46.99, y: 269.32))
            shape.addCurve(to: CGPoint(x: 36.1, y: 251.01), controlPoint1: CGPoint(x: 32.17, y: 269.32), controlPoint2: CGPoint(x: 30.43, y: 261.91))
            shape.close()
            context.saveGState()
            UIColor.white.setFill()
            shape.fill()
            context.restoreGState()
            
            /// Path
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 8.53, y: 114))
            path.addLine(to: CGPoint(x: 23.47, y: 114))
            path.addCurve(to: CGPoint(x: 32, y: 105.3), controlPoint1: CGPoint(x: 28.16, y: 114), controlPoint2: CGPoint(x: 32, y: 110.08))
            path.addLine(to: CGPoint(x: 32, y: 13.05))
            path.addCurve(to: CGPoint(x: 19.2, y: 0), controlPoint1: CGPoint(x: 32, y: 5.66), controlPoint2: CGPoint(x: 26.45, y: 0))
            path.addLine(to: CGPoint(x: 12.8, y: 0))
            path.addCurve(to: CGPoint(x: 0, y: 13.05), controlPoint1: CGPoint(x: 5.55, y: 0), controlPoint2: CGPoint(x: 0, y: 5.66))
            path.addLine(to: CGPoint(x: 0, y: 105.73))
            path.addCurve(to: CGPoint(x: 8.53, y: 114), controlPoint1: CGPoint(x: 0, y: 110.52), controlPoint2: CGPoint(x: 3.84, y: 114))
            path.close()
            context.saveGState()
            context.translateBy(x: 146, y: 89)
            UIColor.white.setFill()
            path.fill()
            context.restoreGState()
            
            /// Oval
            let oval = UIBezierPath()
            oval.move(to: CGPoint(x: 16, y: 32))
            oval.addCurve(to: CGPoint(x: 32, y: 16), controlPoint1: CGPoint(x: 24.84, y: 32), controlPoint2: CGPoint(x: 32, y: 24.84))
            oval.addCurve(to: CGPoint(x: 16, y: 0), controlPoint1: CGPoint(x: 32, y: 7.16), controlPoint2: CGPoint(x: 24.84, y: 0))
            oval.addCurve(to: CGPoint(x: 0, y: 16), controlPoint1: CGPoint(x: 7.16, y: 0), controlPoint2: CGPoint(x: 0, y: 7.16))
            oval.addCurve(to: CGPoint(x: 16, y: 32), controlPoint1: CGPoint(x: 0, y: 24.84), controlPoint2: CGPoint(x: 7.16, y: 32))
            oval.close()
            context.saveGState()
            context.translateBy(x: 146, y: 220)
            UIColor.white.setFill()
            oval.fill()
            context.restoreGState()
            
            context.restoreGState()
        }
        
        context.restoreGState()
    }
    
    
    //MARK: - Canvas Images
    
    /// Page 1
    
    class func imageOfInfo() -> UIImage {
        struct LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 299, height: 302), false, 0)
        Icons.drawInfo()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    class func imageOfSuccess() -> UIImage {
        struct LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 304, height: 302), false, 0)
        Icons.drawSuccess()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    class func imageOfError() -> UIImage {
        struct LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 302, height: 302), false, 0)
        Icons.drawError()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    class func imageOfWarning() -> UIImage {
        struct LocalCache {
            static var image: UIImage!
        }
        if LocalCache.image != nil {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 327, height: 302), false, 0)
        Icons.drawWarning()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    
    //MARK: - Resizing Behavior
    
    enum ResizingBehavior {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
    
    
}

final class Manager: NSObject, UIViewControllerTransitioningDelegate {
    private let loaf: Loaf
    private let size: CGSize
    var animator: AnimatorLoader
    
    init(loaf: Loaf, size: CGSize) {
        self.loaf = loaf
        self.size = size
        self.animator = AnimatorLoader(duration: 0.4, loaf: loaf, size: size)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return Controller(
            presentedViewController: presented,
            presenting: presenting,
            loaf: loaf,
            size: size
        )
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.presenting = false
        return animator
    }
}

final class Controller: UIPresentationController {
    private let loaf: Loaf
    private let size: CGSize
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        loaf: Loaf,
        size: CGSize) {
        
        self.loaf = loaf
        self.size = size
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    //MARK: - Transitions
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        let yPosition: CGFloat
        switch loaf.location {
        case .bottom:
            let bottomMargin:CGFloat = containerView.frame.height - size.height
            if let tabBar = loaf.sender?.parent as? UITabBarController{
                yPosition = bottomMargin - 10 - tabBar.tabBar.frame.height
            }else{
                yPosition = bottomMargin - 40
            }
        case .top:
            yPosition = 50
        }
        
        containerView.frame.origin = CGPoint(
            x: (containerView.frame.width - frameOfPresentedViewInContainerView.width) / 4,
            y: yPosition
        )
        containerView.frame.size = size
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return size
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        let containerSize = size(forChildContentContainer: presentedViewController,
                                 withParentContainerSize: containerView.bounds.size)
        
        let yPosition: CGFloat
        switch loaf.location {
        case .bottom:
            yPosition = containerView.bounds.height - containerSize.height
        case .top:
            yPosition = 0
        }
        
        let toastSize = CGRect(x: containerView.center.x - (containerSize.width / 2),
                               y: yPosition,
                               width: containerSize.width,
                               height: containerSize.height
        )
        
        return toastSize
    }
}

final class AnimatorLoader: NSObject {
    var presenting: Bool!
    private let loaf: Loaf
    private let duration: TimeInterval
    private let size: CGSize
    
    init(duration: TimeInterval, loaf: Loaf, size: CGSize) {
        self.duration = duration
        self.loaf = loaf
        self.size = size
        super.init()
    }
}

extension AnimatorLoader: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = presenting ? .to : .from
        let controller = transitionContext.viewController(forKey: key)!
        
        if presenting {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        
        switch presenting ? loaf.presentingDirection : loaf.dismissingDirection {
        case .vertical:
            dismissedFrame.origin.y = (loaf.location == .bottom) ? controller.view.frame.height + 60 : -size.height - 60
        case .left:
            dismissedFrame.origin.x = -controller.view.frame.width * 2
        case .right:
            dismissedFrame.origin.x = controller.view.frame.width * 2
        }
        
        let initialFrame = presenting ? dismissedFrame : presentedFrame
        let finalFrame = presenting ? presentedFrame : dismissedFrame
        let animationOption: UIView.AnimationOptions = presenting ? .curveEaseOut : .curveEaseIn
        
        controller.view.alpha = presenting ? 0 : 1
        
        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        
        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.65, options: animationOption, animations: {
            controller.view.frame = finalFrame
            controller.view.alpha = self.presenting ? 1 : 0
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
    
}
