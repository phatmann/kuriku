Kuriku
======

Create a todo
-------------
Each todo has an entry in the journal when it is created. A todo is created by tapping the + button.

A todo has a temperature. When frozen, it never gets stale and never thaws. When cold, it eventually thaws out. When warm it keeps getting hotter.

Take action
-----------
A user can take action on a todo. They indicate this by sliding one's finder across the entry to the right about halfway across. Easiest way to do this is to place finger in middle of entry and slide over. As they slide a progress bar appears. When they let go, a new entry in the journal with 1/2 progress bar is created.

If they take more action they get a new entry with a 3/4 progress bar. Etc. Kuriku always assumes you are one step away from finishing :-)

Complete todo
-------------
A user can complete a todo. They indicate this by quickly swiping the entry to the right, or sliding all the way across. When they let go, a new entry in the journal with a full progress bar and strikeout text is created.

Repeat todo
-----------
A user can complete a todo and set it up to repeat later. They do this by sliding their finger down as they slide across. This shows a repeat icon in the progress bar. When they let go, a Repeat dialog appears. They can then choose how long to wait to repeat it. The todo is marked complete and then frozen with an appropriate start date.

NOTE: repeat icon is small and hard to see. Probably better to change entire bar appearance.

Delete entry
------------
You can use the standard swipe left to delete an entry. If the entry is a todo's first entry, the todo is deleted. Otherwise the user is prompted for deleting just the one entry or all entries for the todo.

If a user deletes a completion entry, the todo is considered incomplete.

Edit todo text
--------------
Tapping a todo allows user to edit text.

Edit todo info
--------------
A long press on a todo brings up an edit dialog where you can set start date and due date.

If you set a start date, that date will be shown in blue in top right of todo. The todo is made cold. As the start date approaches the todo thaws out. When the start date hits a new entry is created.

If you set a due date, that date will be shown in red in top right of todo. As date approaches the todo warms up.

Heat up or cool off a todo
--------------------------
Pinch to raise or lower temperature.

When temperature is very low, background color turns dark blue to show that the todo is frozen. When temperature is low, background color turns light blue to show that the todo is cold. When temperature is high, the background color is reddish.

Stale todos
-----------
Todos that are either hot or cold and have had no action in a while become "stale". The background color gets more brown as they get more stale. As they get more stale their temperature goes up.

Inactive entries
----------------
When a user takes action on a todo or completes it, a new entry is created. The previous entry is marked as "inactive" and has a gray background.

Filter slider
-------------
The slider along the top filters the list by temperature. At leftmost settings all entries are shown. One click to the right and inactive entries are hidden. Another click and all completed entries are hidden. Then there are clicks to hide frozen, cold, and room temperature todos.




