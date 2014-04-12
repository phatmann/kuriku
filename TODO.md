
Bugs
-------------
* Sometimes expanding text views makes table scroll bounce
* Do not allow actions on completed task
* Do not allow actions on inactive task
* If start date in past applied, ignore it

Missing Features
----------------
* Tap inactive task goes to active task
* Should not add HOLD entry when startDate changes if NEW or COMPLETED entry is "recent"

Performance
-----------
* Use cache file for NSFetchedResultControllers
* Cache Todo.entriesByDate
* Make lastEntry a modeled property

New Thoughts
------------
* "Edit Todo" -> "Edit Entry"
* Filter slider: show all -> hide inactive/pending -> show higher pri -> show highest pri
* Pinch up/down to set importance, left/right for urgency
* "Urgency" -> "glow"
* Slide to set urgency, start date on one side, due date on other side
* Urgency driven by due date (glow red) or start date (glow blue), or manual override
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
* Show progress of todos by partial coloring, assume one action will complete and scale accordingly


PRE-JOURNAL-ONLY

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




