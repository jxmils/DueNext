//
//  DueNextWidgetBundle.swift
//  DueNextWidget
//
//  Created by Jason Miller on 11/4/24.
//

import WidgetKit
import SwiftUI

@main
struct DueNextWidgetBundle: WidgetBundle {
    var body: some Widget {
        DueNextWidget()
        DueNextWidgetLiveActivity()
    }
}
