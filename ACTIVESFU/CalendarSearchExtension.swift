//
//  CalendarSearchExtension.swift
//  ACTIVESFU
//
//  Created by Xue Han on 2017-03-29.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

extension ViewCalendarController {

    //MARK: filter and search bar
    //TODO: implement time of day search
    func filterEventsForSearch(searchText: String, scope: String = "All") {
        
        filteredEvents = events.filter { event in
            
            let timeMatch = (scope == "All") || (event.timeOfDay == scope)
            
            print("event-----------------------", event.title)
            print("event.timeofDay-------------", event.timeOfDay)
            print("scope-----------------------", scope)
            print("time match-------------------", timeMatch)
            
            return timeMatch && (event.title?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
        
        print(filteredEvents)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        print("--------------------------scope", scope)
        
        filterEventsForSearch(searchText: searchController.searchBar.text!, scope: scope)
    }


}
