// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import UIKit

struct ErrorReportView: View {
  @Environment(\.dismiss) private var dismiss
  let info: ErrorInfo

  var body: some View {
    NavigationStack {
      reportList
        .listStyle(.plain)
        .navigationTitle("Felrapport")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .presentationDetents([.medium, .large])
    }
  }
}

private extension ErrorReportView {
  var rows: [(title: String, value: String)] {
    [
      ("Felkod", info.code),
      ("Meddelande", info.message),
      ("Endpoint", info.endpoint),
      ("Trace-ID", info.traceId),
      ("App-version", info.appVersion),
      ("Tidpunkt", info.timestamp),
      ("iOS", info.iosVersion),
      ("Modell", info.deviceModel),
      ("Nätverk", info.network),
    ]
    .compactMap { title, value in
      value.map { (title: title, value: $0) }
    }
  }

  var reportText: String {
    (["Felrapport"] + rows.map { "\($0.title): \($0.value)" })
      .joined(separator: "\n")
  }

  var reportList: some View {
    List {
      ForEach(Array(rows.enumerated()), id: \.element.title) { index, row in
        listRow(title: row.title, info: row.value)
          .listRowSeparator(index == 0 ? .hidden : .automatic, edges: .top)
          .listRowSeparator(index == rows.count - 1 ? .hidden : .automatic, edges: .bottom)
      }
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
          .accessibilityLabel("Stäng")
          .accessibilityHint("Använd knappen för att stänga felskärmen")
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      ShareLink(item: reportText) {
        Image(systemName: "square.and.arrow.up")
          .accessibilityLabel("Dela felrapport")
      }
    }

    ToolbarItem(placement: .bottomBar) {
      HStack(spacing: .zero) {
        PrimaryButton(
          "Kopiera",
          icon: "document.on.clipboard",
          maxWidth: .infinity,
          onClick: {
            UIPasteboard.general.string = reportText
            dismiss()
          },
        )
      }
    }
    .sharedBackgroundVisibilityHiddenIfPossible()
  }

  func listRow(title: String, info: String) -> some View {
    VStack(spacing: .zero) {
      HStack(alignment: .top, spacing: 12) {
        Text(title)
          .textStyle(.body)

        Spacer()

        Text(info)
          .textStyle(.bodySmall)
          .foregroundStyle(.gray)
          .multilineTextAlignment(.trailing)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .listModifiers()
    }
  }
}

private extension View {
  func listModifiers() -> some View {
    self
      .padding(.horizontal, 8)
      .listRowBackground(Color.clear)
  }
}

#Preview {
  ErrorReportView(info: .mock)
    .themed
}
