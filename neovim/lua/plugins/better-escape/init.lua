local is_present_better_escape, better_escape = pcall(require, "better_escape")

if not is_present_better_escape then
  return
end

better_escape.setup {}
