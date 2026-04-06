import UIKit

class LevelUpAlertViewController: UIViewController {

    var onDestruct: (() -> Void)?
    var onContinue: (() -> Void)?
    
    var session: VentingSession?
    
    var sessionLevel: Int = 1
    var accumulatedValue: Int = 0
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.1, alpha: 0.95)
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.systemRed.cgColor
        v.layer.shadowOpacity = 0.5
        v.layer.shadowOffset = .zero
        v.layer.shadowRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "痛快发泄了一波！"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .black)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lbl.textColor = .systemRed.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let destructBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("💥 毁灭吧！", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let continueBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("继续凌迟", for: .normal)
        btn.setTitleColor(.lightGray, for: .normal)
        btn.backgroundColor = .clear
        btn.layer.borderColor = UIColor.lightGray.cgColor
        btn.layer.borderWidth = 1
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        setupUI()
        
        switch sessionLevel {
        case 1:
            titleLabel.text = "爽快发泄！"
            subtitleLabel.text = "发泄对象已被你打得鼻青脸肿...\n现在可以直接让它彻底毁灭，\n或者把它留着继续“凌迟”！"
        case 2:
            titleLabel.text = "痛快发泄了一波！"
            subtitleLabel.text = "发泄对象已毫无招架之力...\n现在可以直接让它彻底毁灭，\n或者把它留着继续“凌迟”！"
        case 3:
            titleLabel.text = "火力全开！"
            subtitleLabel.text = "发泄对象已被折磨得奄奄一息...\n是时候让它彻底毁灭了，\n或者...你还不解气，想继续“凌迟”？"
        case 4:
            titleLabel.text = "狂暴连击！"
            subtitleLabel.text = "发泄对象已经体无完肤、濒临崩溃...\n给它最后的致命一击，\n或者继续你无情的“凌迟”？"
        default:
            titleLabel.text = "极限毁灭！"
            subtitleLabel.text = "发泄对象的精神与躯体即将崩坏...\n立刻将其灰飞烟灭，\n还是继续感受这残酷的“凌迟”？"
        }
        
        // Appear animations setup
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        containerView.alpha = 0
        
        destructBtn.addTarget(self, action: #selector(didTapDestruct), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
        
        // Additional rumble
        let notification = UINotificationFeedbackGenerator()
        notification.prepare()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            notification.notificationOccurred(.error)
        }
        
        // Trigger particle burst
        triggerSymbolBurst()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        })
        
        // Pulse destruct button
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        destructBtn.layer.add(pulse, forKey: "pulse")
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(destructBtn)
        containerView.addSubview(continueBtn)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            destructBtn.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            destructBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            destructBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            destructBtn.heightAnchor.constraint(equalToConstant: 56),
            
            continueBtn.topAnchor.constraint(equalTo: destructBtn.bottomAnchor, constant: 16),
            continueBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            continueBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            continueBtn.heightAnchor.constraint(equalToConstant: 44),
            continueBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    private func triggerSymbolBurst() {
        // [💢, 🔥, 💥, ⚡️, ☢️]
        let symbols = ["💢", "🔥", "💥", "⚡️", "☢️"]
        let symbolForLevel = symbols[min(sessionLevel - 1, symbols.count - 1)]
        
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = view.center
        emitter.emitterShape = .point
        
        let cell = CAEmitterCell()
        cell.birthRate = 80
        cell.lifetime = 1.8
        cell.velocity = 500
        cell.velocityRange = 250
        cell.emissionRange = .pi * 2
        cell.spin = 2
        cell.spinRange = 4
        cell.scale = 1.5
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.2
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 80, height: 80))
        let img = renderer.image { ctx in
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 60)]
            (symbolForLevel as NSString).draw(at: CGPoint(x: 0, y: 0), withAttributes: attrs)
        }
        
        cell.contents = img.cgImage
        emitter.emitterCells = [cell]
        
        view.layer.insertSublayer(emitter, below: containerView.layer)
        
        // Stop birthrate after a short burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            emitter.birthRate = 0
        }
        
        // Remove layer after particles die out
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitter.removeFromSuperlayer()
        }
    }
    
    @objc private func didTapDestruct() {
        saveRecord()
        dismiss(animated: true) {
            self.onDestruct?()
        }
    }
    
    @objc private func didTapContinue() {
        saveRecord()
        dismiss(animated: true) {
            self.onContinue?()
        }
    }
    
    private func saveRecord() {
        guard let session = session else { return }
        var targetDisplayName = "目标"
        switch session.target.type {
        case .text(let text): targetDisplayName = text
        case .image(_): targetDisplayName = "发泄对象"
        }
        
        let record = VentingRecord(sessionId: session.id,
                                   targetName: targetDisplayName,
                                   totalVentingScore: session.accumulatedVentingValue,
                                   energyValue: session.energyValue,
                                   weaponUsedTimes: session.strikesCount)
        RecordManager.shared.saveOrUpdate(record: record)
    }
}
