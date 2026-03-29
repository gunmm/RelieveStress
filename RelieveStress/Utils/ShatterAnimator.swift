import UIKit

class ShatterAnimator {
    
    private var animator: UIDynamicAnimator?
    private var pieceViews: [UIView] = []
    
    /// Shatter a given view. The view will be visually exploded and its original alpha set to 0.
    func shatter(view: UIView, in referenceView: UIView, completion: @escaping () -> Void) {
        // 1. Render view into an image
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
        
        // Hide original view
        view.alpha = 0
        
        // 2. Cut image into pieces (e.g. 10x10 grid for much finer shatter)
        let columns = 10
        let rows = 10
        let pieceWidth = view.bounds.width / CGFloat(columns)
        let pieceHeight = view.bounds.height / CGFloat(rows)
        
        guard let cgImage = image.cgImage else { return }
        
        // Define behaviors
        animator = UIDynamicAnimator(referenceView: referenceView)
        let gravity = UIGravityBehavior()
        let collision = UICollisionBehavior()
        // Make pieces stay on screen for a moment by setting bottom boundary just slightly off screen,
        // or let them fall completely through by setting a very low boundary.
        collision.addBoundary(withIdentifier: "bottom" as NSCopying, 
                              from: CGPoint(x: -1000, y: referenceView.bounds.height + 200), 
                              to: CGPoint(x: referenceView.bounds.width + 1000, y: referenceView.bounds.height + 200))
        
        let itemBehavior = UIDynamicItemBehavior()
        itemBehavior.elasticity = 0.6 // Bouncy
        itemBehavior.density = 1.0
        itemBehavior.friction = 0.5
        
        pieceViews.removeAll()
        
        let targetFrameInRef = view.convert(view.bounds, to: referenceView)
        
        for row in 0..<rows {
            for col in 0..<columns {
                let rect = CGRect(x: CGFloat(col) * pieceWidth, 
                                  y: CGFloat(row) * pieceHeight, 
                                  width: pieceWidth, 
                                  height: pieceHeight)
                
                // Crop
                if let croppedCGImage = cgImage.cropping(to: rect) {
                    let pieceImageView = UIImageView(image: UIImage(cgImage: croppedCGImage))
                    pieceImageView.frame = CGRect(x: targetFrameInRef.origin.x + rect.origin.x, 
                                                  y: targetFrameInRef.origin.y + rect.origin.y, 
                                                  width: pieceWidth, 
                                                  height: pieceHeight)
                    referenceView.addSubview(pieceImageView)
                    pieceViews.append(pieceImageView)
                    
                    gravity.addItem(pieceImageView)
                    collision.addItem(pieceImageView)
                    itemBehavior.addItem(pieceImageView)
                    
                    // Add explosive push force from center
                    let push = UIPushBehavior(items: [pieceImageView], mode: .instantaneous)
                    let centerOffset = CGPoint(x: pieceImageView.center.x - targetFrameInRef.midX, 
                                               y: pieceImageView.center.y - targetFrameInRef.midY)
                    // Normalize and scale magnitude
                    let maxPush = 2.0
                    push.pushDirection = CGVector(dx: centerOffset.x * 0.05, dy: centerOffset.y * 0.05)
                    push.magnitude = CGFloat.random(in: 0.5...maxPush)
                    animator?.addBehavior(push)
                    
                    // Add random rotation throw
                    itemBehavior.addAngularVelocity(CGFloat.random(in: -5...5), for: pieceImageView)
                }
            }
        }
        
        animator?.addBehavior(gravity)
        animator?.addBehavior(collision)
        animator?.addBehavior(itemBehavior)
        
        // Clean up after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.cleanUp()
            completion()
        }
    }
    
    private func cleanUp() {
        animator?.removeAllBehaviors()
        animator = nil
        pieceViews.forEach { $0.removeFromSuperview() }
        pieceViews.removeAll()
    }
}
