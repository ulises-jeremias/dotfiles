# Pulseaudio Volume Module

The Pulseaudio Volume module displays the volume and mute state for Pulseaudio. It provides two different flavors: `pulseaudio` and `pulseaudio-bar`.

## `pulseaudio` Flavor

The `pulseaudio` flavor is a simple wrapper around the [`internal/pulseaudio`](https://github.com/polybar/polybar/wiki/Module:-pulseaudio) module. It shows the volume and mute state of the default sink.

| Muted                                                                                                                  | 75 %                                                                                                                | 100 %                                                                                                                |
| :--------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------- |
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-100.jpg?raw=true) |

## `pulseaudio-bar` Flavor

The `pulseaudio-bar` flavor is a simple wrapper around `pulseaudio` that displays the volume and mute state of the default sink as a bar.

| Muted                                                                                                                  | 75 %                                                                                                                    | 100 %                                                                                                                    |
| :--------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-bar-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pulseaudio-bar-100.jpg?raw=true) |

Feel free to choose the flavor that best suits your preferences and integrate it into your Polybar setup.
