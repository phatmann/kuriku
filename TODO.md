
Bugs
----
* Sometimes expanding text views makes table scroll bounce

Deletion semantics
------------------
* Deleting active entry should activate previous entry
* Deleting NEW entry should delete Todo with no prompt
* Deleting COMPLETED entry should make Todo ready and remove any COMPLETED or READY entries above it
* Deleting READY entry should make Todo completed

Missing Features
----------------


PRE-JOURNAL-ONLY

Implement
---------
* Indicate when todo has notes


Code
----
* Enhance InnerBand to return fetch requests and/or fetch results controller
* Clean up urgency/due-date mess
* Replace entry timestamp with journalTimeString

Performance
-----------
* Use cache file for both NSFetchedResultControllers
* Cache Todo.entriesByDate

Testing
-------
* Sample journal entries spread out over many days. Include action entries.

Cosmetic
--------
* get rid of nav bar or make it worth it
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
* Show time in latest action date in Todo view
* Tomorrow and Next Week buttons in Date picker
* Colors for edit todo view values (e.g. gray Never)
* Secondary sorts
* Max todo height with ellipsis
* Dismiss keyboard when edit view scrolled up

Advanced Features
-----------------
* Priority looks at lastActionDate
* Customize UI: hide unused features, set value ranges, etc. Optimize real-time usage.
* Stalled filter in Todo view
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
* replace tab bar
* indicate stale actions
* Autofocus: move pending todos to end of journal
* Decide if all entries for completed todod should be crossed out
* Sort up/down
* Remember Todos filter setting
* Consider star for Today items instead of bold
* Consider segemented controls to replace sliders
* Consider more randomness in priority
* Better term than Priority?
* Commitment sort
* Intl date format
* Edit title field should use correct font based on settings
* Hide urgency slider if due date is set
* Show urgent maybe todos properly (or disallow)

New Thoughts
------------
* Pinch to set importance
* "Todos" -> "Radar"
* Slide to set urgency, start date on one side, due date on other side
* Urgency driven by due date or start date, or manual override
* No start date == no commitment
* Commitment icons: none (maybe), hollow star (must), filled in star (today), jogger (habit)
* "Do again..." action adds completed action and sets start date via dialog
* "Completed" action -> "Did it"
* Can make a todo a "habit". Separate them to reduce noise.
* Multiple journals chosen from nav bar
* Journals are hierarchical, can use for projects
* Show "i" accessory when editing to add a note, edit properties
* When there is a note, show below todo, tap to edit
* In Edit dialog mention gestures for each property


