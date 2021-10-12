local present, autosave = pcall(require, "autosave")
if not present then
  return
end

autosave.setup {
  enabled = true,
  execution_message = " 💾 saving...",
  events = {"InsertLeave", "TextChanged"},
  conditions = {
      exists = true,
      filename_is_not = {},
      filetype_is_not = {},
      modifiable = true
  },
  write_all_buffers = false,
  on_off_commands = true,
  clean_command_line_interval = 1000,
  debounce_delay = 135
}
