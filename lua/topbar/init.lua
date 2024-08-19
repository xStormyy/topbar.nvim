-- Credits to:
-- https://github.com/MariaSolOs/dotfiles/blob/f1d6229f4a4675745aff95c540dc8f1b9007a77a/.config/nvim/lua/winbar.lua

-- local render = require("topbar.render")

local conf = require("topbar.config")

local M = {}

M.setup = function(args)
    -- M.config = vim.tbl_deep_extend("keep", M.config, args or {})
    conf = vim.tbl_deep_extend("keep", conf, args or {})
end

function M.component_mode()
    local mode_to_str = {
        ['n'] = conf.mode.labels.normal,
        ['no'] = conf.mode.labels.op_pending,
        ['nov'] = conf.mode.labels.op_pending,
        ['noV'] = conf.mode.labels.op_pending,
        ['no\22'] = conf.mode.labels.op_pending,
        ['niI'] = conf.mode.labels.normal,
        ['niR'] = conf.mode.labels.normal,
        ['niV'] = conf.mode.labels.normal,
        ['nt'] = conf.mode.labels.normal,
        ['ntT'] = conf.mode.labels.normal,
        ['v'] = conf.mode.labels.visual,
        ['vs'] = conf.mode.labels.visual,
        ['V'] = conf.mode.labels.visual,
        ['Vs'] = conf.mode.labels.visual,
        ['\22'] = conf.mode.labels.visual,
        ['\22s'] = conf.mode.labels.visual,
        ['s'] = conf.mode.labels.select,
        ['S'] = conf.mode.labels.select,
        ['\19'] = conf.mode.labels.select,
        ['i'] = conf.mode.labels.insert,
        ['ic'] = conf.mode.labels.insert,
        ['ix'] = conf.mode.labels.insert,
        ['R'] = conf.mode.labels.replace,
        ['Rc'] = conf.mode.labels.replace,
        ['Rx'] = conf.mode.labels.replace,
        ['Rv'] = conf.mode.labels.vir_replace,
        ['Rvc'] = conf.mode.labels.vir_replace,
        ['Rvx'] = conf.mode.labels.vir_replace,
        ['c'] = conf.mode.labels.command,
        ['cv'] = conf.mode.labels.ex,
        ['ce'] = conf.mode.labels.ex,
        ['r'] = conf.mode.labels.prompt,
        ['rm'] = conf.mode.labels.more,
        ['r?'] = conf.mode.labels.confirm,
        ['!'] = conf.mode.labels.shell,
        ['t'] = conf.mode.labels.terminal,
    }

    local mode = mode_to_str[vim.api.nvim_get_mode().mode] or ""

    local highlight = ""

    if mode:find(conf.mode.labels.normal) or mode:find(conf.mode.labels.op_pending) then
        highlight = "%#StatusNormal#"
    elseif mode:find(conf.mode.labels.visual) then
        highlight = "%#StatusVisual#"
    elseif mode:find(conf.mode.labels.insert) or mode:find(conf.mode.labels.select) then
        highlight = "%#StatusInsert#"
    else
        highlight = "%#StatusNormal#"
    end

    return table.concat {
        string.format("%s", highlight),
        string.format("%s", string.rep(" ", conf.mode.padding)),
        string.format("%s", mode),
        string.format("%s", string.rep(" ", conf.mode.padding)),
        string.format("%s", "%#StatusLine#"),
    }

end

function M.component_position()
    local line = vim.fn.line(".")
    local column = vim.fn.charcol(".")

    return string.format("%d:%d", line, column)

end

function M.component_progress()
    local current_line = vim.fn.line(".")
    local bottom = vim.fn.line("$")

    if current_line == 1 then
        return "Top"
    elseif current_line == bottom then
        return "Bottom"
    else
        return string.format("%2d%%%%", math.floor(current_line / bottom * 100))
    end

end

-- TODO: make it only show filenamw instead of path
function M.component_filename()
    if vim.bo.modified then
        return "%f " .. string.format("[%s]", conf.file_name.labels.modified)
    elseif vim.bo.modifiable == false or vim.bo.readonly then
        return "%f " .. string.format("[%s]", conf.file_name.labels.read_only)
    else
        return "%f"
    end

end

-- TODO: proper implementation
function M.component_git()
    local HEAD_file = io.open(".git/HEAD")
    if HEAD_file then
        local head = HEAD_file:read()
        HEAD_file:close()
        local branch = head:match("ref: refs/heads/(.+)$")
        if branch then
            return branch
        else
            return "uhhhhhhh"
        end
    end

end

-- TODO: Make it update not when buffer changes
function M.component_time()
    return os.date(conf.time.format)
end

function M.component_search_count()
    
end

-- TODO: Proper implementation
function M.component_recent_keybind()
    return vim.keycode
end

-- Displaying contents of topbar
-- Add configuration similar to lualine
function M.render()
    local mode = M.component_mode()
    local filename = M.component_filename()
    local pos = M.component_position()
    -- local branch = M.component_git()
    local time = M.component_time()

    return table.concat {
        "%#StatusLine#", -- %#StatusLine#%=
        mode,
        " ",
        filename,
        " ",
        pos,
        " ",
        time,
        " ",
        M.component_progress()
    }
end

-- Setup for bar
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("the/topbar", { clear = true }),
    desc = "topbar",
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex      -- not floating window
            and vim.bo[args.buf].buftype == ""             -- normal buffer
            and vim.api.nvim_buf_get_name(args.buf) ~= ""  -- has a file name
            and not vim.wo[0].diff                         -- not in diff mode
        then
        vim.wo.winbar = "%{%v:lua.require('topbar').render()%}"
        end
    end,
})

return M
