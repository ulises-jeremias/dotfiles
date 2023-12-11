We encourage you to use `dots` as a tool to keep your dotfiles always updated and maintain a consistent configuration across your systems. However, we understand that there may be situations where you want to have your own independent distribution of dotfiles.

To eject from `dots` and create your own dotfiles distribution, you can follow these steps:

1. Create a copy of the entire `<dotfiles_dir>` directory. This will serve as the foundation for your custom dotfiles setup.

2. Within the copied directory, you will find a script named `install`. This script can be used as a starting point for your own dotfiles installation process. You can modify it according to your needs and preferences.

3. Review the contents of the `install` script and customize it to suit your requirements. You can add or remove installation steps, update paths, or make any other necessary adjustments.

4. Once you have customized the `install` script and set up your dotfiles according to your preferences, you can use it to deploy your dotfiles on different systems or share them with others.

Remember that by ejecting from `dots`, you are taking full responsibility for maintaining and updating your dotfiles. It's recommended to establish a version control system (such as Git) to track changes and easily synchronize your dotfiles across multiple machines.

Feel free to explore and modify the `install` script and other files in your copied dotfiles directory to create a customized dotfiles distribution that perfectly suits your needs. Happy dotfile customization! ✨🔧
