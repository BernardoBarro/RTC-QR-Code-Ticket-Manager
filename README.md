# Description
It is a flutter project application to serve as a check-in at places and events

# How it works
Only the event organizers have access to the app, they then register a visitor for the event by adding their data, and then a QR-Code is generated which is sent directly to the registered visitor.

So, when entering, the visitor simply presents their QR-Code and the organizers will read the QR-Code with the application, allowing the visitor to check in.

For paid events, the application is also used to check whether the visitor has already paid or needs to pay.

PS: Currently the application works as if it were for just one event, to use it for another you would have to clean the entire database, but in the future I intend to make it more generic
PS2: The idea of ​​the application was created to handle event accreditations for the [Rotaract](https://www.rotary.org/en/get-involved/rotaract-clubs) Club de Erechim volunteer club in Brazil in a more automatic way that allows for fewer errors.

# Version
```
Flutter 3.22.2 • channel stable
Framework • revision 761747bfc5 • 2024-06-05 22:15:13 +0200
Engine • revision edd8546116
Tools • Dart 3.4.3 • DevTools 2.34.3
```

# Get the dependencies
```
$ flutter pub get
```

# Running the app
```
$ flutter run
```

# Status
> ### Paused for now, but I’ll be working on it again soon. 🛑🔄🛠️

# To do
- Leave it generic enough to be able to create events and add their respective needs, such as payments
  - Add credentials
  - Make information registration more versatile
  - Create a part for creating events

# What is Rotaract?
Rotaract Clubs are clubs that promote social actions, environmental preservation and aim to train leaders. They are made up of young people/adults aged 18 and over. Clubs are typically affiliated with (or sponsored by) a local Rotary club.
