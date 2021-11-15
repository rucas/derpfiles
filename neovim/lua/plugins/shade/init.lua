local present, shade = pcall(require, "shade")

if not present then
	return
end

shade.setup({
	overlay_opacity = 50,
	opacity_step = 1,
	keys = {
		brightness_up = "<C-Up>",
		brightness_down = "<C-Down>",
		toggle = "<Leader>sh",
	},
})
