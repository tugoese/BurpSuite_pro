# Set Invoke-WebRequest Progress to Silent, Because it slows down Downloading by 50x
Write-Output "Setting Invoke-WebRequest Progress to Silent, Because it slows down Downloading by 50x`n"
$ProgressPreference = 'SilentlyContinue'

# Check JDK-21 Availability or Download JDK-21
$jdk21 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" | Where-Object Caption -clike "Java(TM) SE Development Kit 21*"
if (!($jdk21)) {
    Write-Output "`t`tDownnloading Java JDK-21 ...."
    Invoke-WebRequest "https://download.oracle.com/java/21/archive/jdk-21_windows-x64_bin.exe" -O jdk-21.exe  
    Write-Output "`n`t`tJDK-21 Downloaded, lets start the Installation process"
    Invoke-WebRequest jdk-21.exe
    Remove-Item jdk-21.exe
}
else {
    Write-Output "Required JDK-21 is Installed"
    $jdk21
}

# Check JRE-8 Availability or Download JRE-8
$jre8 = Get-WmiObject -Class Win32_Product -filter "Vendor='Oracle Corporation'" | Where-Object Caption -clike "Java 8 Update *"
if (!($jre8)) {
    Write-Output "`n`t`tDownloading Java JRE ...."
    Invoke-WebRequest "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=247947_0ae14417abb444ebb02b9815e2103550" -O jre-8.exe
    Write-Output "`n`t`tJRE-8 Downloaded, lets start the Installation process"
    Invoke-WebRequest jre-8.exe
    Remove-Item jre-8.exe
}
else {
    Write-Output "`n`nRequired JRE-8 is Installed`n"
    $jre8
}

# Download Burpsuite Professional
Write-Host "Downloading Burp Suite Professional Latest..."
$version = "2026.10.1"
Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/download?product=desktop&version=2026.10.1&type=Jar" `
    -OutFile "burpsuite_pro_v$version.jar"

# Creating Burp.bat file with command for execution
if (Test-Path burp.bat) { Remove-Item burp.bat }
$path = "java --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:`"$pwd\loader.jar`" -noverify -jar `"$pwd\burpsuite_pro_v$version.jar`""
$path | add-content -path Burp.bat
Write-Output "`nBurp.bat file is created"

# Creating Burp-Suite-Pro.vbs File for background execution
if (Test-Path Burp-Suite-Pro.vbs) {
    Remove-Item Burp-Suite-Pro.vbs
}
Write-Output "Set WshShell = CreateObject(`"WScript.Shell`")" > Burp-Suite-Pro.vbs
add-content Burp-Suite-Pro.vbs "WshShell.Run chr(34) & `"$pwd\Burp.bat`" & Chr(34), 0"
add-content Burp-Suite-Pro.vbs "Set WshShell = Nothing"
Write-Output "`nBurp-Suite-Pro.vbs file is created."

# Download loader if it not exists
if (!(Test-Path loader.jar)) {
    Write-Output "`nDownloading Loader ...."
    Invoke-WebRequest -Uri "https://github.com/xiv3r/Burpsuite-Professional/raw/refs/heads/main/loader.jar" -OutFile loader.jar
    Write-Output "`nLoader is Downloaded"
}
else {
    Write-Output "`nLoader is already Downloaded"
}

# Lets Activate Burp Suite Professional with keygenerator and Keyloader
Write-Output "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 
Write-Output "`n`nStarting Keygenerator ...."
start-process java.exe -argumentlist "-jar loader.jar"
Write-Output "`n`nStarting Burp Suite Professional"
java --add-opens=java.desktop/javax.swing=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:"loader.jar" -noverify -jar "burpsuite_pro_v$version.jar"

# Set-ExecutionPolicy -ExecutionPolicy bypass -Scope process