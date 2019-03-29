//
//  PaddingLabel.swift
//  ParkItIOS
//
//  Created by Hadar Pur on 27/03/2019.
//  Copyright © 2019 Hadar Pur. All rights reserved.
//

import Foundation
import UIKit

class PaddingLabel: UILabel {
    let mPadding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: mPadding))
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + mPadding.left + mPadding.right
        let height = superSizeThatFits.height + mPadding.top + mPadding.bottom
        return CGSize(width: width, height: height)
    }
}
