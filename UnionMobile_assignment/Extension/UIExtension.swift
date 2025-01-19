//
//  UIExtension.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import SwiftUI

// MARK: - 커스텀 폰트
extension Font {
    enum Family: String {
        case bold,boldItalic,extraLight,italic,light,lightItalic,medium,mediumItalic,regular,semiBold,semiBoldItalic,thin,thinItalic
    }
    
    static func kantumruyPro(size: CGFloat, family: Family) -> Font {
        return Font.custom("KantumruyPro-\(family)", size: size)
    }
}
