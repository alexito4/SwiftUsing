
struct User {
    var name: String
    var age: Int
}

struct Address {
    var street: String
    let city: String
}

struct Friend {
    // using
    let user: User
    
    // using
    var home: Address
    
    var friendshipDate: Date
}

// generated
extension Friend {
	var name: String {
		get {
			return user.name
		}
	}
	var age: Int {
		get {
			return user.age
		}
	}
}
// generated
extension Friend {
	var street: String {
		get {
			return home.street
		}
		set {
			home.street = newValue
		}
	}
	var city: String {
		get {
			return home.city
		}
	}
}
