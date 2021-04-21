local gl = require("galaxyline")
local colors = {
    bg = "#2E3440",
    lightbg = "#3B4252",
    linebg = "NONE",
    fg = "#81A1C1",
    yellow = "#EBCB8B",
    cyan = "#A3BE8C",
    darkblue = "#81A1C1",
    green = "#8FBCBB",
    orange = "#D08770",
    violet = "#B48EAD",
    magenta = "#BF616A",
    blue = "#5E81AC",
    red = "#BF616A"
}
local condition = require("galaxyline.condition")
local gls = gl.section
gl.short_line_list = {"NvimTree", "packer"}

gls.left[1] = {
    leftRounded = {
        provider = function()
            return ""
        end,
        highlight = {colors.blue, colors.bg}
    }
}

gls.left[2] = {
    statusIcon = {
        provider = function()
            return "   "
        end,
        highlight = {colors.bg, colors.blue},
        separator = " ",
        separator_highlight = {colors.lightbg, colors.lightbg}
    }
}

gls.left[3] = {
    FileIcon = {
        provider = "FileIcon",
        condition = condition.buffer_not_empty,
        highlight = {require("galaxyline.provider_fileinfo").get_file_icon_color, colors.lightbg}
    }
}

gls.left[4] = {
    FileName = {
        provider = {"FileName", "FileSize"},
        condition = condition.buffer_not_empty,
        highlight = {colors.fg, colors.lightbg}
    }
}

gls.left[5] = {
    leftRightRounded = {
        provider = function()
            return ""
        end,
        separator = " ",
        highlight = {colors.lightbg, colors.bg}
    }
}

local checkwidth = function()
    local squeeze_width = vim.fn.winwidth(0) / 2
    if squeeze_width > 40 then
        return true
    end
    return false
end

gls.left[6] = {
    DiffAdd = {
        provider = "DiffAdd",
        condition = checkwidth,
        icon = "   ",
        highlight = {colors.green, colors.linebg}
    }
}

gls.left[7] = {
    DiffModified = {
        provider = "DiffModified",
        condition = checkwidth,
        icon = " ",
        highlight = {colors.orange, colors.linebg}
    }
}

gls.left[8] = {
    DiffRemove = {
        provider = "DiffRemove",
        condition = checkwidth,
        icon = " ",
        highlight = {colors.red, colors.linebg}
    }
}

gls.left[9] = {
    LeftEnd = {
        provider = function()
            return " "
        end,
        separator = " ",
        separator_highlight = {colors.linebg, colors.linebg},
        highlight = {colors.linebg, colors.linebg}
    }
}

gls.left[10] = {
    DiagnosticError = {
        provider = "DiagnosticError",
        icon = "  ",
        highlight = {colors.red, colors.bg}
    }
}

gls.left[11] = {
    Space = {
        provider = function()
            return " "
        end,
        highlight = {colors.linebg, colors.linebg}
    }
}

gls.left[12] = {
    DiagnosticWarn = {
        provider = "DiagnosticWarn",
        icon = "  ",
        highlight = {colors.blue, colors.bg}
    }
}

gls.right[1] = {
    GitIcon = {
        provider = function()
            return "   "
        end,
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {colors.green, colors.linebg}
    }
}

gls.right[2] = {
    GitBranch = {
        provider = "GitBranch",
        condition = require("galaxyline.provider_vcs").check_git_workspace,
        highlight = {colors.green, colors.linebg}
    }
}

gls.right[3] = {
    rightLeftRounded = {
        provider = function()
            return ""
        end,
        separator = " ",
        separator_highlight = {colors.bg, colors.bg},
        highlight = {colors.red, colors.bg}
    }
}

gls.right[4] = {
    ViMode = {
        provider = function()
            local alias = {
                n = "NORMAL",
                i = "INSERT",
                c = "COMMAND",
                V = "VISUAL",
                [""] = "VISUAL",
                v = "VISUAL",
                R = "REPLACE"
            }
            return alias[vim.fn.mode()]
        end,
        highlight = {colors.bg, colors.red}
    }
}

gls.right[5] = {
    Percent = {
        provider = "LinePercent",
        separator = " ",
        separator_highlight = {colors.red, colors.red},
        highlight = {colors.bg, colors.fg}
    }
}

gls.right[6] = {
    rightRounded = {
        provider = function()
            return ""
        end,
        highlight = {colors.fg, colors.bg}
    }
}

gls.short_line_left[1] = {
    BufferType = {
        provider = "FileTypeName",
        separator = " ",
        separator_highlight = {"NONE", colors.bg},
        highlight = {colors.blue, colors.bg, "bold"}
    }
}

gls.short_line_left[2] = {
    SFileName = {
        provider = "SFileName",
        condition = condition.buffer_not_empty,
        highlight = {colors.fg, colors.bg, "bold"}
    }
}

gls.short_line_right[1] = {
    BufferIcon = {
        provider = "BufferIcon",
        highlight = {colors.fg, colors.bg}
    }
}

