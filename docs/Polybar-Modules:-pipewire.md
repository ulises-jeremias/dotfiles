# PipeWire Volume Module

The PipeWire Volume module displays the volume and mute state for PipeWire. It provides two different flavors: `pipewire` and `pipewire-bar`.

## `pipewire` Flavor

The `pipewire` flavor is a simple wrapper around the [`internal/pipewire`](https://github.com/polybar/polybar/wiki/Module:-pipewire) module. It shows the volume and mute state of the default sink.

| Muted                                                                                                                  | 75 %                                                                                                                | 100 %                                                                                                                |
| :--------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------- |
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-100.jpg?raw=true) |

## `pipewire-bar` Flavor

The `pipewire-bar` flavor is a simple wrapper around `pipewire` that displays the volume and mute state of the default sink as a bar.

| Muted                                                                                                                  | 75 %                                                                                                                    | 100 %                                                                                                                    |
| :--------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-muted.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-bar-75.jpg?raw=true) | ![](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/polybar/modules/pipewire-bar-100.jpg?raw=true) |

Feel free to choose the flavor that best suits your preferences and integrate it into your Polybar setup.
