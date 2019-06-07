//
//  Array+SKPhotoBrowser.swift
//  SKPhotoBrowser
//
//  Created by Елизаров Владимир Алексеевич on 05/06/2019.
//

import Foundation

extension Array {
    func take(last: Index) -> [Element] {
        let maxIndex = self.endIndex
        let minIndex = Swift.max(self.endIndex - last, self.startIndex)
        return Array(self[minIndex..<maxIndex])
    }
}
