//
//  SafariView.swift
//  TodoTasksSync
//
//  Created by Nishad Zulfuqarli on 12.08.26.
//

import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}


