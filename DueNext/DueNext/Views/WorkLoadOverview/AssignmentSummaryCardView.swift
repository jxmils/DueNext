//
//  AssignmentSummaryCardView.swift
//  DueNext
//
//  Created by Jason Miller on 11/5/24.
//

import SwiftUI

struct AssignmentSummaryCard: View {
    var title: String
    var count: Int
    var color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Text("\(count)")
                .font(.title)
                .bold()
                .foregroundColor(color)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
        .shadow(radius: 5)
    }
}
