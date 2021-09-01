## MTA SA Properties
This resource adds functionality to enter, exit and load properties from a SQLite database. Entering to a property tries to mimick single-player functionality.

This resource also adds and calls an event called `serverCreatedProperty` from which you can interact further with the loaded properties from the SQLite database. The table `properties` also has an additional field called `EXTRA` (BLOB), from which you can add aditional data that you might need.
