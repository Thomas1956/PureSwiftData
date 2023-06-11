//
//  ListHeaderView.swift
//  PureSwiftData
//
//  Created by Thomas on 11.06.23.
//

import UIKit


class ListHeaderView: UICollectionReusableView {
    static var elementKind: String { UICollectionView.elementKindSectionHeader }
    
    private let buttonSelect = ActivateButton(identifier: nil)
    private let labelName = UILabel(frame: .zero)
    
    var onButtonClick: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareSubviews()
    }

    /// Setzen des Callbacks
    func initialize(action: @escaping (Bool) -> Void = {_ in}) {
        self.onButtonClick = action
    }

    func configure(title: String) {
        labelName.text = title
    }
    
    //----------------------------------------------------------------------------------------
    /// Voreingestellte Größen. Die Höhe der Zelle wird automatisch eingestellt.
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 60)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func prepareSubviews() {
        self.backgroundColor = UIColor(white: 0, alpha: 0.05)
        labelName.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        buttonSelect.addTarget(self, action: #selector(didPressActiveButton(_:)), for: .touchUpInside)

        addSubview(buttonSelect)
        addSubview(labelName)

        buttonSelect.translatesAutoresizingMaskIntoConstraints = false
        labelName.translatesAutoresizingMaskIntoConstraints = false
 
        NSLayoutConstraint.activate([
            buttonSelect.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            buttonSelect.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            buttonSelect.widthAnchor.constraint(equalToConstant: 25),
            
            labelName.leadingAnchor.constraint(equalTo: buttonSelect.trailingAnchor, constant: 15),
            labelName.trailingAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.trailingAnchor),
            labelName.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            heightAnchor.constraint(equalToConstant: intrinsicContentSize.height)
        ])
    }
    
    @objc func didPressActiveButton(_ activateButton: ActivateButton) {
        buttonSelect.isActive.toggle()
        onButtonClick?(buttonSelect.isActive)
    }

}
