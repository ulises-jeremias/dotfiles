# Rofi Bluetooth Module

The Rofi Bluetooth module is a custom module created around the [`internal/script`](https://github.com/polybar/polybar/wiki/Module:-script) module. It provides functionality to display the state of the Bluetooth connection and allows you to easily control the Bluetooth settings.

This module shows the state of the bluetooth. It uses the script `dots-scripts rofi-bluetooth` to get the state and listen for changes.

```sh
dots-scripts rofi-bluetooth --status | cut -d " " -f 1
```

You can customize the appearance and behavior of the Rofi Bluetooth module by modifying its configuration options. Refer to the [Polybar documentation](https://github.com/polybar/polybar/wiki/Module:-script) for a comprehensive list of configuration options that you can use to customize the module.

## Functionality

The Rofi Bluetooth module offers the following functionality:

- Bluetooth State: It shows the current state of the Bluetooth connection, indicating whether it is turned on or off.
- State Changes: The module listens for changes in the Bluetooth state and updates the displayed state accordingly.

## Rofi Bluetooth UI

The Rofi Bluetooth module provides an intuitive and interactive UI powered by Rofi, which allows you to control the Bluetooth settings easily. Here's a demonstration of the Rofi Bluetooth module in action:

![Rofi Bluetooth](https://raw.githubusercontent.com/wiki/ulises-jeremias/dotfiles/images/polybar/modules/rofi-bluetooth.gif)

You can use this UI to enable or disable Bluetooth, connect to available devices, and perform other Bluetooth-related actions.

Ensure that you have the necessary dependencies and configuration settings in place to use the Rofi Bluetooth module effectively.

Enjoy controlling your Bluetooth settings with the Rofi Bluetooth module in your Polybar configuration!