Bugs
----

Code
----
* Don't factor completion into priority

Usability
---------

Performance
-----------
* Only update urgencies when 24hrs has passed
* Use cache file for both NSFetchedResultControllers

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

Basic Features
--------------
* Start date (hide from Todo until then)
* Recurring todos
* Show due date in Todo and Journal views
* Completed items prioritize by completed date
* Sort/filter Todo view
    - All (by priority)
    - Urgent
    - Important
    - Scheduled (by start date)
    - Completed (by completed date)

Tweaks
------
* Show time in latest action date in Todo view
* Show create date in Todo list
* Tomorrow and Next Week buttons in Date picker

Advanced Features
-----------------
* Archive completed entries
* Factor stalled into priority
* Stalled filter in Todo view
* Remember active tab
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

Standards
---------
* Use preferred font size per iOS 7, no hard-coded text widths
* Edit mode

Migration
---------

In Box
------
* show completed date
* replace tab bar
* indicate stale actions
* Autofocus: move pending todos to end of journal
* Archive/hide old journal pages
* journal reference entries (italic)
* Longer notes field
* Urgency window based on size of todo
* Due reminders in journal
