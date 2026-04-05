import UIKit

class RecordsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let records = RecordManager.shared.fetchAllRecords().sorted { $0.date > $1.date }
    
    private let headerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let totalEnergyLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 48, weight: .heavy)
        lbl.textColor = .systemOrange
        lbl.textAlignment = .center
        lbl.layer.shadowColor = UIColor.systemYellow.cgColor
        lbl.layer.shadowOpacity = 0.5
        lbl.layer.shadowOffset = CGSize(width: 0, height: 2)
        lbl.layer.shadowRadius = 10
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let totalEnergyTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "累计发泄收集☀️"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(RecordCell.self, forCellReuseIdentifier: "RecordCell")
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "发泄历史"
        view.backgroundColor = .systemGroupedBackground
        
        let closeBtn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.rightBarButtonItem = closeBtn
        
        setupUI()
        
        let total = records.reduce(0) { $0 + $1.energyValue }
        totalEnergyLabel.text = "\(total)"
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupUI() {
        view.addSubview(headerView)
        headerView.addSubview(totalEnergyTitle)
        headerView.addSubview(totalEnergyLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 160),
            
            totalEnergyTitle.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
            totalEnergyTitle.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            totalEnergyLabel.topAnchor.constraint(equalTo: totalEnergyTitle.bottomAnchor, constant: 10),
            totalEnergyLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordCell
        let record = records[indexPath.row]
        cell.configure(with: record)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

class RecordCell: UITableViewCell {

    private let targetLabel = UILabel()
    private let dateLabel = UILabel()
    private let statsLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        targetLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        targetLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        statsLabel.textColor = .systemOrange
        statsLabel.textAlignment = .right
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(targetLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            targetLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            targetLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            targetLabel.trailingAnchor.constraint(equalTo: statsLabel.leadingAnchor, constant: -10),
            
            dateLabel.topAnchor.constraint(equalTo: targetLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: targetLabel.leadingAnchor),
            
            statsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with record: VentingRecord) {
        let titleText = "释放怒气值: "
        let valueText = "\(record.totalVentingScore)"
        let attributedString = NSMutableAttributedString(string: titleText + valueText)
        
        let valueRange = NSRange(location: titleText.count, length: valueText.count)
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemRed, range: valueRange)
        
        targetLabel.attributedText = attributedString
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateLabel.text = formatter.string(from: record.date)
        
        statsLabel.text = "+\(record.energyValue) ✨"
    }
}
