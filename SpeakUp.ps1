Add-Type -AssemblyName System.speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$speak.Rate = 10
$speak.Speak('Hello...')
$speak.Rate = -10
$speak.Speak('And Welcome!')
$speak.Rate = 0
$speak.Speak('А также: Приветствую')
$speak.Rate = -10
$speak.Speak('Тебя')
$speak.Rate = 5
$speak.Speak('Мой друг')