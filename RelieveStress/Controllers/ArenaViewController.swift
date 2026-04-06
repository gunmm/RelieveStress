import UIKit
import AudioToolbox

class ArenaViewController: UIViewController, WeaponToolbarDelegate, TargetSetupDelegate {
    
    // UI Elements
    private let tipBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("打赏 ❤️", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let recordsBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("记录 📊", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let setupBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("更换发泄对象", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemRed.withAlphaComponent(0.8)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let targetContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.secondarySystemBackground
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    private let targetLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 48, weight: .black)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private let targetImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.isHidden = true
        return iv
    }()
    
    private let scoreTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl.textColor = .systemRed.withAlphaComponent(0.8)
        lbl.textAlignment = .center
        lbl.text = "🔥 已释放怒气值"
        return lbl
    }()
    
    private let scoreLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.monospacedDigitSystemFont(ofSize: 42, weight: .black)
        lbl.textColor = .systemRed
        lbl.textAlignment = .center
        lbl.text = "0"
        return lbl
    }()
    
    private let flashView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .red
        v.alpha = 0
        v.isUserInteractionEnabled = false
        return v
    }()
    
    private let toolbar: WeaponToolbar = {
        let tb = WeaponToolbar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    // Core Data
    private var session: VentingSession?
    private var currentWeapon: WeaponModel = WeaponModel.availableWeapons[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If no session is active, present the setup sheet
        if session == nil {
            presentSetupVC()
        }
    }
    
    private func setupUI() {
        toolbar.delegate = self
        
        view.addSubview(tipBtn)
        view.addSubview(recordsBtn)
        view.addSubview(setupBtn)
        view.addSubview(toolbar)
        view.addSubview(scoreTitleLabel)
        view.addSubview(scoreLabel)
        view.addSubview(targetContainerView)
        targetContainerView.addSubview(targetLabel)
        targetContainerView.addSubview(targetImageView)
        
        // Add flashView on top of everything but below setup button
        view.addSubview(flashView)
        view.bringSubviewToFront(tipBtn)
        view.bringSubviewToFront(recordsBtn)
        view.bringSubviewToFront(setupBtn)
        
        setupBtn.addTarget(self, action: #selector(presentSetupVC), for: .touchUpInside)
        tipBtn.addTarget(self, action: #selector(presentTipVC), for: .touchUpInside)
        recordsBtn.addTarget(self, action: #selector(presentRecords), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Top Navigation Row
            setupBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setupBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            tipBtn.centerYAnchor.constraint(equalTo: setupBtn.centerYAnchor),
            tipBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            recordsBtn.centerYAnchor.constraint(equalTo: setupBtn.centerYAnchor),
            recordsBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            // Toolbar at bottom SafeArea
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toolbar.heightAnchor.constraint(equalToConstant: 80),
            
            // Score Title Label
            scoreTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scoreTitleLabel.topAnchor.constraint(equalTo: setupBtn.bottomAnchor, constant: 10),
            
            // Score Label at the top (below score title)
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scoreLabel.topAnchor.constraint(equalTo: scoreTitleLabel.bottomAnchor, constant: 0),
            scoreLabel.heightAnchor.constraint(equalToConstant: 50),
            
            // Target Container in the center
            targetContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            targetContainerView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            targetContainerView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -20),
            targetContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            // Flash View covering Entire Screen
            flashView.topAnchor.constraint(equalTo: view.topAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            flashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Subviews inside target
            targetLabel.leadingAnchor.constraint(equalTo: targetContainerView.leadingAnchor, constant: 20),
            targetLabel.trailingAnchor.constraint(equalTo: targetContainerView.trailingAnchor, constant: -20),
            targetLabel.centerYAnchor.constraint(equalTo: targetContainerView.centerYAnchor),
            
            targetImageView.leadingAnchor.constraint(equalTo: targetContainerView.leadingAnchor),
            targetImageView.trailingAnchor.constraint(equalTo: targetContainerView.trailingAnchor),
            targetImageView.topAnchor.constraint(equalTo: targetContainerView.topAnchor),
            targetImageView.bottomAnchor.constraint(equalTo: targetContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - API
    
    @objc private func presentTipVC() {
        let tipVC = TipViewController()
        present(tipVC, animated: true, completion: nil)
    }
    
    @objc private func presentRecords() {
        let recordsVC = RecordsViewController()
        let nav = UINavigationController(rootViewController: recordsVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
        }
        present(nav, animated: true, completion: nil)
    }
    
    @objc private func presentSetupVC() {
        let setupVC = TargetSetupViewController()
        setupVC.delegate = self
        // Use a bottom sheet style presentation
        if let sheet = setupVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(setupVC, animated: true, completion: nil)
    }
    
    func didSetupTarget(_ target: TargetModel) {
        startNewSession(with: target)
    }
    
    func startNewSession(with target: TargetModel) {
        session = VentingSession(target: target)
        
        targetContainerView.subviews.compactMap { $0 as? DamageOverlayView }.forEach { $0.removeFromSuperview() }
        targetContainerView.alpha = 1.0
        scoreTitleLabel.alpha = 1.0
        scoreLabel.text = "0"
        scoreLabel.alpha = 1.0
        
        switch target.type {
        case .text(let str):
            targetLabel.text = str
            targetLabel.isHidden = false
            targetImageView.isHidden = true
        case .image(let img):
            targetImageView.image = img
            targetImageView.isHidden = false
            targetLabel.isHidden = true
        }
    }
    
    // MARK: - Weapon Toolbar Delegate
    func didSelectWeapon(_ weapon: WeaponModel) {
        self.currentWeapon = weapon
    }
    
    // MARK: - Handle Hits
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // Ensure touch is inside the target container bounds
        let location = touch.location(in: targetContainerView)
        if targetContainerView.bounds.contains(location) {
            if let session = session {
                handleHit(at: location, session: session)
            } else {
                presentSetupVC()
            }
        }
    }
    
    private func handleHit(at position: CGPoint, session: VentingSession) {
        // Apply Damage
        let damage = session.applyHit(weapon: currentWeapon)
        
        // 1. Visual crack
        let overlay = DamageOverlayView(center: position, impactLevel: currentWeapon.impactLevel, currentLevel: session.currentLevel)
        targetContainerView.addSubview(overlay)
        
        // Limit maximum visual cracks to prevent memory/performance issues
        let maxCracks = 200
        let activeCracks = targetContainerView.subviews.compactMap { $0 as? DamageOverlayView }.filter { $0.tag != 999 }
        if activeCracks.count > maxCracks {
            if let oldest = activeCracks.first {
                oldest.tag = 999 // Mark as dying so it isn't targeted again
                UIView.animate(withDuration: 0.5, animations: {
                    oldest.alpha = 0
                }) { _ in
                    oldest.removeFromSuperview()
                }
            }
        }
        
        // 2. Score Bar Update
        let generator = UIImpactFeedbackGenerator(style: currentWeapon.impactLevel == .heavy ? .heavy : .light)
        generator.prepare()
        
        UIView.transition(with: scoreLabel, duration: 0.1, options: .transitionCrossDissolve, animations: {
            self.scoreLabel.text = "\(session.accumulatedVentingValue)"
        }, completion: nil)
        
        // Popup damage label (mimicking losing health)
        showDamagePopup(at: position, damage: damage)
        
        // 2.5 Dynamic Weapon Hit Animation
        showWeaponHitAnimation(at: position, weapon: currentWeapon)
        
        // 3. Haptics
        generator.impactOccurred()
        
        // 4. Full Screen Impact (scaled by weapon & level)
        triggerFullScreenImpact(level: session.currentLevel, isHeavy: currentWeapon.impactLevel == .heavy)
        
        // Check Ultimate Threshold
        if session.hasHitThreshold {
            promptLevelUp(session: session)
        }
    }
    
    private func showDamagePopup(at position: CGPoint, damage: Int) {
        let lbl = UILabel()
        lbl.text = "-\(damage)"
        lbl.textColor = .systemYellow
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        lbl.sizeToFit()
        lbl.center = position
        targetContainerView.addSubview(lbl)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            lbl.center.y -= 50
            lbl.alpha = 0
            lbl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            lbl.removeFromSuperview()
        })
    }
    
    private func showWeaponHitAnimation(at position: CGPoint, weapon: WeaponModel) {
        let weaponLbl = UILabel()
        weaponLbl.text = weapon.iconEmoji
        
        // Scale based on selected weapon weight/impactLevel
        let baseSize: CGFloat = weapon.impactLevel == .heavy ? 120 : 60
        weaponLbl.font = UIFont.systemFont(ofSize: baseSize)
        
        weaponLbl.sizeToFit()
        targetContainerView.addSubview(weaponLbl)
        
        // Start position (slightly right and top)
        let offsetX: CGFloat = 80
        let offsetY: CGFloat = -100
        weaponLbl.center = CGPoint(x: position.x + offsetX, y: position.y + offsetY)
        weaponLbl.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4).scaledBy(x: 1.5, y: 1.5)
        
        // Whack! (Animate down to target point quickly)
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            weaponLbl.center = position
            weaponLbl.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 8).scaledBy(x: 0.8, y: 0.8)
        }, completion: { _ in
            // Fade out
            UIView.animate(withDuration: 0.2, animations: {
                weaponLbl.alpha = 0
            }, completion: { _ in
                weaponLbl.removeFromSuperview()
            })
        })
    }
    
    private func triggerFullScreenImpact(level: Int, isHeavy: Bool) {
        // Flash logic
        flashView.alpha = isHeavy ? 0.4 : 0.2
        UIView.animate(withDuration: 0.2, animations: {
            self.flashView.alpha = 0
        })
        
        // Screen Shake (Container + Main View)
        let intensity: CGFloat = isHeavy ? 10.0 : 5.0
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.3
        animation.values = [-intensity, intensity, -intensity*0.8, intensity*0.8, -intensity*0.5, intensity*0.5, 0.0]
        
        targetContainerView.layer.add(animation, forKey: "shake")
        
        if isHeavy {
            // Intense whole screen shake for heavy hits
            view.layer.add(animation, forKey: "globalShake")
        }
    }
    
    private func promptLevelUp(session: VentingSession) {
        // Temporarily disable interactions
        view.isUserInteractionEnabled = false
        
        let alertVC = LevelUpAlertViewController()
        alertVC.session = session
        alertVC.sessionLevel = session.currentLevel
        alertVC.accumulatedValue = session.accumulatedVentingValue
        alertVC.modalPresentationStyle = .overFullScreen
        alertVC.modalTransitionStyle = .crossDissolve
        
        alertVC.onDestruct = { [weak self] in
            self?.triggerUltimateDestruction()
        }
        
        alertVC.onContinue = { [weak self] in
            session.levelUp()
            self?.view.isUserInteractionEnabled = true
        }
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func triggerUltimateDestruction() {
        print("Triget Ultimate Destruction!")
        
        var targetDisplayName = "目标"
        
        // Save the stats
        if let currentSession = session {
            switch currentSession.target.type {
            case .text(let text): targetDisplayName = text
            case .image(_): targetDisplayName = "发泄对象"
            }
            
            let record = VentingRecord(sessionId: currentSession.id,
                                       targetName: targetDisplayName,
                                       totalVentingScore: currentSession.accumulatedVentingValue,
                                       energyValue: currentSession.energyValue,
                                       weaponUsedTimes: currentSession.strikesCount)
            RecordManager.shared.saveOrUpdate(record: record)
            RecordManager.shared.printRecentStatistics()
        }
        
        
        // 1. 声音反馈（调用系统重音提示音，实际项目可替换为音效文件）
        // For a more explosive sound stack
        AudioServicesPlaySystemSound(1322) // Deep impact
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            AudioServicesPlaySystemSound(1053) // Follow up crack
        }
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        // 2. 连续剧烈震动 (Rumble Haptics)
        let rumble = UINotificationFeedbackGenerator()
        rumble.prepare()
        rumble.notificationOccurred(.error)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
        
        // 3. 仿微信炸弹特效 (Shockwave + Flash)
        showWeChatBombExplosion()
        
        // 4. 超大振幅全屏晃动
        let intensity: CGFloat = 40.0
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.y")
        shake.timingFunction = CAMediaTimingFunction(name: .linear)
        shake.duration = 0.6
        shake.values = [-intensity, intensity, -intensity*0.8, intensity*0.8, -intensity*0.4, intensity*0.4, 0.0]
        view.layer.add(shake, forKey: "destructionShake")
        
        // 隐藏工具栏UI
        UIView.animate(withDuration: 0.2) {
            self.scoreTitleLabel.alpha = 0
            self.scoreLabel.alpha = 0
            self.toolbar.alpha = 0
            self.setupBtn.alpha = 0
            self.tipBtn.alpha = 0
            self.recordsBtn.alpha = 0
        }
        
        showFireballExplosion(on: targetContainerView) { [weak self] in
            guard let self = self else { return }
            
            // Show Motivational Alert after it fully crushes
            let cheerWords = [
                "允许自己偶尔崩溃，也允许自己被慢慢治愈。",
                "把那些烂人烂事，统统隔绝在你的光芒之外。",
                "你不需要总是那么坚强，累了就放下防备休息一下吧。",
                "所有的坏情绪在这里终结，接下来全是好运气。",
                "今天真的辛苦了，其实你做得比你想象的还要好。",
                "生活难免充满泥沙，但你依然可以开出属于自己的花。",
                "别让短暂的阴霾，遮挡了你身上原有的万丈光芒。",
                "每一次畅快的发泄，都是为了腾出心里空间来装下新的快乐。",
                "不必在意他人的眼光，你只需要好好爱护你自己。",
                "遗憾和愤怒都被干脆地粉碎了，深呼吸，原谅这不完美的一天。",
                "不管今天经历了什么，这浩瀚的宇宙依然深爱着你。",
                "那些曾经拖累你的，终将让你变得更加强大且温柔。",
                "慢慢来，谁不是翻山越岭，去与那个更好的自己相遇呢？",
                "释放掉心底淤积的乌云，明天你的世界一定会拨云见日。",
                "发泄完就翻篇吧，你值得这世间所有最纯粹的美好。"
            ]
            let randomCheer = cheerWords.randomElement() ?? "你是最好的！"
            
            let energyPopup = EnergyPopupViewController()
            energyPopup.energyValue = self.session?.energyValue ?? 0
            energyPopup.cheerText = randomCheer
            energyPopup.modalPresentationStyle = .overFullScreen
            energyPopup.modalTransitionStyle = .crossDissolve
            
            energyPopup.onReceiveEnergy = { [weak self, weak energyPopup] in
                guard let self = self, let popup = energyPopup else { return }
                
                // Hide popup content to focus on animation
                UIView.animate(withDuration: 0.2) {
                    popup.receiveButton.alpha = 0
                }
                
                // Animate Sun flying to Records button
                let sunView = UIImageView(image: UIImage(systemName: "sun.max.fill"))
                sunView.tintColor = .systemYellow
                sunView.contentMode = .scaleAspectFit
                sunView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                sunView.center = popup.view.center
                
                popup.view.addSubview(sunView)
                
                // Get the records button position in popup's coordinate space
                let targetRect = self.recordsBtn.convert(self.recordsBtn.bounds, to: popup.view)
                let targetCenter = CGPoint(x: targetRect.midX, y: targetRect.midY)
                
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut, animations: {
                    sunView.center = targetCenter
                    sunView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    sunView.alpha = 0.5
                }) { _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    popup.dismiss(animated: true) {
                        self.session = nil
                        // Resume UI
                        UIView.animate(withDuration: 0.3) {
                            self.scoreTitleLabel.alpha = 1
                            self.scoreLabel.alpha = 1
                            self.toolbar.alpha = 1
                            self.setupBtn.alpha = 1
                            self.tipBtn.alpha = 1
                            self.recordsBtn.alpha = 1
                        }
                        self.view.isUserInteractionEnabled = true
                        self.presentSetupVC()
                    }
                }
            }
            
            self.present(energyPopup, animated: true)
        }
    }
    
    private func showWeChatBombExplosion() {
        // 1. Expanding shockwave ring
        let circle = CAShapeLayer()
        let center = view.center
        let startPath = UIBezierPath(arcCenter: center, radius: 10, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let endPath = UIBezierPath(arcCenter: center, radius: view.bounds.height, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        circle.path = endPath.cgPath
        circle.fillColor = UIColor.clear.cgColor
        circle.strokeColor = UIColor.systemOrange.withAlphaComponent(0.8).cgColor
        circle.lineWidth = 40
        view.layer.addSublayer(circle)
        
        let pathAnim = CABasicAnimation(keyPath: "path")
        pathAnim.fromValue = startPath.cgPath
        pathAnim.toValue = endPath.cgPath
        
        let widthAnim = CABasicAnimation(keyPath: "lineWidth")
        widthAnim.fromValue = 60
        widthAnim.toValue = 0
        
        let alphaAnim = CABasicAnimation(keyPath: "opacity")
        alphaAnim.fromValue = 1.0
        alphaAnim.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [pathAnim, widthAnim, alphaAnim]
        group.duration = 0.5
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        circle.add(group, forKey: "shockwave")
        
        // Remove layer after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            circle.removeFromSuperlayer()
        }
        
        // 2. Fire particles burst
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = center
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 50, height: 50)
        
        let cell = CAEmitterCell()
        cell.birthRate = 200
        cell.lifetime = 1.0
        cell.velocity = 300
        cell.velocityRange = 100
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleSpeed = -0.05
        cell.color = UIColor.systemRed.cgColor
        // Using a built-in character as image since we don't have images
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 20, height: 20))
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: CGRect(x: 0, y: 0, width: 20, height: 20))
        }
        cell.contents = img.cgImage
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
        // Stop emitting almost instantly to create a burst
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            emitter.removeFromSuperlayer()
        }
        
        // 3. Intense Flame Flash (Orange/Yellow)
        let flameFlash = UIView(frame: view.bounds)
        flameFlash.backgroundColor = UIColor.systemOrange
        flameFlash.alpha = 0.8
        view.addSubview(flameFlash)
        
        UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseOut, animations: {
            flameFlash.backgroundColor = .white
            flameFlash.alpha = 0
        }, completion: { _ in
            flameFlash.removeFromSuperview()
        })
    }
    
    private func showFireballExplosion(on targetView: UIView, completion: @escaping () -> Void) {
        // Disable target view
        targetView.isUserInteractionEnabled = false
        
        let center = targetView.center
        
        // 1. Particle fireball burst
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = center
        emitter.emitterShape = .circle
        emitter.emitterSize = CGSize(width: 50, height: 50)
        
        let cell = CAEmitterCell()
        cell.birthRate = 120
        cell.lifetime = 1.5
        cell.velocity = 600
        cell.velocityRange = 300
        cell.emissionRange = .pi * 2
        cell.spin = 3
        cell.spinRange = 6
        cell.scale = 1.0
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.5
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 60, height: 60))
        let img = renderer.image { ctx in
            let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 50)]
            ("☄️" as NSString).draw(at: CGPoint(x: 5, y: 5), withAttributes: attrs)
        }
        cell.contents = img.cgImage
        
        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
        
        // Let's add an inner red/white core fireball that grows huge
        let fireball = UIView()
        fireball.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        fireball.center = center
        fireball.backgroundColor = .systemRed
        fireball.layer.cornerRadius = 5
        fireball.layer.shadowColor = UIColor.systemYellow.cgColor
        fireball.layer.shadowRadius = 20
        fireball.layer.shadowOpacity = 1.0
        fireball.alpha = 1.0
        view.addSubview(fireball)
        
        // 2. Animate the target view scaling and fading, and fireball expanding
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            targetView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                targetView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                targetView.alpha = 0
                
                // Explode the fireball to engulf the area
                fireball.transform = CGAffineTransform(scaleX: 100, y: 100)
                fireball.backgroundColor = .systemYellow
                fireball.alpha = 0
            }) { _ in
                targetView.transform = .identity
                fireball.removeFromSuperview()
                completion()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            emitter.birthRate = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            emitter.removeFromSuperlayer()
        }
    }
}
