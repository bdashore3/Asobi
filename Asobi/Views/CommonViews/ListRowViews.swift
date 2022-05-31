//
//  ListRowView.swift
//  Asobi
//
//  Created by Brian Dashore on 8/5/21.
//

import SwiftUI

// These views were imported from FileBridge

// View alias for a list row with an external link
struct ListRowLinkView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    @EnvironmentObject var webModel: WebViewModel
    @EnvironmentObject var navModel: NavigationViewModel

    let text: String
    let link: String
    var subText: String?
    @State var useStatefulBookmarks: Bool = false

    var body: some View {
        ZStack {
            Color.clear
            HStack {
                VStack(alignment: .leading) {
                    Text(text)
                        .font(subText != nil ? .subheadline : .body)
                        .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                        .lineLimit(1)

                    if let subText = subText {
                        Text(subText)
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            var loadLink = link

            if useStatefulBookmarks {
                let cutUrl = link.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "")

                let historyRequest = HistoryEntry.fetchRequest()
                historyRequest.predicate = NSPredicate(format: "url CONTAINS %@", cutUrl)
                historyRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntry.timestamp, ascending: false)]
                historyRequest.fetchLimit = 1

                if let entry = try? PersistenceController.shared.backgroundContext.fetch(historyRequest).first, let url = entry.url {
                    loadLink = url
                }
            }

            webModel.loadUrl(loadLink)

            navModel.currentSheet = nil
        }
    }
}

struct ListRowExternalLinkView: View {
    let text: String
    let link: String

    var body: some View {
        HStack {
            Link(text, destination: URL(string: link)!)
                .foregroundColor(.primary)

            Spacer()

            Image(systemName: "arrow.up.forward.app.fill")
                .foregroundColor(.gray)
        }
    }
}

struct ListRowTextView: View {
    let leftText: String
    var rightText: String?
    var rightSymbol: String?

    var body: some View {
        HStack {
            Text(leftText)

            Spacer()

            if let rightText = rightText {
                Text(rightText)
            } else {
                Image(systemName: rightSymbol!)
                    .foregroundColor(.gray)
            }
        }
    }
}
