import SwiftUI

struct Person: Identifiable, Hashable {
    let id: String
    let name: String
    let color: Color
    let letter: String
    var total: Double = 0
}

struct BillItem: Identifiable {
    let id: Int
    let name: String
    let price: Double
    var assignees: [String] = []
}

class BillViewModel: ObservableObject {
    @Published var people: [Person] = [
        Person(id: "you", name: "You", color: .blue, letter: "Y"),
        Person(id: "maya", name: "Maya", color: Color(red: 1.0, green: 0.42, blue: 0.62), letter: "M"),
        Person(id: "jonah", name: "Jonah", color: .green, letter: "J"),
        Person(id: "priya", name: "Priya", color: .orange, letter: "P")
    ]
    
    @Published var items: [BillItem] = [
        BillItem(id: 1, name: "Burrata", price: 18.00),
        BillItem(id: 2, name: "Cacio e Pepe", price: 24.00),
        BillItem(id: 3, name: "Rigatoni alla Vodka", price: 26.00),
        BillItem(id: 4, name: "Branzino", price: 34.00),
        BillItem(id: 5, name: "Margherita", price: 21.00),
        BillItem(id: 6, name: "Montepulciano (btl)", price: 58.00),
        BillItem(id: 7, name: "Tiramisu", price: 12.00)
    ]
    
    @Published var selectedId: String? = nil
    
    let taxRate = 0.08875
    let tipRate = 0.20
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.price }
    }
    
    var tax: Double { subtotal * taxRate }
    var tip: Double { subtotal * tipRate }
    var grandTotal: Double { subtotal + tax + tip }
    
    func toggleAssignee(for itemId: Int) {
        guard let selected = selectedId,
              let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        
        if let idx = items[index].assignees.firstIndex(of: selected) {
            items[index].assignees.remove(at: idx)
        } else {
            items[index].assignees.append(selected)
        }
        calculate()
    }
    
    func calculate() {
        var subtotals: [String: Double] = [:]
        for person in people {
            subtotals[person.id] = 0
        }
        
        for item in items {
            guard !item.assignees.isEmpty else { continue }
            let share = item.price / Double(item.assignees.count)
            for id in item.assignees {
                subtotals[id, default: 0] += share
            }
        }
        
        let totalSub = subtotals.values.reduce(0, +)
        let taxAmount = totalSub * taxRate
        let tipAmount = totalSub * tipRate
        
        for i in people.indices {
            let sub = subtotals[people[i].id] ?? 0
            let ratio = totalSub > 0 ? sub / totalSub : 0
            people[i].total = sub + (taxAmount * ratio) + (tipAmount * ratio)
        }
    }
    
    func reset() {
        for i in items.indices {
            items[i].assignees = []
        }
        selectedId = nil
        calculate()
    }
}
