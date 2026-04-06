import UIKit
import PhotosUI

protocol TargetSetupDelegate: AnyObject {
    func didSetupTarget(_ target: TargetModel)
}

class TargetSetupViewController: UIViewController, PHPickerViewControllerDelegate {
    
    weak var delegate: TargetSetupDelegate?
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "选择发泄对象"
        lbl.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let segmentControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["🖼 照片", "🏷 文字"])
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let contentArea: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    // MARK: - Text Tab Views
    private let textContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = true
        return v
    }()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "输入让他毁灭的名字或短语..."
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 18)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private let textSubmitBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("生成发泄文字", for: .normal)
        btn.backgroundColor = .systemRed
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let presetScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        // Hide scroll indicators
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let presetVerticalStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // MARK: - Photo Tab Views
    private let photoContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.isHidden = false
        return v
    }()
    private let photoBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("从相册选择发泄目标", for: .normal)
        btn.backgroundColor = .systemBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        setupPresets()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(segmentControl)
        view.addSubview(contentArea)
        
        contentArea.addSubview(textContainer)
        contentArea.addSubview(photoContainer)
        
        textContainer.addSubview(textField)
        textContainer.addSubview(textSubmitBtn)
        textContainer.addSubview(presetScrollView)
        presetScrollView.addSubview(presetVerticalStack)
        
        photoContainer.addSubview(photoBtn)
        
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        textSubmitBtn.addTarget(self, action: #selector(textSubmitTapped), for: .touchUpInside)
        photoBtn.addTarget(self, action: #selector(photoBtnTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            segmentControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            contentArea.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            contentArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Text Container
            textContainer.topAnchor.constraint(equalTo: contentArea.topAnchor),
            textContainer.leadingAnchor.constraint(equalTo: contentArea.leadingAnchor),
            textContainer.trailingAnchor.constraint(equalTo: contentArea.trailingAnchor),
            textContainer.bottomAnchor.constraint(equalTo: contentArea.bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: textContainer.topAnchor, constant: 10),
            textField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 44),
            
            textSubmitBtn.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15),
            textSubmitBtn.centerXAnchor.constraint(equalTo: textContainer.centerXAnchor),
            textSubmitBtn.widthAnchor.constraint(equalToConstant: 200),
            textSubmitBtn.heightAnchor.constraint(equalToConstant: 44),
            
            presetScrollView.topAnchor.constraint(equalTo: textSubmitBtn.bottomAnchor, constant: 30),
            presetScrollView.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 20),
            presetScrollView.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -20),
            presetScrollView.bottomAnchor.constraint(equalTo: textContainer.bottomAnchor, constant: -20),
            
            presetVerticalStack.topAnchor.constraint(equalTo: presetScrollView.topAnchor),
            presetVerticalStack.leadingAnchor.constraint(equalTo: presetScrollView.leadingAnchor),
            presetVerticalStack.trailingAnchor.constraint(equalTo: presetScrollView.trailingAnchor),
            presetVerticalStack.bottomAnchor.constraint(equalTo: presetScrollView.bottomAnchor),
            presetVerticalStack.widthAnchor.constraint(equalTo: presetScrollView.widthAnchor),
            
            // Photo Container
            photoContainer.topAnchor.constraint(equalTo: contentArea.topAnchor),
            photoContainer.leadingAnchor.constraint(equalTo: contentArea.leadingAnchor),
            photoContainer.trailingAnchor.constraint(equalTo: contentArea.trailingAnchor),
            photoContainer.bottomAnchor.constraint(equalTo: contentArea.bottomAnchor),
            
            photoBtn.topAnchor.constraint(equalTo: photoContainer.topAnchor, constant: 40),
            photoBtn.centerXAnchor.constraint(equalTo: photoContainer.centerXAnchor),
            photoBtn.widthAnchor.constraint(equalToConstant: 200),
            photoBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupPresets() {
        let groupedPresets = TargetType.categorizedPresets
        
        for group in groupedPresets {
            // Category Title
            let catLabel = UILabel()
            catLabel.text = group.category
            catLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            catLabel.textColor = .secondaryLabel
            
            // Horizontal Scroll for buttons to prevent overflowing
            let tagsHScrollView = UIScrollView()
            tagsHScrollView.showsHorizontalScrollIndicator = false
            
            let tagsStack = UIStackView()
            tagsStack.axis = .horizontal
            tagsStack.spacing = 10
            tagsStack.translatesAutoresizingMaskIntoConstraints = false
            
            for tagText in group.tags {
                let btn = UIButton(type: .system)
                btn.setTitle(tagText, for: .normal)
                btn.backgroundColor = .systemBackground
                btn.setTitleColor(.systemBlue, for: .normal)
                btn.layer.cornerRadius = 16
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.3).cgColor
                btn.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                btn.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
                tagsStack.addArrangedSubview(btn)
            }
            
            tagsHScrollView.addSubview(tagsStack)
            
            NSLayoutConstraint.activate([
                tagsStack.leadingAnchor.constraint(equalTo: tagsHScrollView.leadingAnchor),
                tagsStack.trailingAnchor.constraint(equalTo: tagsHScrollView.trailingAnchor),
                tagsStack.topAnchor.constraint(equalTo: tagsHScrollView.topAnchor),
                tagsStack.bottomAnchor.constraint(equalTo: tagsHScrollView.bottomAnchor),
                tagsStack.heightAnchor.constraint(equalTo: tagsHScrollView.heightAnchor)
            ])
            tagsHScrollView.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            // Wrapper stack for title and tags
            let sectionStack = UIStackView(arrangedSubviews: [catLabel, tagsHScrollView])
            sectionStack.axis = .vertical
            sectionStack.spacing = 10
            
            presetVerticalStack.addArrangedSubview(sectionStack)
        }
    }
    
    @objc private func segmentChanged() {
        let isPhotoTab = segmentControl.selectedSegmentIndex == 0
        textContainer.isHidden = isPhotoTab
        photoContainer.isHidden = !isPhotoTab
        view.endEditing(true)
    }
    
    @objc private func presetTapped(_ sender: UIButton) {
        guard let text = sender.titleLabel?.text else { return }
        let model = TargetModel(type: .text(text))
        delegate?.didSetupTarget(model)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textSubmitTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        let model = TargetModel(type: .text(text))
        delegate?.didSetupTarget(model)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func photoBtnTapped() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            guard let self = self, let uiImage = image as? UIImage else { return }
            DispatchQueue.main.async {
                let model = TargetModel(type: .image(uiImage))
                self.delegate?.didSetupTarget(model)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
