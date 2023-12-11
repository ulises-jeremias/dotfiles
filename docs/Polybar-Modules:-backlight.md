Here's an improved version of the documentation for the backlight modules:

# Backlight Modules

The backlight modules provide functionality to display the current brightness of the screen using different methods. We offer the following backlight modules:

- `modules/xbacklight`: Displays the current brightness of the screen using `xbacklight`.
- `module/backlight-acpi`: Displays the current brightness of the screen using `acpi`.
- `module/backlight-acpi-bar`: Displays the current brightness of the screen using `acpi` with a progress bar.

## Functionality

The backlight modules offer the following functionality:

- Scroll Up: Scrolling up on the module increases the screen brightness by 5% for each scroll step.
- Scroll Down: Scrolling down on the module decreases the screen brightness by 5% for each scroll step.
- Left Click: Clicking the module with the left mouse button toggles redshift.

Please note that the functionality of these modules depends on the underlying backlight control method used (e.g., `xbacklight` or `acpi`).

Enjoy convenient control of screen brightness and redshift toggling with the backlight modules in your Polybar setup.