import Foundation

public func format<I: BinaryInteger>(_ type: I.Type = I.self) -> IntegerFormatStyle<I> {
  return IntegerFormatStyle<I>()
}

public func fixedWidthFormat<I: BinaryInteger>(
  _ type: I.Type = I.self,
  width: Int,
  grouping: Bool = false
) -> IntegerFormatStyle<I> {
  return format(type)
    .precision(.integerLength(width))
    .grouping(grouping ? .automatic : .never)
}
