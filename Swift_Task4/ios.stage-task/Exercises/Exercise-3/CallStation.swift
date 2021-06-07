import Foundation

final class CallStation {
    var usersArray = [User]()
    var callsArray = [Call]()
    var userCallsDictionary = [User: [Call]]()
}

extension CallStation: Station {
    func users() -> [User] {
        usersArray
    }
    
    func add(user: User) {
        if !usersArray.contains(user) {
            usersArray.append(user)
            userCallsDictionary[user] = []
        }
    }
    
    func remove(user: User) {
        let index:Int = usersArray.firstIndex(of: user)!
        usersArray.remove(at: index)
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
        // Start calling
        case .start(let from, let to):
            
            // Check if user isnot created
            if users().contains(from) {
                if !users().contains(to) {
                    let call = Call(id: from.id, incomingUser: to, outgoingUser: from, status: .ended(reason: .error))
                    callsArray.append(call)
                    userCallsDictionary[call.incomingUser]?.append(call)
                    userCallsDictionary[call.outgoingUser]?.append(call)
                    return call.id
                }
                
                // Check if user was busy
                if currentCall(user: to) != nil {
                    let call = Call(id: from.id, incomingUser: to, outgoingUser: from, status: .ended(reason: .userBusy))
                    callsArray.append(call)
                    userCallsDictionary[call.incomingUser]?.append(call)
                    userCallsDictionary[call.outgoingUser]?.append(call)
                    return call.id
                }
                
                // Check if user is going to call himself
                if from.id != to.id {
                    let call = Call(id: from.id, incomingUser: to, outgoingUser: from, status: .calling)
                    callsArray.append(call)
                    userCallsDictionary[call.incomingUser]?.append(call)
                    userCallsDictionary[call.outgoingUser]?.append(call)
                    return call.id
                }
            }
            return nil
            
            
            
        // User answered
        case .answer(let from):
            let incomingCall = currentCall(user: from)
            if incomingCall != nil {
                if users().contains(from) {
                    let call = Call(id: incomingCall?.id ?? from.id, incomingUser: from, outgoingUser: incomingCall?.outgoingUser ?? from, status: .talk)
                    callsArray.removeFirst()
                    callsArray.append(call)
                    return call.id
                } else {
                    let call = Call(id: incomingCall?.id ?? from.id, incomingUser: from, outgoingUser: incomingCall?.outgoingUser ?? from, status: .ended(reason: .error))
                    callsArray.removeFirst()
                    callsArray.append(call)
                    return nil
                }
            }
            
            
        // End of call
        case .end(let from):
            
            let incomingCall = currentCall(user: from)
            if incomingCall != nil {
                if incomingCall?.status == CallStatus.talk {
                    let call = Call(id: incomingCall?.id ?? from.id, incomingUser: from, outgoingUser: incomingCall?.outgoingUser ?? from, status: .ended(reason: .end))
                    callsArray.removeFirst()
                    callsArray.append(call)
                    return call.id
                }
                
                if incomingCall?.status == CallStatus.calling {
                    let call = Call(id: incomingCall?.id ?? from.id, incomingUser: from, outgoingUser: incomingCall?.outgoingUser ?? from, status: .ended(reason: .cancel))
                    callsArray.removeFirst()
                    callsArray.append(call)
                    
                    return call.id
                }
            }
        }
        return nil
    }
    
    func calls() -> [Call] {
        callsArray
    }
    
    func calls(user: User) -> [Call] {
        if userCallsDictionary[user] != nil {
            let userCallsArray = userCallsDictionary[user]!
            return userCallsArray
        }
        return []
    }
    
    func call(id: CallID) -> Call? {
        for (index, call) in callsArray.enumerated() {
            if id == call.id   {
                callsArray.remove(at: index)
                return call
            }
        }
        return nil
    }
    
    
    func currentCall(user: User) -> Call? {
        for (index, call) in callsArray.enumerated() {
            if call.status == CallStatus.ended(reason: .end) ||
                call.status == CallStatus.ended(reason: .error) {
                callsArray.remove(at: index)
                break
            }
            
            if call.status == CallStatus.ended(reason: .cancel)   {
                callsArray.remove(at: index)
                break
            }
            
            if call.outgoingUser == user || call.incomingUser == user {
                return call
            }
        }
        return nil
    }
}
