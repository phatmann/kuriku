Kuriku
The visual intelligent action journal


Newest thoughts
---------------
* Tap and hold, drag up for urgency, right for frostiness
* Cell always has some color, unless new as white
* Tap to edit
* Scroll down to show blank line in edit mode
* Pinch to make importance high to normal (positive?). Pinch again to make it less committed.
* Show a special shaded color when importance low, immune to staleness.
* Stale color is brown, like parchment paper
* Slide right to set action, 1/4, 1/2, 3/4 done. Keep sliding to complete. Keep sliding to repeat.
* While dragging up/right, show days in bold white overlay. Final choice is "Choose Date",
  if chosen show date dialog.


Todo
----
* Notch for normal importance

Bugs
-------------
* No highlighting when cell is tapped
* Done button does not animate cell collapse
* Do not allow actions on completed task
* Do not allow actions on inactive task
* If start date in past applied, ignore it

Missing Features
----------------
* Allow multiple todos to be entered
* Tap inactive task goes to active task
* Jump around to different dates in journal
* Search
* Scroll to new entry after taking action?
* Let user change settings for stale, urgent, and frosty days

New Thoughts
------------
* Add notes by embedding return
* Don't unmark todo completed, instead delete completion entry. Needed for accurate progress measurement.
* Change repeat names?
* Glide to set temperature, via start date or due date
* How do we handle urgency and importance changes with filter? Adjust filter?
* Slide to take action, set complete, or repeat
* Remove start date when action taken?
* Filter slider has stops: all, hide inactive, hide complete, hide cold
* Check priority calcs
* Glide left to make more icy (start date) or right to make more urgent (due date)
* Slide left to see "bar" partial complete, more left check, more left repeat
* Tap and drag: up more prominent, down less prominent remove start date, left blue, right red
* One line entry: type icon on left, time on right
* Tap and drag up/down to glow more/less. If not glowing, down to set due date.
* Tap and drag right/left to put on hold, yellow color
* If not yellow, tap and drag left to put place start date in past, blue glow.
* "Importance" -> "prominence"
* "Urgency" -> "glow"
* No start date == no commitment
* Commitment icons: none (maybe), hollow star (must), filled in star (today), jogger (habit)
* Can make a todo a "habit". Separate them to reduce noise.
* Multiple journals chosen from nav bar
* Journals are hierarchical, can use for projects
* When there is a note, show below todo, tap to edit
* In Edit dialog mention gestures for each property

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





