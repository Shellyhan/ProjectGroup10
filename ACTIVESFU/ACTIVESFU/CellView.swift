//
//  CellView.swift
//
//  By Nathan Cheung
//  Sets up the cell UI for the calendar
//
//  Inspired by by Jeron Thomas - github.com/patchthecode/JTAppleCalendar
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import JTAppleCalendar

class CellView: JTAppleDayCellView {
   
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet var dayLabel: UILabel!
}
