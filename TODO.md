Implement
---------
* Show hold date in Todo and Journal views
* Decide about semantics of journal entry deletion or disallow

Bugs
----

Code
----
* Enhance InnerBand to return fetch requests and/or fetch results controller
* Clean up urgency/due-date mess
* Replace entry timestamp with journalTimeString

Performance
-----------
* Use cache file for both NSFetchedResultControllers
* Cache Todo's entriesByDate

Testing
-------
* Sample journal entries spread out over many days. Include action entries.

Cosmetic
--------
* get rid of nav bar or make it worth it
* icons for tab bar
* warmer looking journal
* replace entry type text with icon
* Edit title field should use correct font based on settings

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
* Multi-line todos and entries, avoid ellipsis
* Secondary sorts

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
* indicate when todo has notes
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
* Journal reference entries (italic)
* Urgency window based on size of todo

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
* Intl dates
