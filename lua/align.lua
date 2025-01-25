local M = {}

function M.align(pat)
    local top, bot = vim.fn.getpos("'<"), vim.fn.getpos("'>")
    M.align_lines(pat, top[2] - 1, bot[2])
    vim.fn.setpos("'<", top)
    vim.fn.setpos("'>", bot)
end

function M.align_lines(pat, startline, endline)
    local re = vim.regex(pat)
    local lines = vim.api.nvim_buf_get_lines(0, startline, endline, false)

    local max_positions = {}
    local split_lines = {}

    for _, line in ipairs(lines) do
        local parts = vim.split(line, pat, { plain = true, trimempty = false })
        table.insert(split_lines, parts)

        for i, part in ipairs(parts) do
            local length = vim.str_utfindex(part)
            max_positions[i] = math.max(max_positions[i] or 0, length)
        end
    end

    for i, parts in ipairs(split_lines) do
        local new_line = {}
        for j, part in ipairs(parts) do
            if j < #parts then
                table.insert(new_line, part .. string.rep(" ", max_positions[j] - vim.str_utfindex(part)))
            else
                table.insert(new_line, part)
            end
        end
        lines[i] = table.concat(new_line, pat)
    end

    vim.api.nvim_buf_set_lines(0, startline, endline, false, lines)
end

return M

