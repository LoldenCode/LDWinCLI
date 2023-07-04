LDWinCLI

## A semi-modernized port of LDWin in PowerShell
<img src="https://github.com/LoldenCode/LDWinCLI/blob/master/PowershellOutput.png" />
### What does this do differently?
Using this ported Powershell script, this can be ran on an endpoint via RMM or other application execution tool. While in WIP phase, it is building out one or multiple PSCustomObjects, then writing the contents to a file in the same directory, named `LLDP_raw.txt`.

There are some quality of life improvements, including natively excluding inactive NICs, and having the prebuilt Object to manipulate for further API integrations.

### What's next?
I'm planning on working this into Luke Whitelock's [HuduAPI](https://github.com/lwhitelock/HuduAPI) as a Proof of Concept, but intend to keep the pieces separated so this can be integrated with any sort of documentation system that you are using. The data this pulls should allow building an accurate map correlating any device moves, locating mislabeled cable drops, and even assist with the initial onboarding of a new client, or jumping into a new client that's poorly documented.

### Installation
+ Download **Get-SwitchInfo.ps1** and **tcpdump.exe** to the same directory
+ Execute Get-SwitchInfo through an elevated PowerShell session. Recommended usage is tying to a variable as such:
```ps
>$WorkstationInfo = .\Get-SwitchInfo.ps1
>$WorkstationInfo | Select-Object *
```

The goal is to make this as accessible as possible, for ingress and verification of accuracy of network documents. Feel free to submit PR's for future integrations!

**Currently, only LLDP is integrated. I am planning on porting the CDP features over in the coming days.**

## Original README below:
=====

## Link Discovery Client for Windows
Chris Hall 2010-2014 - [chall32.blogspot.com]

<p align="center"> 
<img src="https://github.com/chall32/LDWin/blob/master/LDWin.png?raw=true" alt="LDWin is a Link Discovery Protocol Client for Windows"/>
</p>

### What is Link Discovery?
Link discovery is the process of ascertaining information from directly connected networking devices, such as network switches.  This can be helpful when diagnosing suspected network connectivity issues.

LDWin supports the following methods of link discovery:

+   [CDP] - Cisco Discovery Protocol
+   [LLDP] - Link Layer Discovery Protocol

LDWin is based on [WinCDP] also by Chris Hall

### Why?
Lets face it.  We have all been there: "where does this network cable / uplink / port go?"

Until now, it has been a matter of looking up cable numbers in databases, fiddling about in the back of server and network racks or worst case - manually tracing cables down the backs of server racks, under the computer room or office floor, in overhead cable trays etc etc...

There must be a better way to tell where a network cable goes to without having to go to all that trouble every time.  VMware ESXi has Link discovery built in. Why not also have link discovery in Windows?

### How to Use
**You must have administrative rights to run this program**

1.   Start the program
2.   From the "Network Connection:" drop down, select the network adaptor over which you wish to obtain network link information
3.   Click "Get Link Data"
4.   LDWin will then listen on the selected network adaptor for link protocol announcements.  It may take up to 60 seconds to receive an announcement
5.   Once an announcement has been received, the received information will be displayed in the results section
6.   Use the "Save Link Data" button to save the received information into a text file

NOTE: A valid TCP/IP address is not required to receive valid link information.

### What's New?
***See the [changelog] for what's new in the most recent release.***


### [Click here to download latest version](https://github.com/chall32/LDWin/blob/master/LDWin.exe?raw=true)

If LDWin helped you, how about buying me a beer? Use the donate button below. THANK YOU!

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=KT462HRW7XQ3J)


[changelog]: https://github.com/chall32/LDWin/blob/master/ChangeLog.txt
[chall32.blogspot.com]: http://chall32.blogspot.com
[CDP]:http://en.wikipedia.org/wiki/Cisco_Discovery_Protocol
[LLDP]:http://en.wikipedia.org/wiki/Link_Layer_Discovery_Protocol
[WinCDP]:http://github.com/chall32/WinCDP