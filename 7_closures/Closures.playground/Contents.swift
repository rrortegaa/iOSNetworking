import UIKit

// Closures

/**
 
    A closure is bassicaly a function that can be handled as a variable
 
 */


// Here Im defining a variable that will hold a closure that takes nothing and returns nothing.
var aClosure: () -> Void
// Here Im defining a variable that will hold a closure that takes nothing and returns an Integer
var aReturningClosure: () -> Int
// Here Im defining a variable that will hold a closure that takes an Integer and returns nothing
var aClosureWithInput: (Int) -> Void


// This is how we would assign a closure to its variable
aClosure = {
    print("This an empty closure")
}

aReturningClosure = {
    print("This is a returning closure")
    return 0
}

aClosureWithInput = { value in
    print("This is a closure that takes an input. Input \(value)")
}


// To execute a closure would be like a function
aClosure()

let value = aReturningClosure()

aClosureWithInput(1)

// Closures can be optional types too for example
var anOptionalClosure: (() -> Void)?


// To invoke an optional closure we must put a ? before the parenthesis ()
anOptionalClosure?()

anOptionalClosure = {
    print("This is an optional closure")
}


anOptionalClosure?()

// Like optionals we can unwrap the optional closure

if let nonOptionalClosure = anOptionalClosure {
    nonOptionalClosure()
}


// Closures can also be passed as input parameters for functions

func makeCall(inputParams: String, completion: () -> Void) {
    print("Input params: \(inputParams)")
    completion()
}

// And the way to pass a closure into a function would be like this

makeCall(inputParams: "Hello", completion: {
    print("This is a closure inside a function")
})


/**
    Another way to pass a closure with a cleaner syntax would be like this. But, in order to pass the closure like this, the closure parameter
     must be the last parameter of the function parameter
 */
makeCall(inputParams: "Hello") {
    print("This is another closure inside a function")
}


// Closures can be called asyncronously
// and if the closure is going to be used asyncronously, we must add @escaping before the closure type


func asyncronousWork(completion: @escaping () -> Void) {
    print("Doing some asyncronous work")
    // Here the code is switching to another thread
    DispatchQueue.global(qos: .userInitiated).async {
        completion()
    }
}


/**
 While working with escpaing closures defined inside a class. We must consider the following
 
  If we are going to use a global attribute or call a function defined in the class we must CAPTURE a reference of the class, by doing this
 
        asyncronousWork { [weak self] in
     
        }
 
 The *weak* reserved word indicates tha the reference captured of the class instance is the type of weak, and by doing that we can avoid a posible
 memory leak caused by the ARC (Automatic Reference Counting). Another thing to take into consideration is that by capturing the class instance with a weak reference, that reference has to be treated like an optional
 
        asyncronousWork { [weak self] in
            self?.doSomeStuff()
        }
 
 */


class NetworkManager {
    
    var urlSession = URLSession.shared
    
    
    func performNetworkCall() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts?id=4") else { return }
        
        // When an input parameter of the closure is not going to be used we should place _ instead of a name.
        urlSession.dataTask(with: url) { [weak self] _, _, _ in
            /**
            When using self we must place ?, because we captured a weak reference of the class instance.
            
            We can also unwrap the self captured by doing this
            
                guard let self = self { return }
             
            or even by
            
                guard let self else { return }
                
            */
            self?.finishedRequest()
        }.resume()
    }
    
    func finishedRequest() {
        print("Finished request :)")
    }
    
}


let manager = NetworkManager()
manager.performNetworkCall()


/**
Swift allow us to do this
 
1.
        urlSession.dataTask(with: url)  { [self] _,_,_ in
            self.finishedRequest()
        }
 
 and this
 
2.
        urlSession.dataTask(with: url) { [unowned self] _,_,_ in
            self.fhinishedRequest()
        }
 

 We should never use both of those examples because, on example (1) we could make a memory leak by creating a strong reference cycle, where ARC will never deallocate the reference of the class and the closure, and if the closure is called again, it will create another reference of the class and the closure, even if there is already a reference of the closure and the class. On example (2) by using *unowned* the reference captured of the class is an *implicity unwrapped optional* (it is equivalent to declare an optional like this *var optional: Int! *  which is a very bad practice) and use that reference is very risky because if the ARC deallocates the reference of the class before we use it on the closure, we will face a reference with a *nil* value and therefore the app will crash.
 */
