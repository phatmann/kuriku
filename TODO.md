Kuriku
The visual intelligent action journal

Todo
----
* Make importance a float
* Show red if hot or blue if cold
* Tap to edit
* Slide to take action, set complete, or repeat
* Implement temperature, including staleness based on last action date
* Glide to set temperature, via start date or due date

Bugs
-------------
* Sometimes expanding text views makes table scroll bounce
* Do not allow actions on completed task
* Do not allow actions on inactive task
* If start date in past applied, ignore it
* Should deploy only to iOS 7

Missing Features
----------------
* Tap inactive task goes to active task

New Thoughts
------------
* Remove start date when action taken?
* Don't need prominent type icons in journal. Every entry is newness, readiness or action.
* Filter slider has stops: all, hide inactive, hide complete, hide cold
* Check priority calcs
* Staleness driven by last action date
* Iciness driven by distance from start date
* Temperature from urgency, staleness and iciness
* Glide left to make more icy (start date) or right to make more urgent (due date)
* No more commitment: importance 0 = no commitment, no staleness
* "READY" -> "TODO"
* Slide left to see "bar" partial complete, more left check, more left repeat
* Tap and drag: up more prominent, down less prominent remove start date, left blue, right red
* One line entry: type icon on left, time on right
* Tap and drag up/down to glow more/less. If not glowing, down to set due date.
* Tap and drag right/left to put on hold, yellow color
* If not yellow, tap and drag left to put place start date in past, blue glow.
* "Importance" -> "prominence"
* "Urgency" -> "glow"
* Setting glow sets due date or start date, but dates not shown in journal (?)
* No start date == no commitment
* Commitment icons: none (maybe), hollow star (must), filled in star (today), jogger (habit)
* Can make a todo a "habit". Separate them to reduce noise.
* Multiple journals chosen from nav bar
* Journals are hierarchical, can use for projects
* Show "i" accessory when editing to add a note, edit properties
* When there is a note, show below todo, tap to edit
* In Edit dialog mention gestures for each property
* Show progress of todos by partial coloring, assume one action will complete and scale accordingly

Performance
-----------
* Use cache file for NSFetchedResultControllers
* Cache lastEntry metadata

PRE-JOURNAL-ONLY

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
* indicate stale actions
* Autofocus: move pending todos to end of journal
* Decide if all entries for completed todod should be crossed out
* Sort up/down
* Remember Todos filter setting
* Consider star for Today items instead of bold
* Consider segmented controls to replace sliders
* Consider more randomness in priority
* Commitment sort
* Intl date format
* Edit title field should use correct font based on settings
* Hide urgency slider if due date is set
* Show urgent maybe todos properly (or disallow)

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





