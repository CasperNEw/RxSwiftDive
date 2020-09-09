//
//  String+.swift
//  RxSwiftDive
//
//  Created by Дмитрий Константинов on 09.09.2020.
//  Copyright © 2020 Дмитрий Константинов. All rights reserved.
//

import Foundation

extension String {

    func titleCase() -> String {

        return self
            .replacingOccurrences(of: "([A-Z])",
                                  with: " $1",
                                  options: .regularExpression,
                                  range: range(of: self))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized
    }
}
