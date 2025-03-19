# Description
It is a flutter project to serve as a check-in at places and events

# How it works
Only the event organizers have access to the app, they then register a visitor for the event by adding their data, and then a QR-Code is generated which is sent directly to the registered visitor.

So, when entering, the visitor simply presents their QR-Code and the organizers will read the QR-Code with the application, allowing the visitor to check in.

For paid events, the application is also used to check whether the visitor has already paid or needs to pay.

PS: Currently the application works as if it were for just one event, to use it for another you would have to clean the entire database, but in the future I intend to make it more generic
PS2: The idea of ​​the application was created to handle event accreditations for the [Rotaract](https://www.rotary.org/en/get-involved/rotaract-clubs) Club de Erechim volunteer club in Brazil in a more automatic way that allows for fewer errors.

# Version
```
flutter: 3.29.2
dart: 3.7.2
```

# Get the dependencies
```
$ flutter pub get
```

# Configure criptography key on lib/criptographyKey.dart

# Running the app
```
$ flutter run
```

# Status
> ### Paused for now, but I’ll be working on it again soon. 🛑🔄🛠️

# To do
- Leave it generic enough to be able to create events and add their respective needs, such as payments
  - Export QR Code as an image
  - Export PDF Report
  - Improve encryption
  - Add credentials
  - Hub to access multiple projects

# What is Rotaract?
Rotaract Clubs are clubs that promote social actions, environmental preservation and aim to train leaders. They are made up of young people/adults aged 18 and over. Clubs are typically affiliated with (or sponsored by) a local Rotary club.
