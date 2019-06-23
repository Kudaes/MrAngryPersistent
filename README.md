
# Mr. Angry Persistent

Tool to obtain stealthy persistence in Windows systems. Based in the excelent presentation of <a href="https://es.slideshare.net/rootedcon/sheila-ayelen-berta-the-art-of-persistence-mr-windows-i-dont-wanna-go-rooted2019" target="_blank">**Sheila**</a> at <a href="https://www.rootedcon.com/inicio" target="_blank">**RootedCON**</a>.
I do not usually write scripts in Powershell, so feel free to modify and improve the code!

---

## Introduction

This tool allows Red Teams to obtain stealthy persistence on compromised Windows systems modifying the registry to perform either COM hijack or Extension Handler hijack. The best scenario to use this tool is during Red Team operations where classic persistence methods on Windows (programmed tasks, run keys, etc.) suppose a high risk of getting caught by the Blue Team, therefore a more stealthy and unknown method is required. 
This tool is highly inspired on the already mentioned research made by Sheila. Credits to her!

--- 

## Usage 

> To use this tool just open a command prompt and execute `powershell MrPersistent.ps1`. At the moment, two techniques are implemented and the persistence obtained differs from one method to the other.

### COM Object hijack

Usually, when applications look for a COM Object they search first on the Current User (HKCU) registry and, if they dont find it there, they look for it under Local Machine (HKLM) registry. This method generates a new key value (poiting to our malicious payload) that does not exist in HKCU but it does on HKLM. The next time any application tries to load the COM Object it will find it first on HKCU, loading the malicious dll instead of the legit one.

- **User dependent persistence.** 
	- The persistence only will be triggered during sessions of the same user used to modify the registry [Current User registry keys]. Other users' sessions won't be affected.

- **Payload has to be a dll.** 

- **It does not require admin privileges.** 
	- Even though you can use this method without admin privileges, it requires that you know beforehand a valid COM Object identifier (check <a href="https://es.slideshare.net/rootedcon/sheila-ayelen-berta-the-art-of-persistence-mr-windows-i-dont-wanna-go-rooted2019" target="_blank">**Sheila's slides**</a>!). In case that you dont know wich identifier to use, you can always use Procmon to find it out although then you will need to have Administrator privileges.


### Extension Handler hijack

This technique modifies the key values under Classes Root (HKCR) registry used by the system to find the applications required to open the different kind of files (txt, jpg, pdf, etc.). The tool will ask you for a file extension to *poison*, and once the process is concluded each time any user opens a file with the *poisoned* extension the *malicious* payload will be executed. Also, this techniques allows you to use a *proxy* to make this method practically undetectable since the files with the chosen extension will be opened correctly and at the same time the payload will be executed on the background.


- **User independent persistence.** 
	- This persistence will be activated each time ANY user of the system opens a file with the chosen extension (common extesions like txt or jpg are the best).

- **Payload has to be an exe.** 
	- I did not tested yet with other executable files like bat, it might work too.

- **It does require admin privileges** 
	- Since Classes Root registry is modified, admin privileges are required to perform the correct execution of this technique. Some environments might even need System privileges, although it is not a common situation.

- **It might require that the system has Go language installed.**
	- If you choose the stealthiest method, the tool will create and compile a Go script used as a "proxy". If Go is not installed, you will need to compile the proxy in other computer and load it on the compromised system.

---

## Contact

- <a href="https://www.linkedin.com/in/kuroshda/">LinkedIn.</a>
- <a href="https://twitter.com/Kurro2907" target="_blank">Twitter.</a>

---

## License

[![License](http://img.shields.io/:license-mit-blue.svg?style=flat-square)](http://badges.mit-license.org)

- **[MIT license](http://opensource.org/licenses/mit-license.php)**
