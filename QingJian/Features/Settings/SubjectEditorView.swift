import SwiftData
import SwiftUI

struct SubjectEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subject.sortOrder) private var subjects: [Subject]
    @State private var newSubjectName = ""

    var body: some View {
        List {
            Section("当前科目") {
                ForEach(subjects) { subject in
                    HStack {
                        TextField("科目名称", text: Binding(
                            get: { subject.name },
                            set: { subject.name = $0 }
                        ))
                        Toggle("归档", isOn: Binding(
                            get: { subject.isArchived },
                            set: { subject.isArchived = $0 }
                        ))
                        .labelsHidden()
                        .accessibilityLabel("归档\(subject.name)")
                    }
                    .onChange(of: subject.name) { _, _ in try? modelContext.save() }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            Section("新增科目") {
                HStack {
                    TextField("例如：错题整理", text: $newSubjectName)
                    Button("添加") { addSubject() }
                        .disabled(newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .navigationTitle("科目管理")
        .toolbar {
            EditButton()
        }
    }

    private func addSubject() {
        let name = newSubjectName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        modelContext.insert(Subject(name: name, sortOrder: subjects.count))
        newSubjectName = ""
        try? modelContext.save()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(subjects[index])
        }
        try? modelContext.save()
    }

    private func move(from offsets: IndexSet, to destination: Int) {
        var reordered = subjects
        reordered.move(fromOffsets: offsets, toOffset: destination)
        for (index, subject) in reordered.enumerated() {
            subject.sortOrder = index
        }
        try? modelContext.save()
    }
}
