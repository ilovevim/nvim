local M = {}

--- 判断当前是否为竖屏环境（宽高比aspect ratio临界值）
---@return boolean
function M.is_vertical_screen()
	-- 基于宽高比经验值2区分竖屏，暂不调操作系统API
	return (vim.o.columns / vim.o.lines) < 2
end

return M
