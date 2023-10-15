//
//  CurrencyTextField.swift
//  Celery
//
//  Created by Skylar Clemens on 10/15/23.
//

import Foundation
import UIKit
import SwiftUI

struct CurrencyTextField: UIViewRepresentable {
    typealias UIViewType = CurrencyUITextField
    
    let formatter: NumberFormatter
    let currencyTextField: CurrencyUITextField
    
    init(value: Binding<Double>, formatter: NumberFormatter) {
        self.formatter = formatter
        self.currencyTextField = CurrencyUITextField(value: value, formatter: formatter)
    }
    
    func makeUIView(context: Context) -> CurrencyUITextField {
        return currencyTextField
    }
    
    func updateUIView(_ uiView: CurrencyUITextField, context: Context) { }
}

class CurrencyUITextField: UITextField {
    @Binding private var value: Double
    private let formatter: NumberFormatter
    var locale: Locale = .current {
        didSet {
            formatter.locale = locale
            sendActions(for: .editingChanged)
        }
    }
    
    init(value: Binding<Double>, formatter: NumberFormatter) {
        self._value = value
        self.formatter = formatter
        super.init(frame: .zero)
        setupView()
    }
    
    private var textVal: String { text ?? "" }
    
    private var doubleVal: Double { (decimal as NSDecimalNumber).doubleValue }
    
    private var decimal: Decimal { textVal.decimal / pow(10, formatter.maximumFractionDigits) }
    
    private func currency(from decimal: Decimal) -> String { formatter.string(for: decimal) ?? "" }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addTarget(self, action: #selector(resetSelectedText), for: .allTouchEvents)
        keyboardType = .numberPad
        textAlignment = .center
        sendActions(for: .editingChanged)
    }
    
    override func deleteBackward() {
        text = String(textVal.dropLast())
        sendActions(for: .editingChanged)
    }
    
    private func setupView() {
        font = .systemFont(ofSize: 32, weight: .semibold)
        if value > 0 {
            let decimalValue = Decimal(value / 100.0)
            text = currency(from: decimalValue)
        }
    }
    
    @objc private func resetSelectedText() {
        selectedTextRange = textRange(from: endOfDocument, to: endOfDocument)
    }
    
    @objc private func editingChanged() {
        text = currency(from: decimal)
        resetSelectedText()
        updateValue()
    }
    
    private func updateValue() {
        DispatchQueue.main.async { [weak self] in
            self?.value = self?.doubleVal ?? 0
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StringProtocol where Self: RangeReplaceableCollection {
    var digits: Self { filter (\.isWholeNumber) }
}

extension String {
    var decimal: Decimal { Decimal(string: digits) ?? 0 }
}

extension LosslessStringConvertible {
    var string: String { .init(self) }
}
