# A customized, MSP and IT Professional friendly tool to grab and digest LLDP and CDP packets. No third party dependencies!

### What does this do differently?

This tool started as a modernized port of an old LLDP/CDP digestion utility, but has quickly morphed into being a community-first gateway for easily digesting information from all of the workstations in your fleet. While best executed directly on the endpoint being investigated, this does support being ran from any elevated session that has WinRM and PSRemoting access to the workstations being queried.

The number one priority with this script will always be *ease of integration into other tools* - whether it's a network mapping utility, documentation, or ticketing system. Variables output by this app are planned to be kept the same as further improvements are made.

There are some quality of life improvements, including natively excluding inactive NICs and wireless adapters, then providing a prebuilt Object to manipulate for further API integrations.

### What's next?

I'm glad you asked! I'd like to see this turn into a community project of sorts, with various integrations for ticketing/documentation systems to make the Identify/Discovery parts of our lives easier.

Currently, the main script [Get-SwitchInfo](https://github.com/LoldenCode/LDWinCLI/blob/master/Get-SwitchInfo.ps1) is built to pipe in and out of. This will take and poll any computers passed into it for LLDP or CDP packets, and build them into an easily addressable PSObject.

The next plannned milestone is working this into Luke Whitelock's [HuduAPI](https://github.com/lwhitelock/HuduAPI) as a Proof-of-Concept for the power that the FOSS community offers its peers. The intent is to keep the functions separated so that this can be integrated with any system that is able to have an object POSTed. The data this pulls should allow building more accurate site maps, making it easier to correlate any device moves, locate mislabeled cable drops, and even assist with the initial onboarding of a new client, or jumping into a new client that's poorly documented.

### Installation

+ Download **Get-SwitchInfo.ps1**.

+ Execute Get-SwitchInfo through an elevated PowerShell session. Recommended usage is tying to a variable as such:

```ps
>$WorkstationInfo = .\Get-SwitchInfo.ps1
>$WorkstationInfo | Select-Object Computer,@{Name="IPofSwitch"; Expression = {$_.IPAddress}},Device
```

### Testing

[Get-NetworkMap](https://github.com/LoldenCode/LDWinCLI/blob/master/Get-NetworkMap.ps1) is the first integration that's made it out of the oven so far. This simple example will pass either a list of workstations, or query Active Directory for online workstations - then pass the list to Draw.IO to build a basic diagram.
    - This includes some of the code that [Kelvin Tegelaar](https://github.com/KelvinTegelaar/) had in an older project, [PSdrawIO](https://github.com/KelvinTegelaar/PSdrawIO/).

### Contribution

Feel free to submit PR's for any any future integrations - this is a great way to help everyone get caught up with the new compliance regulations!

## Credits

This tool is currently a combination of two fantastic tools, with the intent on making the Discovery and Identification process seamless to keep accurate in the modern "Hybrid Office" movement.

### PSdrawIO

[PSdrawIO](https://github.com/KelvinTegelaar/PSdrawIO/) is a tool to create a rudimentary "Hub and Spoke" map of the network, based off of ports or services that respond when running a network map against them. That functionality is currently outside the scope of this project, but the CSV styling has been copied and lightly modified to assist in the legibility of generated [Draw.IO](https://app.diagrams.net) documents.

### PSDiscoveryProtocol

[PSDiscoveryProtocol](https://github.com/lahell/PSDiscoveryProtocol/tree/master) has been heavily borrowed from, due to the utilization of native Microsoft utilities for performing the capturing and decrypting of LLDP and CDP packets. Most Functions have been joined in, but have yet to be fully integrated with PowerShell flags for ease of exporting Objects.

### License for PSDiscoveryProtocol

MIT License

Copyright (c) 2019 lahell

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Link Discovery Client for Windows

Chris Hall 2010-2014 - [chall32.blogspot.com]

<p align="center"> 
<img src="https://github.com/chall32/LDWin/blob/master/LDWin.png?raw=true" alt="LDWin is a Link Discovery Protocol Client for Windows"/>
</p>

LDWin was one of the first FOSS tools we'd fully integrated into our stack at my MSP, due to the ease of use for Layer 2 issues. Now that Command Line/API is back to the forefront, I decided to re-create the tool from the ground up - ensuring that clarity, stability, and ease of use were at the forefront. This still is, and will be for the forseeable future, be the way this project sticks.

LDWin is based on [WinCDP] also by Chris Hall

### Why?

Lets face it.  We have all been there: "where does this network cable / uplink / port go?"

Until now, it has been a matter of looking up cable numbers in databases, fiddling about in the back of server and network racks or worst case - manually tracing cables down the backs of server racks, under the computer room or office floor, in overhead cable trays etc etc...

There must be a better way to tell where a network cable goes to without having to go to all that trouble every time.  VMware ESXi has Link discovery built in. Why not also have link discovery in Windows?
