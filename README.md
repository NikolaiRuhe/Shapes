##  Bezier Drawing App

This is a simple bezier drawing app.

- Applicant: Nikolai Ruhe
- Date: 2019-02-12
- Time used: 7.5h

### Full description

> Build a simple drawing app that allows the user to create simple bezier objects in an editing window.
> The user can pick a simple preset shape (circle, square, rounded rectangle, star, etc), assign dimensions
> and a unique name when the bezier path is created.
>
> Once a bezier shape has been created, the user can edit the shape path’s anchors and handles to modify
> the paths. The user should also be able to select and translate the entire shape path (when not clicking on
> an anchor or handle).
>
> Paths that show up in the editing window should also show in a list view which displays the path name
> and path visibility. The user can toggle visibility of each path individually from the list view.

> - Architecture and code quality are key
> - Cocoa with no third-party libraries
> - Swift or Objective-C
> - No need to support scrolling or zooming in the drawing view
> - UI design is up to you
> - Should not take more than 2 days of work; Please track your time
> - macOS preferred but can be done in iOS for iPad (if you are open to learning macOS later)


### Architecture Notes

I'm using the following patterns:

- The app is separated into modules (currently only "Model" and "UI"). In a real world app this would probably
be actual Swift modules (libraries) but for this simple app I just keep source files separated in subfolders.
- The UI layer is separated into "scenes". Each scene represents a screen or main part of a screen. The files
making up a scene (swift, storyboard) are kept together in subfolders.
- Storyboards are used to model the UI but with one storyboard file per scene. No segues.
- Swift code is separated into extensions as much as possible. Only stuff that needs to be in the main type
declaration goes there (required initializers, stored properties, overrides). Everything else has its own `extension`.  
