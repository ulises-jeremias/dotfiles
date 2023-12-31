Openbox is a lightweight and highly configurable window manager that provides a simple yet powerful environment for managing windows in your desktop. With its flexibility and extensive customization options, Openbox allows you to create a personalized and efficient workflow.

The `openbox` configuration files are located at `~/.config/openbox`. This gives you the freedom to fully customize and fine-tune Openbox according to your preferences.

To edit the `openbox` configuration, you need to run the following command:

```sh
chezmoi edit ~/.config/openbox
```

Remember to apply your changes using `chezmoi apply` and restart Openbox for the modifications to take effect.

## Configuring Openbox

To simplify the configuration process, you can use `obconf`, a graphical configuration tool designed specifically for Openbox. `obconf` provides an intuitive interface that allows you to easily customize various aspects of Openbox, including window appearance, desktop settings, mouse behavior, and more.

If `obconf` is available in your package manager, you can install it using the appropriate installation command for your operating system. Once installed, you can launch `obconf` and explore the wide range of customization options it offers.

![Openbox Config](https://github.com/ulises-jeremias/dotfiles/blob/master/docs/images/obconf.jpg?raw=true)

Using `obconf`, you can conveniently tweak and adjust Openbox without directly modifying the configuration files. This makes it easy to experiment, fine-tune your settings, and create a seamless desktop experience tailored to your workflow.

If `obconf` is not available in your package manager, don't worry! You can still configure Openbox by manually editing the configuration files located at `~/.config/openbox`. These files provide detailed control over various aspects of Openbox's behavior, allowing you to customize window placement, keybindings, desktop menus, and much more.

Remember to save your configuration changes and restart Openbox for the modifications to take effect. This will ensure that your personalized Openbox setup is applied and ready to enhance your productivity and workflow.

Unleash the power of Openbox and create a unique desktop environment that reflects your style and optimizes your daily tasks!
