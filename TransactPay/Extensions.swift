//
//  Extensions.swift
//  TransactPay
//
//  Created by James Anyanwu on 11/11/24.
//

import Foundation

extension String {
    func toMoneyFormat() -> String? {
        let pattern = "([A-Z]{3})(\\d+)"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let nsString = self as NSString
        let results = regex.firstMatch(in: self, range: NSRange(location: 0, length: nsString.length))
        
        guard let match = results else { return nil }
        
        let currencyCode = nsString.substring(with: match.range(at: 1))
        let amountString = nsString.substring(with: match.range(at: 2))
        
        guard let amount = Double(amountString) else { return nil }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? amountString
        
        return "\(currencyCode)\(formattedAmount)"
    }
}
