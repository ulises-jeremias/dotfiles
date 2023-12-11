# i3 Workspace Icon Module

The i3 Workspace Icon module displays the icon for each workspace in the i3 window manager. It provides convenient functionality to switch between workspaces and navigate through them.

## Functionality

The i3 Workspace Icon module supports the following events:

- **Left-click**: Clicking on the module with the left mouse button executes the `i3-msg workspace <index>` command, allowing you to switch to a specific workspace by specifying its index.
- **Scroll up**: Scrolling up on the module executes the `i3-msg workspace prev` command, allowing you to switch to the previous workspace.
- **Scroll down**: Scrolling down on the module executes the `i3-msg workspace next` command, allowing you to switch to the next workspace.

By interacting with the i3 Workspace Icon module, you can easily navigate between workspaces in your i3 window manager setup.

Please note that this module assumes you have the necessary dependencies and configurations set up for i3 window manager, such as `i3-msg` and properly configured workspaces.

Feel free to customize the appearance and behavior of the i3 Workspace Icon module according to your preferences to enhance your workspace navigation experience.
