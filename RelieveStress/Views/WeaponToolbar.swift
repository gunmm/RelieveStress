import UIKit

protocol WeaponToolbarDelegate: AnyObject {
    func didSelectWeapon(_ weapon: WeaponModel)
}

class WeaponToolbar: UIView {
    
    weak var delegate: WeaponToolbarDelegate?
    private var weapons: [WeaponModel] = WeaponModel.availableWeapons
    private var buttons: [UIButton] = []
    
    // StackView to hold weapon buttons
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6.withAlphaComponent(0.9)
        layer.cornerRadius = 24
        
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
        
        for (index, weapon) in weapons.enumerated() {
            let btn = createWeaponButton(for: weapon, tag: index)
            buttons.append(btn)
            stackView.addArrangedSubview(btn)
        }
        
        // Select first weapon by default
        if !buttons.isEmpty {
            weaponSelected(buttons[0])
        }
    }
    
    private func createWeaponButton(for weapon: WeaponModel, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.tag = tag
        btn.setTitle(weapon.iconEmoji, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        btn.backgroundColor = .systemBackground
        btn.layer.cornerRadius = 16
        // Small shadow
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        
        btn.addTarget(self, action: #selector(weaponSelected(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc private func weaponSelected(_ sender: UIButton) {
        // Highlight logic
        for btn in buttons {
            btn.layer.borderWidth = 0
            btn.layer.borderColor = UIColor.clear.cgColor
            btn.transform = .identity
        }
        
        sender.layer.borderWidth = 3
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        
        UIView.animate(withDuration: 0.2, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
        
        let weapon = weapons[sender.tag]
        delegate?.didSelectWeapon(weapon)
    }
}
