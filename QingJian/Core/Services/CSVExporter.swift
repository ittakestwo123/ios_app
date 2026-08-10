import Foundation

enum CSVExporter {
    static func exportURL(for sessions: [StudySession]) throws -> URL {
        let formatter = ISO8601DateFormatter()
        let header = "开始时间,结束时间,时长分钟,科目,模式,计划分钟,是否完成"
        let rows = sessions.sorted { $0.startAt < $1.startAt }.map { session in
            [
                formatter.string(from: session.startAt),
                formatter.string(from: session.endAt),
                String(session.durationSeconds / 60),
                escaped(session.subjectNameSnapshot),
                session.mode.localizedName,
                session.plannedSeconds.map { String($0 / 60) } ?? "",
                session.completed ? "是" : "否"
            ].joined(separator: ",")
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("晴笺学习记录.csv")
        guard let data = ([header] + rows).joined(separator: "\n").data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: url, options: .atomic)
        return url
    }

    private static func escaped(_ value: String) -> String {
        "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
