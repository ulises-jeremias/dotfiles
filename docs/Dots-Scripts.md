In the dotfiles installation process, various scripts are added for configuring applications and modules. While these scripts are primarily used for module configuration, they can also be used independently. To simplify the management of these scripts, we provide the `dots` utility.

The `dots` utility provides a convenient way to manage and execute these scripts. You can explore their functionalities and customize them as needed.

## Usage

```sh
dots --help    # Show help
dots --list    # List all available scripts
dots <script>  # Run a specific script with optional flags
```

## Available Scripts

> NOTE: The following list may not be exhaustive. You can always check the up-to-date list of scripts by running `dots --list`.

- `brightness`: Control the screen brightness using various backends such as `xbacklight`, `brightnessctl`, `blight`, or `xrandr`.
- `check-network`: Check if the network connection is up.
- `checkupdates`: Check for updates.
- `feh-blur`: Blur the background of the current window when using `feh` to set the wallpaper.
- `git-notify`: Show a notification when a git commit is made.
- `microphone`: Control the microphone settings.
- `monitor`: Print the name of the current monitor.
- `night-mode`: Toggle night mode.
- `openweathermap-detailed`: Print detailed weather information.
- `popup-calendar`: Show a calendar in a popup.
- `rofi-bluetooth`: Show a rofi menu to manage Bluetooth devices.
- `rofi-randr`: Show a rofi menu to manage the screen resolution.
- `rofi-run`: Show a rofi menu to run commands.
- `rofi-xrandr`: Show a rofi menu to manage the screen resolution with charts.
- `screenshooter`: Take a screenshot.
- `spotify`: Get information about the currently playing song in Spotify.
- `sysupdate`: Update the system.
- `toggle`: Toggle the state of specific applications.
- `updates`: Check for updates.
- `weather`: Print the current weather information.

Feel free to use these scripts to enhance your system configuration and workflow!
