#Landmark Remark Assignment Submission for Tigerspike
#by Gagandeep Singh

#Installation
    - Open the LandmarkRemark.xcworkspace in Xcode 7.3.1 or later.
    - Run the app in Simulator or a device.
    - Parse has been used as backend for this project.


#Approach
    - As per the Assignment Brief, following is what I considered as essential parts for the project
        - A Sign Up & Login process
    - The sign up process would sign up a user with their email address, aling with a Username & Password and allow Login using the Username & Password
    - A Map with locations of Notes added by users, seems to be the main function of the app. Hence, it was made the Home Screen of the App, once a user is Logged In.
    - The Map View shows all the notes that have been saved by different users of the app as location pins.
    - Them Map View queries the database only for the notes that have been saved in the area that is visible to the user on their device screen at the given time.
    - Each time the visible area of the map changes, a new query is made to the database and if the area is different or larger than before, more note locations are added to the map, if found.
    - User can tap on any pin to read the note and see more details about the note such as, the location address and the time when the note was written.
    - The Note is saved in the database along with the user's credentials and the user's location at the time of writing the note.

#Search
    - A search filed is added above the Map View, for the user to search for notes.
        - The Note also has a 'Search String' field, which inludes the username of the user, location at which the note was written and the body of the note. This field is used to match notes when a user performs a search. The Search String is transformed into lowercase, to make serch results more relevant.
    - When user performs a search for notes, a query is sent to the databse which will search for notes that match the search string and are within the visible area of the map.
    - Once a search string has been added to the search input, the user can drag and zoom the map and the same search will be repeated for the now visible area.
    - User can, at any time, clear the search field and see all the available notes in the visible area.

    - In order to save a note, a Compose View controller was added which displayes the User's username & the Current Location and allows the user to write & save a note.

#Location Access
    - Current Location access is very important for this app. Hence, the user is asked to Authorize the app to access their location, when the Home Screen is presented for the first time.

    #Access Allowed
    - If the user Allows the access then the map view proceeds to take the user to their current location and fetch the notes in that area.
    - This also allows the user to write and new note at their location.

    #Access not allowed
    - If the user Does Not Allow access, then the user can still browse the notes written by other users on the map.
    - If the user taps on the Write Note button, the authorization is checked and the user is asked to allow access to their current location, once again.
    - If the user decides to allow access, they can tap the Settings button on the alert and they'll be taken to the app settings, allows location access and then come back and write their note.
    - If the user decides not allow access once again, they cannot write a note.

#Issues/Limitations
    - The projects covers all the requirements given in the Assignment Brief.
    - It does go slighly beyond of what was asked but there still are a few things that can be added to make this a proper app.
    - First thing would be a proper email verification before allowing a user to sign up.
    - User should be able to Edit/Delete their own notes.
    - There cold be an option to write a Private note which will not be visible to other users.

#Time Spent
    - Developed over 3 days

    - ~3 hours: Login/Signup 
    - ~2 hours: Map View + showing user notes on the map 
    - ~1 hour:  Showing user note details 
    - ~1 hour:  Compose View 
    - ~3 hours: UI & UX Design: 
    - ~2 hours:  Miscellaneous
    - ~30 minutes: Localization
    




    