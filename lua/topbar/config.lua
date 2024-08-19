local M = {}

M.mode = {
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
    },

    padding = 1  -- Adds padding left and right of the mode
}

M.time = {
    format = "%H:%M"
}

M.file_name = {
    labels = {
        modified = "+",
        read_only = "-",
        unnamed = "No Name",
        new = "New",
    },
}

return M
