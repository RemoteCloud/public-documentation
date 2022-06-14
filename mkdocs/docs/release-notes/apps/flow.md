## v2.6.9

**Bug-fixes and improvements:**

- Offline improvements to picture upload
- API updates
- Bugfixes
- [Very high] Can’t set due time on checklist start (mobile)

## v2.6.8

**Bug-fixes and improvements:**

- [Very high] Major improvements in webhook trigger performance when working in conditions of poor internet signal.
- [Very high] Fixed issue with date and time control UI layout compatibility with mobile devices.
- [Very high] Improved logic for discarded template recovery.
- [Very high] GET ​/api​/flows​/{flowId}​/tasks now is updating Request URL with a value from {flowId}​ field.
- [High] Major user interface improvements: completion of the item does not switch the flow view, sections are not closed after picture, sign, file upload in tasks, possible to close comment filter block.
- [High] Time before template is deleted now can't exceed 50 months and wrong values now does not prevent the flow from being completed or discarded.
- [Medium] Fixed bugs with modal window display fopr date, signature, picture and file upload tasks.
- [low] Automatic bug reporting endpoint changed

**Features:**

- [Very high] Implemented the asynchronous mode that allows users to work in in conditions of poor internet signal.
- [Very high] Added indicators to show task upload process to improve usability.



## v2.6.7

**Bug-fixes and improvements:**

- [high] Fixed flushing action groups for asynchronous UI actions
- [high] Fixed flow completion issue for templates with archive timeout beyond limit

**Features:**

- [medium] Possibility to set current D/T value by swiping DateTime, Date or Time task

## v2.6.6

**Bug-fixes and improvements:**

- [high] Prevent blocking UI on bad connections (asynchronous UI actions)
- [high] Prevent saving value right on change for DT picker if it is in double control
- [medium] Allow to recover discarded checklists that were not finished
- [medium] Disable override option when template is active

## v2.6.5

## v2.6.4

Bug-fixes and improvements:

- [high] Fixed section complete webhook trigger
- [high] Improvements in external access to the flows
- [high] Solved issue with webhook multiplication
- [medium] Pictures now are included in Api/GenerateChecklistPdf report
- [medium] Signature is displayed fully in the list control
- [medium] In handovered checklists in consecutive long text control long value without spaces does not go out of the window anymore
- [medium] Not seeing the first item of the next section once a section is completed issue is fixed now
- [medium] Discarded checklist list is not affected by switching filter
- [medium] When switching between sections, user will always see the first item in the section
- [medium] It is now possible to select current date and time for date and time controls on the Android phones
- [medium] Improved long text control diplay in the flow view
- [low] Fixed item scrolling in sections 

Features:
- [very high] Date and time control was built into the layout and now is more responsive


## v2.6.1

- ...

