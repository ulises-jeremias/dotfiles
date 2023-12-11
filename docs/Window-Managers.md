🖌️ You can customize the installed window managers, including i3, Openbox, and XFCE4, to suit your preferences and workflow. Here's how you can customize each of them:

## i3 Window Manager

To customize i3, you can modify the configuration files located in the `~/.config/i3` directory. These files control various aspects of i3's behavior, such as keybindings, workspace layouts, and appearance. After making any changes, run the command `chezmoi apply` to update the i3 configuration.

For more detailed instructions and information about i3 customization, please refer to the [i3 customization documentation](i3).

## Openbox Window Manager

For customizing Openbox, you can edit the configuration files located in the `~/.config/openbox` directory. These files define the behavior, appearance, and keybindings for Openbox. Make your desired changes to these files, and then run command `chezmoi apply` to apply the changes.

If you need additional guidance or want to explore more about Openbox customization, please visit the [Openbox customization documentation](Openbox).

## XFCE4 Window Manager

XFCE4 customization is handled through the xfce4 tools included in the dotfiles installation. To customize XFCE4, use the xfce4 settings manager (`xfce4-settings-manager`). This utility allows you to modify various aspects of the XFCE4 desktop environment, including themes, appearance, panels, and more. Any customizations made through the xfce4 settings manager will be applied globally to all the installed dotfiles and affect all the window managers you have installed.

For more detailed instructions and tips on XFCE4 customization, please refer to the [XFCE4 customization documentation](Xfce4).

🔧 Remember to run command `chezmoi apply` after making any changes to the configuration files to ensure that the customizations are applied.

Feel free to customize each window manager according to your preferences, and if you have any further questions or need more specific guidance, please refer to the respective documentation for each window manager.

---

**IMPORTANT**: If you encounter any issues or need further assistance with customization, please refer to the dotfiles documentation or seek help from the dotfiles community.
