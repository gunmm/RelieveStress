import UIKit

class DamageOverlayView: UIView {
    
    init(center: CGPoint, impactLevel: ImpactLevel, currentLevel: Int) {
        // Base size scaled up by level
        let levelMultiplier = CGFloat(currentLevel)
        let baseSize: CGFloat = impactLevel == .heavy ? 80 : 40
        let size = baseSize * (1.0 + (levelMultiplier - 1.0) * 0.5)
        
        let frame = CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)
        super.init(frame: frame)
        setupUI(impactLevel: impactLevel, currentLevel: currentLevel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(impactLevel: ImpactLevel, currentLevel: Int) {
        self.backgroundColor = .clear
        
        // Emojis mapping
        let label = UILabel(frame: self.bounds)
        let crackEmojis = currentLevel > 2 ? ["💥", "🔥", "☄️", "⚡️"] : ["💥", "💢", "❌", "🩸"]
        label.text = crackEmojis.randomElement()
        
        let targetFontSize: CGFloat = (impactLevel == .heavy ? 60 : 30) * (1.0 + CGFloat(currentLevel - 1) * 0.3)
        label.font = UIFont.systemFont(ofSize: targetFontSize)
        label.textAlignment = .center
        
        // Random slight rotation
        let angle = CGFloat.random(in: -CGFloat.pi/4 ... CGFloat.pi/4)
        label.transform = CGAffineTransform(rotationAngle: angle)
        
        self.addSubview(label)
        
        // Small pop animation
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut) {
            self.transform = .identity
        }
    }
}
