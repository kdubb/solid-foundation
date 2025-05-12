//
//  Formats.swift
//  SolidFoundation
//
//  Created by Kevin Wooten on 1/31/25.
//

import Foundation

package func format<I: BinaryInteger>(_ type: I.Type = I.self) -> IntegerFormatStyle<I> {
  return IntegerFormatStyle<I>()
}

package func fixedWidthFormat<I: BinaryInteger>(
  _ type: I.Type = I.self,
  width: Int,
  grouping: Bool = false
) -> IntegerFormatStyle<I> {
  return format(type)
    .precision(.integerLength(width))
    .grouping(grouping ? .automatic : .never)
}
