LETTER_LENGTHS = {}
LETTERS = " 0123456789abcedfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ;'@#.,!/\\-+_=?[]"

function make_letter_lengths()
    for i=1,#LETTERS do
        local letter = string.sub(LETTERS, i, i)
        if letter == "'" or letter == "!" or letter == "." then
            LETTER_LENGTHS[letter] = 1
        elseif letter == " " or letter == ";" or letter == "," then
            LETTER_LENGTHS[letter] = 2
        elseif letter == "i" or letter == "l" or letter == "1" or letter == "$" or letter == "-"
        or letter == "+" or letter == "[" or letter == "]" then
            LETTER_LENGTHS[letter] = 3
        elseif letter == "j" or letter == "k" then
            LETTER_LENGTHS[letter] = 4
        elseif letter == "@" then
            LETTER_LENGTHS[letter] = 9
        else
            LETTER_LENGTHS[letter] = 5
        end
    end
end

function get_string_px(str)
    local out = 0
    local letter = ""
    local line_length = 0
    for i=1,#str do
        letter = string.sub(str, i, i)
        if LETTER_LENGTHS[letter] ~= nil then
            out = out + LETTER_LENGTHS[letter] + 1
        else
            out = out + 6
        end
    end
    if out > 0 then
        out = out - 1
    end
    return out
end