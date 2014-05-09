Kuriku
The visual intelligent action journal

Improvements
------------
* Enhance edit dialog to use temperature, show gesture tips

Bugs
----
* Section needs separator lines
* Cell should resize during pinch without scrolling
* Often cell gets selected during a gesture
* If start date in past applied, ignore it
* Sometimes pinching happens when trying to rotate
* Swipe recognition not reliable

Missing Features
----------------
* Scroll down to show blank line in edit mode
* Allow multiple todos to be entered
* Tap inactive task goes to active task
* Jump around to different dates in journal
* Search
* Let user change settings for number of stale, urgent, and frosty days
* Repeat icon on frozen completed todos?

New Thoughts
------------
* Add notes by embedding return
* Remove start date when action taken?
* Commitment icons: none (maybe), hollow star (must), filled in star (today), jogger (habit)
* Can make a todo a "habit". Separate them to reduce noise.
* Multiple journals chosen from nav bar
* Journals are hierarchical, can use for projects
* When there is a note, show below todo, tap to edit

Performance
-----------
* Use cache file for NSFetchedResultControllers
* Cache lastEntry metadata
* Cache entry progress

PRE-JOURNAL-ONLY

Bugs
----
* Sometimes expanding text views makes table scroll bounce

Code
----
* Enhance InnerBand to return fetch requests and/or fetch results controller
* Clean up urgency/due-date mess
* Replace entry timestamp with journalTimeString

Testing
-------
* Sample journal entries spread out over many days. Include action entries.

Cosmetic
--------
* warmer looking journal
* replace entry type text with icon
* complete entries should look different than closed

Before shipping
---------------
* Automated tests
* Remove test data
* Show helpful sample data
* Graphics

Tweaks
------
* Tomorrow and Next Week buttons in Date picker
* Colors for edit todo view values (e.g. gray Never)
* Max todo height with ellipsis
* Dismiss keyboard when edit view scrolled up

Advanced Features
-----------------
* Priority looks at lastActionDate
* Customize UI: hide unused features, set value ranges, etc. Optimize real-time usage.
* Archive completed entries
* Inline editing
* Landscape mode
* Remember active tab
* Todos with dates on calendar
* Search
* Filter journal by entry type
* Set journal date and time for entry
* Starred view
* Todo estimated size
* Task timer with duration in action entries
* view notes
* multi journals
* Choose urgency window for due dates
* Jump around journal
* Set action entry title and show todo title with it
* Action list for todos, can choose from actions when creating entry
* Projects
* Settings
* Tags
* Color labels
* Action outline
* Filter by context (e.g. when home)
* Shared lists
* Shake to shuffle
* Reminders
* Use preferred font size per iOS 7, no hard-coded text widths
* Edit mode
* Archive/hide old journal pages
* Journal reference entries
* Urgency window based on size of todo
* Show todo count

In Box
------
* Autofocus: move pending todos to end of journal
* Decide if all entries for completed todos should be crossed out
* Sort up/down
* Consider segmented controls to replace sliders
* Consider more randomness in priority
* Intl date format
* Edit title field should use correct font based on settings

Old Notes
==========================

Kuriku

Tabs: Journal, Discover, Commit, Projects

Properties:
urgency/due date: black to red
importance: small to large
commitment: star
project
actions
start date
estimate

Journal:
Section per day
Hide days with no open items
Option to show all
Day browser
Jump to day

Commands: delete, archive

Task timer: choose todo, start timer. Moves in journal to current date and crosses off old one. Can name new action or choose from an existing action. Can add estimate. If estimated counts down. Timer appears on Commit tab. 

Minimal: Journal, Discover
Soon: Commit tab and star
Upgrades: multiple journals, projects, syncing, timer/actions

Maybe:
Track interruptions
Activity stats
Choose filters and sorts in discover view

Desktop:
Menu bar app
Task timer floating window

Sync:
Reminders
iCloud
Calendar
Dropbox
Evernote





