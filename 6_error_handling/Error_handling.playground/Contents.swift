import UIKit

// Error handling

// Define our custom error type
enum DivisionErrors: Error {
    case stringIsNotNumber
    case tryingToDivideByZero
}


// Throws indicate that a function can fail and emit an error
func divide(_ number1: String,by number2: String) throws -> Double {
    
    guard let number1 = Double(number1) else {
        throw DivisionErrors.stringIsNotNumber
    }
    
    guard let number2 = Double(number2) else {
        throw DivisionErrors.stringIsNotNumber
    }
    
    if number2 == 0 {
        throw DivisionErrors.tryingToDivideByZero
    }
    
    return number1 / number2
}


// To run a throwing function we must call it from do catch block

do {
    let result = try divide("1", by: "1")
    print(result)
} catch DivisionErrors.stringIsNotNumber {
    print("String is not a number.")
} catch DivisionErrors.tryingToDivideByZero {
    print("It is not possible to divide by zero.")
}
