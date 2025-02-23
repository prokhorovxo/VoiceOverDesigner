import Foundation

#if canImport(AppKit)
import AppKit

public typealias Font = NSFont
#elseif canImport(UIKit)
import UIKit
public typealias Font = UIFont
#endif

extension A11yDescription {
    
    @available(macOS 12, *)
    @available(iOS 15, *)
    public func voiceOverTextAttributed(font: Font?) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        if trait.contains(.selected) {
            result += "\(Localization.traitSelectedDescription) \(label)"
        } else {
            result += label
        }
        
        if !value.isEmpty {
            let valueString = isAdjustable ? (adjustableOptions.currentValue ?? "") : value
            result += ": \(valueString.italic)"
        }
        
        var traitsDescription = self.traitDescription

        if !hint.isEmpty {
            traitsDescription.append("\(hint)")
        }

        if result.isEmpty && traitsDescription.isEmpty {
            result += Localization.traitEmptyDescription.italic
        }

        if !traitsDescription.isEmpty {
            if result.isEmpty {
                result += traitsDescription.joined(separator: " ")
            } else {
                let trailingPeriod = result.string.hasSuffix(".") ? "" : "."
                result += NSAttributedString(string: trailingPeriod + " ")
                let trait = traitsDescription.joined(separator: " ")
                result += trait.markdown(color: .color(for: self))
            }
        } else {
            result.addAttribute(.foregroundColor, value: Color.label, range: result.string.fullRange)
        }
        
        if let font = font {
            result.addAttribute(.font, value: font, range: result.string.fullRange)
        }
        
        return result
    }
    
    private var traitDescription: [String] {
        var traitsDescription: [String] = []
        
        if trait.contains(.notEnabled) {
            traitsDescription.append(Localization.traitNotEnabledDescription)
        }
        
        if trait.contains(.button) {
            traitsDescription.append(Localization.traitButtonDescription)
        }
        
        if trait.contains(.switcher) {
            traitsDescription.append(Localization.traitSwitcherDescription)
        }
        
        if trait.contains(.adjustable) {
            traitsDescription.append(Localization.traitAdjustableDescription)
        }
        
        if trait.contains(.header) {
            traitsDescription.append(Localization.traitHeaderDescription)
        }
        
        // TODO: Test order when all enabled
        if trait.contains(.image) {
            traitsDescription.append(Localization.traitImageDescription)
        }
        
        if trait.contains(.link) {
            traitsDescription.append(Localization.traitLinkDescription)
        }
        
        if trait.contains(.textInput) {
            traitsDescription.append(Localization.traitTextInputDescription)
        }
        
        if trait.contains(.isEditingTextInput) {
            traitsDescription.append(Localization.traitIsEdititngInputDescription)
        }
        
        return traitsDescription
    }
    
    @available(macOS 12, *)
    @available(iOS 15, *)
    public var voiceOverText: String {
        voiceOverTextAttributed(font: nil).string
    }
}

extension String {
    var fullRange: NSRange {
        NSRange(location: 0, length: count)
    }
}
