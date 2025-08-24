import UIKit

extension UIColor {
    // MARK: - Primary Colors
    static let primaryPurple = UIColor(red: 147/255, green: 51/255, blue: 234/255, alpha: 1.0) // #9333EA - More vibrant purple
    static let secondaryPurple = UIColor(red: 124/255, green: 58/255, blue: 237/255, alpha: 1.0) // #7C3AED - Complementary purple
    static let darkBlue = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0) // #0F172A
    static let cardBackground = UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 0.9) // #1E293B with stronger alpha
    static let cardBorder = UIColor(red: 71/255, green: 85/255, blue: 105/255, alpha: 0.3) // #475569 - Subtle border
    
    // MARK: - Gradient Colors
    static let gradientStart = primaryPurple
    static let gradientEnd = secondaryPurple
    
    // MARK: - Text Colors
    static let primaryText = UIColor.white
    static let secondaryText = UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0) // #94A3B8
    static let accentText = UIColor(red: 251/255, green: 191/255, blue: 36/255, alpha: 1.0) // #FBBF24
    static let movieTitleText = UIColor.white
    static let movieYearText = UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 0.9) // #E2E8F0 - Softer white
    
    // MARK: - Helper methods
    static func createGradientLayer(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [gradientStart.cgColor, gradientEnd.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
    
    static func createCardGradientLayer(frame: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [
            UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 0.9).cgColor,
            UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 0.8).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }
}

extension UIView {
    func addGradientBackground() {
        let gradient = UIColor.createGradientLayer(frame: bounds)
        layer.insertSublayer(gradient, at: 0)
    }
    
    func addCardGradientBackground() {
        let gradient = UIColor.createCardGradientLayer(frame: bounds)
        layer.insertSublayer(gradient, at: 0)
    }
    
    func addBlurEffect(style: UIBlurEffect.Style = .systemMaterialDark) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurEffectView, at: 0)
    }
}
