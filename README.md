# ACTIVE SFU: CMPT276 Group 10

Version 2.0.

ACTIVE SFU strives to assist in the creation of a healthy campus community where users can build connections and maintain a healthy lifestyle - together. 

## How to run

Ensure that you have Xcode 8.2, Swift 3, and CocoaPods. Navigate to ACTIVESFU.xcworkspace and open it in XCode. If you don't have CocoaPods installed, run: 

```
sudo gem install cocoapods
``` 

If you have problems installing CocoaPods, check [here](https://guides.cocoapods.org/using/troubleshooting#installing-cocoapods) for solutions.  

Please note that you must open ACTIVESFU.xcworkspace, not ACTIVESFU.xcodeproj, due to a CocoaPods dependency. The user interface is best viewed as an iPhone 6.

## Included files

**MainViewController.swift:**

The main menu for the user. The screen branches out into main app features such as view buddies, matching, creating events, logging out.The app starts on this page and checks if the user is logged in.

**FindABuddyViewController.swift:**

Allows the user to shake their phone in order to find users that they may want to connect with. Clicking on a user leads to their profile and gives them the ability to connect. Matching is done through answering similar responses on the survey.

**BuddiesViewController.swift:**

Allows the user to view previous buddies he or she has matched with throughout the app's use. This also branches into the chat function where users can chat with matched buddies. 

**LocationViewController.swift:**

Tracks the user location, shows their location on a map.

**ProfileViewController.swift:**

Shows the user's basic info and survey results. The user will be able to change their photo and name.

**CalendarViewController.swift:**

View controller when the user wants to see the calendar to find or create an event. A calendar will show up and the user will be able to select a date, view events on that day, or create one. Users can also modify or delete their events.

**ViewEventDetailController.swift:**

Allows the user to view the details of their event and gives them the ability to modify or delete their events. If a user is viewing an event that they didn’t create, they can join the event or message the event creator.

**CreateEventController.swift:**

Allows the user to create an event on the date chosen. The user can set a time and place, as well as set the privacy
of the event. The newly created event is then stored in Firebase where others can view it.

**LoginViewController.swift:**

The view controller the user sees when he/she is not logged into his account or starts the app for the first time. The user is able to register using email and a password and data will be saved in Firebase.

**QuestionController.swift:**

When registering a new user, the app will ask a series of questions to the user about his/her activity habits and
schedule. Using this information, the app will be able to run matching algorithms and tailor the app to the user's preferences.

**BookFacilityController.swift:**

Sets which facility rental webpage to view when the user clicks an option on the CreateEvent page.

**ChatUserCell.swift:**

Used to create the appearance of the chat cell. 

**ChatLogController.swift:**

Records and retrieves user messages to one another in Firebase. The user is able to select a buddy and then chat in real time.

**Event.swift:**

Custom data structure to store event details.

**User.swift:**

Custom data structure to store user details.

**ChatInputContainer.swift:**

Creates the user interface for the chat input area (where the user will type) when using the chat feature.

**ChatMessageController.swift:**

User interface for the chat bubble messages. 

**Message.swift:**

Custom data structure to store chat message details.

## Current features

1. Login
- Initial login
- Subsequent logins (remember the user)
- Create account

2. Initial setup
- Survey
- Profile page - basic implementation (photo, name)
- Edit profile - basic implementation (edit name)

3. Create event
- Calendar - able to see which days of the month have activities, able to see a list of daily activities and their time and activity type. 
- Facility rental - have a button to redirect to SFU’s facility rental website.
- Create event - create a new event and select location, activity, privacy. 

4. Joining events
- Search events by time of day
- Message the event creator

5. Buddies
- Shake to find suggested friends
- Chat with friends
- View friends list

## Authors

Bronwyn Biro, Carber Zhang, Nathan Cheung, Ryan Brown, Xue (Shelly) Han.


## Website 

View our website [here](https://bronwynbiro.github.io//CMPT276Group10/)
