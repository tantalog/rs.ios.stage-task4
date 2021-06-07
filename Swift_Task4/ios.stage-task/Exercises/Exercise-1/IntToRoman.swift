import Foundation

public extension Int {
    
    var roman: String? {
        if self >= 1 && self <= 3999 {
            let romanNumbersDictionary = [
                100: "C", 400: "CD", 500: "D", 900: "CM", 1000: "M",
                10: "X", 40: "XL", 50: "L", 90: "XC",
                1: "I", 4: "IV", 5: "V", 9: "IX"].sorted(by: >)
            
            var int = self
            var romanValue = ""
            
            for romanNumber in romanNumbersDictionary {
                
                while int >= romanNumber.key {
                    romanValue += romanNumber.value
                    int -= romanNumber.key
                }
            }
            return romanValue
        }
        return nil
    }
}
