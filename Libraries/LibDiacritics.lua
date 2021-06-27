-- The MIT License (MIT)

-- Copyright (c) 2021 Ilya Miller

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

local MAJOR_VERSION = 'LibDiacritics';
local MINOR_VERSION = 1;

local LibDiacritics;

if LibStub then
    local lib, minor = LibStub:GetLibrary(MAJOR_VERSION, true);
    if lib and minor and minor >= MINOR_VERSION then
        return lib;
    else
        LibDiacritics = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION);
    end
else
    LibDiacritics = {};
end

local Diacritics = {
    ['À'] = 'A',
    ['Á'] = 'A',
    ['Â'] = 'A',
    ['Ã'] = 'A',
    ['Ä'] = 'A',
    ['Å'] = 'A',
    ['Æ'] = 'AE',
    ['Ç'] = 'C',
    ['È'] = 'E',
    ['É'] = 'E',
    ['Ê'] = 'E',
    ['Ë'] = 'E',
    ['Ì'] = 'I',
    ['Í'] = 'I',
    ['Î'] = 'I',
    ['Ï'] = 'I',
    ['Ð'] = 'D',
    ['Ñ'] = 'N',
    ['Ò'] = 'O',
    ['Ó'] = 'O',
    ['Ô'] = 'O',
    ['Õ'] = 'O',
    ['Ö'] = 'O',
    ['Ø'] = 'O',
    ['Ù'] = 'U',
    ['Ú'] = 'U',
    ['Û'] = 'U',
    ['Ü'] = 'U',
    ['Ý'] = 'Y',
    ['Þ'] = 'P',
    ['ß'] = 's',
    ['à'] = 'a',
    ['á'] = 'a',
    ['â'] = 'a',
    ['ã'] = 'a',
    ['ä'] = 'a',
    ['å'] = 'a',
    ['æ'] = 'ae',
    ['ç'] = 'c',
    ['è'] = 'e',
    ['é'] = 'e',
    ['ê'] = 'e',
    ['ë'] = 'e',
    ['ì'] = 'i',
    ['í'] = 'i',
    ['î'] = 'i',
    ['ï'] = 'i',
    ['ð'] = 'eth',
    ['ñ'] = 'n',
    ['ò'] = 'o',
    ['ó'] = 'o',
    ['ô'] = 'o',
    ['õ'] = 'o',
    ['ö'] = 'o',
    ['ø'] = 'o',
    ['ù'] = 'u',
    ['ú'] = 'u',
    ['û'] = 'u',
    ['ü'] = 'u',
    ['ý'] = 'y',
    ['þ'] = 'p',
    ['ÿ'] = 'y',
};

function LibDiacritics:Replace(str)
    str = str or '';

    return string.gsub(str, "[%z\1-\127\194-\244][\128-\191]*", Diacritics);
end

return LibDiacritics;