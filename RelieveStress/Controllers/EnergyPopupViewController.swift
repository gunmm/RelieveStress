import UIKit

class EnergyPopupViewController: UIViewController {

    var energyValue: Int = 0
    var cheerText: String = ""
    var onReceiveEnergy: (() -> Void)?

    private let backgroundView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.15)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 24
        v.layer.shadowColor = UIColor.systemOrange.cgColor
        v.layer.shadowOpacity = 0.4
        v.layer.shadowOffset = CGSize(width: 0, height: 10)
        v.layer.shadowRadius = 20
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let sunImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "sun.max.fill")
        iv.tintColor = .systemYellow
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = cheerText
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        lbl.textColor = .label
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let energyTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "让烦恼已随风消散，化作温暖的☀️"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private lazy var energyValueLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "+\(energyValue)"
        lbl.font = UIFont.systemFont(ofSize: 48, weight: .heavy)
        lbl.textColor = .systemOrange
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    let receiveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("我是最棒的 ☀️", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemOrange
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.layer.cornerRadius = 25
        btn.layer.shadowColor = UIColor.systemOrange.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 5)
        btn.layer.shadowRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Blur effect for overall background
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)

        setupUI()
        
        containerView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        containerView.alpha = 0
        
        receiveButton.addTarget(self, action: #selector(receiveButtonTapped), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
            self.containerView.transform = .identity
            self.containerView.alpha = 1
        })
        
        // Gentle rotation for the sun icon
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = 10.0
        rotation.repeatCount = .infinity
        rotation.isRemovedOnCompletion = false
        sunImageView.layer.add(rotation, forKey: "spin")
        
        // Pulse energy label
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.1
        pulse.duration = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        energyValueLabel.layer.add(pulse, forKey: "pulse")
    }

    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(sunImageView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(energyTitleLabel)
        containerView.addSubview(energyValueLabel)
        containerView.addSubview(receiveButton)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            
            sunImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -40),
            sunImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sunImageView.widthAnchor.constraint(equalToConstant: 100),
            sunImageView.heightAnchor.constraint(equalToConstant: 100),
            
            messageLabel.topAnchor.constraint(equalTo: sunImageView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            energyTitleLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            energyTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            energyTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            energyValueLabel.topAnchor.constraint(equalTo: energyTitleLabel.bottomAnchor, constant: 10),
            energyValueLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            receiveButton.topAnchor.constraint(equalTo: energyValueLabel.bottomAnchor, constant: 40),
            receiveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            receiveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            receiveButton.heightAnchor.constraint(equalToConstant: 50),
            receiveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30)
        ])
    }

    @objc private func receiveButtonTapped() {
        // First hide everything but the background to prepare for the animation out, or just pass back action
        onReceiveEnergy?()
    }
}
