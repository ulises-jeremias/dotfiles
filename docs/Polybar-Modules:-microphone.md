Apologies for the confusion. Here's the updated documentation for the Microphone module, including the images table:

# Microphone Module

The Microphone module is a custom module created around the `internal/script` module in Polybar. It displays the state of the microphone and listens for status changes using the script `dots microphone`.

| Muted                                                                                                                                  | Unmuted                                                                                                                                    |
| :------------------------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------- |
| ![Microphone Muted](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/microphone-muted.jpg?raw=true) | ![Microphone Unmuted](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/microphone-unmuted.jpg?raw=true) |

## Usage

The Microphone module provides real-time updates on the microphone status, allowing you to quickly see whether the microphone is currently muted or unmuted.

## Icons

The Microphone module uses the following icons to represent the microphone state:

- **Muted**: The microphone is muted.
- **Unmuted**: The microphone is unmuted.

The icons can be customized to match your preferred style and aesthetic.

In this configuration, the module utilizes the `dots microphone` script to retrieve the microphone state.
