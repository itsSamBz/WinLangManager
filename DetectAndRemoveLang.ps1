# ============================================
#  Script: Detect and Remove Windows Languages & Keyboards
#  Dev Githuhb @itsSamBz   
#  Version: 1.0
# ============================================

# Enable colored text
function Write-Color {
    param (
        [string]$Text,
        [string]$Color = "White"
    )
    Write-Host $Text -ForegroundColor $Color
}

# Display script info
Write-Color "============================================" "Cyan"
Write-Color " Script: Detect and Remove Languages/Keyboards" "Yellow"
Write-Color " Developer: @itsSamBz. " "Green"
Write-Color " Version: 1.0" "Magenta"
Write-Color "============================================`n" "Cyan"

# Keyboard Layout Mapping (Now with the top 20 most used languages!)
$keyboardMap = @{
    "00000409" = "US QWERTY"             # English (United States)
    "0000040C" = "French AZERTY"         # French (France)
    "00020401" = "Arabic (AZERTY)"       # Arabic (Algeria)
    "0000040A" = "Spanish QWERTY"        # Spanish (Spain)
    "00000407" = "German QWERTZ"         # German (Germany)
    "00000410" = "Italian QWERTY"        # Italian (Italy)
    "00000804" = "Simplified Chinese"    # Chinese (Simplified, China)
    "00000411" = "Japanese Kana"         # Japanese
    "00000416" = "Portuguese (Brazil)"   # Portuguese (Brazil)
    "00000419" = "Russian Cyrillic"      # Russian
    "00000405" = "Czech QWERTZ"          # Czech
    "0000040E" = "Hungarian QWERTZ"      # Hungarian
    "00000415" = "Polish QWERTY"         # Polish
    "0000041D" = "Swedish QWERTY"        # Swedish
    "0000041F" = "Turkish QWERTY"        # Turkish (Turkey)
    "00000412" = "Korean Hangul"         # Korean
    "00000418" = "Romanian QWERTY"       # Romanian
    "0000041A" = "Slovak QWERTZ"         # Slovak
    "00000402" = "Bulgarian BDS"         # Bulgarian
    "00000406" = "Danish QWERTY"         # Danish
    "00000408" = "Greek QWERTY"          # Greek
    "00000417" = "Lithuanian AZERTY"     # Lithuanian
    "0000041E" = "Thai Kedmanee"         # Thai
    "00000421" = "Ukrainian QWERTY"      # Ukrainian
}


# Get installed languages
$languages = Get-WinUserLanguageList

# If no languages are found, exit the script
if ($languages.Count -eq 0) {
    Write-Color "No installed languages detected!" "Red"
    Exit
}

Write-Color "========= Installed Languages and Keyboards =========" "Cyan"

$index = 1
$choices = @{}

# Display languages and their keyboards
foreach ($lang in $languages) {
    $kbList = @()
    foreach ($kb in $lang.InputMethodTips) {
        $kbParts = $kb -split ":"
        $kbID = $kbParts[-1]
        
        if ($keyboardMap.ContainsKey($kbID)) {
            $kbName = $keyboardMap[$kbID]
        } else {
            $kbName = "Unknown ($kbID)"
        }
        
        $kbList += $kbName
    }
    
    Write-Color "$index. $($lang.LanguageTag) (Keyboards: $($kbList -join ', '))" "Green"
    $choices[$index] = $lang
    $index++
}

# Ask the user which language to modify
$selection = Read-Host "`nEnter the number of the language to modify (or 0 to exit)"

if ($selection -eq "0") {
    Exit
}

if (-not $choices.ContainsKey([int]$selection)) {
    Write-Color "Invalid selection! Exiting..." "Red"
    Exit
}

$selectedLang = $choices[[int]$selection]

# Ask whether to remove the whole language or just a keyboard
Write-Color "`nYou selected: $($selectedLang.LanguageTag)" "Yellow"
Write-Color "1. Remove the entire language" "Magenta"
Write-Color "2. Remove a specific keyboard" "Magenta"
$choice = Read-Host "Enter your choice"

if ($choice -eq "1") {
    # Remove the whole language
    $newLangList = $languages | Where-Object { $_.LanguageTag -ne $selectedLang.LanguageTag }
    Set-WinUserLanguageList -LanguageList $newLangList -Force
    Write-Color "Language $($selectedLang.LanguageTag) removed!" "Green"
} elseif ($choice -eq "2") {
    # List keyboards for the selected language
    Write-Color "`nKeyboards for $($selectedLang.LanguageTag):" "Cyan"
    $kbIndex = 1
    $kbChoices = @{}
    foreach ($kb in $selectedLang.InputMethodTips) {
        $kbParts = $kb -split ":"
        $kbID = $kbParts[-1]

        if ($keyboardMap.ContainsKey($kbID)) {
            $kbName = $keyboardMap[$kbID]
        } else {
            $kbName = "Unknown ($kbID)"
        }

        Write-Color "$kbIndex. $kbName" "Green"
        $kbChoices[$kbIndex] = $kb
        $kbIndex++
    }

    if ($kbChoices.Count -eq 0) {
        Write-Color "No keyboards found for this language!" "Red"
        Exit
    }

    # Ask which keyboard to remove
    $kbSelection = Read-Host "`nEnter the number of the keyboard to remove"

    if ($kbChoices.ContainsKey([int]$kbSelection)) {
        $selectedKeyboard = $kbChoices[[int]$kbSelection]
        $selectedLang.InputMethodTips.Remove($selectedKeyboard)
        Set-WinUserLanguageList -LanguageList $languages -Force
        Write-Color "Keyboard $selectedKeyboard removed from $($selectedLang.LanguageTag)!" "Green"
    } else {
        Write-Color "Invalid selection!" "Red"
    }
} else {
    Write-Color "Invalid choice!" "Red"
}
