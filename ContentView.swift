import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BillViewModel()
    @State private var showSummary = false
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.94, blue: 0.91).ignoresSafeArea()
            
            VStack(spacing: 0) {
                header
                peopleRow
                instruction
                receipt
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showSummary) {
            summarySheet
        }
        .onAppear { vm.calculate() }
    }
    
    private var header: some View {
        HStack {
            Button(action: { vm.reset() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Circle())
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Split check")
                    .font(.system(size: 17, weight: .semibold))
                Text("\(vm.people.count) people")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Done") {
                if vm.items.contains(where: { !$0.assignees.isEmpty }) {
                    showSummary = true
                }
            }
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundStyle(.white)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
    
    private var peopleRow: some View {
        HStack(spacing: 8) {
            ForEach(vm.people) { person in
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(person.color)
                            .frame(width: 48, height: 48)
                        Text(person.letter)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: vm.selectedId == person.id ? 3 : 0)
                            .frame(width: 54, height: 54)
                    )
                    Text(person.name)
                        .font(.system(size: 13, weight: .medium))
                    Text(formatMoney(person.total))
                        .font(.system(size: 14, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    vm.selectedId = person.id
                }
                .scaleEffect(vm.selectedId == person.id ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: vm.selectedId)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    private var instruction: some View {
        Group {
            if let id = vm.selectedId, let person = vm.people.first(where: { $0.id == id }) {
                Text("Tap what **\(person.name)** had")
                    .foregroundStyle(person.color)
            } else {
                Text("Tap a person, then what they had")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.system(size: 14))
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
    
    private var receipt: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 4) {
                Text("LUCIA TRATTORIA")
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .tracking(1)
                Text("TABLE 12 · 4 GUESTS")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                Text("THU NOV 5 · 8:42 PM")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 12)
            .overlay(alignment: .bottom) {
                Rectangle().frame(height: 1).foregroundStyle(Color.gray.opacity(0.3)).dashed()
            }
            
            ForEach(vm.items) { item in
                HStack {
                    Text("1")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(width: 20, alignment: .leading)
                    Text(item.name)
                        .font(.system(size: 14, design: .monospaced))
                    if item.assignees.count > 1 {
                        Text("1/\(item.assignees.count)")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.2f", item.price))
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                    HStack(spacing: 3) {
                        ForEach(item.assignees, id: \.self) { id in
                            if let p = vm.people.first(where: { $0.id == id }) {
                                Circle()
                                    .fill(p.color)
                                    .frame(width: 16, height: 16)
                                    .overlay(Text(p.letter).font(.system(size: 9, weight: .bold)).foregroundStyle(.white))
                            }
                        }
                    }
                    .frame(minWidth: 40, alignment: .trailing)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(item.assignees.isEmpty ? Color.clear : Color(red: 0.96, green: 0.94, blue: 0.91))
                .cornerRadius(6)
                .onTapGesture {
                    vm.toggleAssignee(for: item.id)
                }
            }
            
            VStack(spacing: 4) {
                totalRow("SUBTOTAL", vm.subtotal)
                totalRow("TAX 8.875%", vm.tax)
                totalRow("TIP 20%", vm.tip)
                totalRow("TOTAL", vm.grandTotal, isGrand: true)
            }
            .padding(.top, 12)
            .overlay(alignment: .top) {
                Rectangle().frame(height: 1).foregroundStyle(Color.gray.opacity(0.3)).dashed()
            }
        }
        .padding(16)
        .background(Color(red: 1.0, green: 0.996, blue: 0.973))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.91, green: 0.88, blue: 0.82), lineWidth: 1)
        )
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
    
    private func totalRow(_ label: String, _ amount: Double, isGrand: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: isGrand ? 15 : 13, weight: isGrand ? .bold : .regular, design: .monospaced))
            Spacer()
            Text(String(format: "%.2f", amount))
                .font(.system(size: isGrand ? 15 : 13, weight: isGrand ? .bold : .regular, design: .monospaced))
        }
        .padding(.vertical, isGrand ? 4 : 2)
    }
    
    private var summarySheet: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Who owes what")
                    .font(.title2.bold())
                    .padding(.top)
                
                ForEach(vm.people) { person in
                    HStack {
                        Text(person.name)
                        Spacer()
                        Text(formatMoney(person.total))
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    Divider()
                }
                
                Text("Tax and tip split by what each person ordered")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showSummary = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func formatMoney(_ n: Double) -> String {
        String(format: "$%.2f", n)
    }
}

extension Shape {
    func dashed() -> some View {
        self.stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
    }
}

#Preview {
    ContentView()
}
