import Foundation

enum ConditionTargetValidator {
    static func validate(type: ConditionType, targetValue: Decimal) throws {
        if type == .streak {
            guard isPositiveInteger(targetValue) else {
                throw DomainError.invalidInput("连续坚持的目标值必须为正整数。")
            }
        } else {
            guard targetValue > 0 else {
                throw DomainError.invalidInput("条件目标值必须大于 0。")
            }
        }
    }

    static func isPositiveInteger(_ value: Decimal) -> Bool {
        guard value > 0 else { return false }

        let number = NSDecimalNumber(decimal: value)
        let rounded = number.rounding(accordingToBehavior: integerRoundingBehavior)
        return number.compare(rounded) == .orderedSame
    }

    private static let integerRoundingBehavior = NSDecimalNumberHandler(
        roundingMode: .plain,
        scale: 0,
        raiseOnExactness: false,
        raiseOnOverflow: false,
        raiseOnUnderflow: false,
        raiseOnDivideByZero: false
    )
}
