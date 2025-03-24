# 🧠 Polybar Module: Memory

The **Memory module** displays real-time statistics about your system’s RAM usage. It’s a simple yet essential module to help you monitor memory consumption at a glance.

> [!TIP]
> Great for keeping tabs on memory-intensive workflows, especially when multitasking or debugging.

---

## 📊 Displayed Information

- **Total Memory**: The total available memory on your system
- **Used Memory**: The amount currently in use
- **Usage Percentage**: A live percentage calculated as `(Used / Total) * 100`

---

## ⚙️ Configuration Example

```ini
[module/memory]
type = internal/memory
interval = 5
format =   %used% / %total% (%percentage%%)
format-underline = #6c71c4
```

> [!TIP]
> Icons like `` can be swapped based on your font (e.g., Nerd Fonts).

---

## ✅ Requirements

- No additional dependencies required — this is a built-in Polybar module
- Works out of the box with Linux systems that expose `/proc/meminfo`

---

## 🎨 Customization Tips

- Use `format-prefix` and `format-suffix` to add context or emojis
- Combine with a temperature or CPU module for a complete resource view
- Adjust `interval` to control how often memory data is refreshed

---

Keep your resource usage in check and optimize your system performance with this lightweight monitor! 📈
