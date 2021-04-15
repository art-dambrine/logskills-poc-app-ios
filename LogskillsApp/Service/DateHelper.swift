//
//  DateHelper.swift
//  LogskillsApp
//
//  Created by Arthur Dambrine on 15/04/2021.
//

import Foundation

class DateHelper {
    
    func getTodayWithOffset(offsetDay: Int)->String {
        
        // Create Date
        let date = Date()
        
        var dayComponent    = DateComponents()
        dayComponent.day    = offsetDay // For removing one day (yesterday): -1
        let theCalendar     = Calendar.current
        let nextDate        = theCalendar.date(byAdding: dayComponent, to: date)

        // Create Date Formatter
        let dateFormatter = DateFormatter()

        // Set Date Format
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Convert Date to String
        return dateFormatter.string(from: nextDate!)
        
        
        
    }

    
}

