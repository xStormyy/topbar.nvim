-- Credits to:
-- https://github.com/MariaSolOs/dotfiles/blob/f1d6229f4a4675745aff95c540dc8f1b9007a77a/.config/nvim/lua/winbar.lua

-- local render = require("topbar.render")

local M = {}

M.config = {

    mode = {
        labels = {
            normal = "NORMAL",
            insert = "INSERT",
            visual = "VISUAL",
            select = "SELECT",
            terminal = "TERMINAL",
            command = "COMMAND",
            op_pending = "OP-PENDING",
            replace = "REPLACE",
            vir_replace = "VIR-REPLACE",
            more = "MORE",
            confirm = "CONFIRM",
            ex = "EX",
            shell = "SHELL",
            prompt = "PROMPT",
        }
    },

    time = {
        format = "%H:%M"
    }
}

M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})
end

-- TODO add colored background
function M.component_mode()
    local mode_to_str = {
        ['n'] = M.config.mode.labels.normal,
        ['no'] = M.config.mode.labels.op_pending,
        ['nov'] = M.config.mode.labels.op_pending,
        ['noV'] = M.config.mode.labels.op_pending,
        ['no\22'] = M.config.mode.labels.op_pending,
        ['niI'] = M.config.mode.labels.normal,
        ['niR'] = M.config.mode.labels.normal,
        ['niV'] = M.config.mode.labels.normal,
        ['nt'] = M.config.mode.labels.normal,
        ['ntT'] = M.config.mode.labels.normal,
        ['v'] = M.config.mode.labels.visual,
        ['vs'] = M.config.mode.labels.visual,
        ['V'] = M.config.mode.labels.visual,
        ['Vs'] = M.config.mode.labels.visual,
        ['\22'] = M.config.mode.labels.visual,
        ['\22s'] = M.config.mode.labels.visual,
        ['s'] = M.config.mode.labels.select,
        ['S'] = M.config.mode.labels.select,
        ['\19'] = M.config.mode.labels.select,
        ['i'] = M.config.mode.labels.insert,
        ['ic'] = M.config.mode.labels.insert,
        ['ix'] = M.config.mode.labels.insert,
        ['R'] = M.config.mode.labels.replace,
        ['Rc'] = M.config.mode.labels.replace,
        ['Rx'] = M.config.mode.labels.replace,
        ['Rv'] = M.config.mode.labels.vir_replace,
        ['Rvc'] = M.config.mode.labels.vir_replace,
        ['Rvx'] = M.config.mode.labels.vir_replace,
        ['c'] = M.config.mode.labels.command,
        ['cv'] = M.config.mode.labels.ex,
        ['ce'] = M.config.mode.labels.ex,
        ['r'] = M.config.mode.labels.prompt,
        ['rm'] = M.config.mode.labels.more,
        ['r?'] = M.config.mode.labels.confirm,
        ['!'] = M.config.mode.labels.shell,
        ['t'] = M.config.mode.labels.terminal,
    }

    local mode = mode_to_str[vim.api.nvim_get_mode().mode] or ""
    -- return mode

    local highlight = ""

    if mode:find(M.config.mode.labels.normal) or mode:find(M.config.mode.labels.op_pending) then
        highlight = "%#StatusNormal#"
    elseif mode:find(M.config.mode.labels.visual) then
        highlight = "%#StatusVisual#"
    elseif mode:find(M.config.mode.labels.insert) or mode:find(M.config.mode.labels.select) then
        highlight = "%#StatusInsert#"
    else
        highlight = "%#StatusNormal#"
    end

    return string.format("%s %s %s", highlight, mode, "%#StatusLine#")
end

function M.component_position()
    local line = vim.fn.line(".")
    local column = vim.fn.charcol(".")

    return string.format("%d:%d", line, column)
end

function M.component_filename()
    return "%f"
end

-- TODO: proper implementation
function M.component_git()
    local head = os.execute("git branch")

    return string.format("%s", head)
end

-- TODO: Make it update not when buffer changes
function M.component_time()
    return os.date(M.config.time.format)
end

function M.component_search_count()
    
end

-- Displaying contents of topbar
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
        time
    }
end

-- Setup for bar to be on top
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
