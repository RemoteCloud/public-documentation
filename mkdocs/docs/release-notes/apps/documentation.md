## v3.0.8

**Bug-fixes and improvements**

- Lib updates
- [medium] Improved search experience on mobile
- [medium] Fixed creating page via Pages/POST/api/pages creates the page that is impossible to open bug
- [low] Added book list & shelf list dynamical loaders
- [low] Improved image resize changes image properties and proportions
- [low] Improved metadata duplication error

## v3.0.7

**Bug-fixes and improvements**

- [High] Fixed issue with customised page verification settings. Removing positions from "Verifiers selected by default" list was updated only visually, and the data was not saver correctly. 
- [High] Fixed issue with loss of verification interval during the page edit process.
- [Medium] Improved UI for application drawer in Documentation app.
- [Medium] Page can have a diverse type of content now and it does not affect page creation.
- [Medium] Now the update webhook is triggered when changes are made to a published and verified page.
- [low] Automatic bug reporting endpoint changed

## v3.0.6

## v3.0.5

Bug-fixes and improvements:

- [very high] When creating a chapter using the API, a unique ID for the chapter is generated automatically to avoid ID duplication
- [high] POST/api/chapters/{chapterId} now uses PATCH method and new name is PATCH/api/chapters/{id}
- [medium] Archive page in Documentation app now shows the valid information about archived items

Features:

- [medium] Implemented search in Documentation's topbar
- [medium] Changelog and Build information now is available for Documentation app
- 

## v3.0.4.1
