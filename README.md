# MobChat 
MobChat is a group chat app for users to experience and chat about live events together. Users can set calendar reminders for air dates 
to receive notifications about the event. 

The app incorporates all the common features you’d expect from a group chat application, but a concept 
I wanted to test was allowing for more democratic control. This meant instead of a single owner controlling features of the chat room, 
all users played a part in maintaining the room such as uploading highlights and adding calendar reminders. This worked by providing a chat log which allowed 
users to monitor others, and kick those who weren't behaving. 

# Features
* Create and join group chats 
* Add highlights to share with the group
* Add and view calendar reminders for live events 
* Monitor the chat log for nefarious activites
* Vote to kick inappropriate members
* ML Nudity moderator
* Real-time notifications 

<img src="https://github.com/ericsong01/MobchatApp/blob/54edcdc1213b0b4ca6748ef68688f7464ecaae67/github_display_photos/launchscreenwhite.jpeg" width=250 align=left><img src="https://github.com/ericsong01/MobchatApp/blob/54edcdc1213b0b4ca6748ef68688f7464ecaae67/github_display_photos/chathomewhite.jpeg" width=250 align=left><img src="https://github.com/ericsong01/MobchatApp/blob/54edcdc1213b0b4ca6748ef68688f7464ecaae67/github_display_photos/chatwhite.jpeg" width=250 align=left><img src="https://github.com/ericsong01/MobchatApp/blob/54edcdc1213b0b4ca6748ef68688f7464ecaae67/github_display_photos/chatlogwhite.jpeg" width=250 align=left><img src="https://github.com/ericsong01/MobchatApp/blob/93e991274abeb54c5f0b8e93754660445b5dfec7/github_display_photos/calendarwhite.jpeg" width=250>

# Implementation Details
The UI was built programmatically using Swift. I utilized Firebase database as the backend.
I used the Nudity-ML model provided in this repo: https://github.com/ph1ps/Nudity-CoreML
