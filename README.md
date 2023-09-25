# Exploitation Guide for TX-45

## Just another one of the boxes not accept by OFFSEC's UGC program
Just a little context I have tried a few times to submit user generated content to offensive security with any success. I was hoping to depend on it as a form of income alongside bug bounties but it did not seem to yield for me the results I required.
I erenstly believe if their process was smoother then my life would of been slightly more barable as I've been unemployeed for a while. Though I feel quite creative and knowledge regarding the operation of a true system. This utltimately is what I guessed they were trying to open their sudent eye's. Though to not imagine that some of people at the companies are well... cant find the right decription. The premise is I believe I would put more effort into creating more challanging boxes worthwhile boxes in returned for humble lively hood. The reasson why this differs from vulnhub is that the content we create is gurrentied to get attention which makes itrr more enticing to create but we also have to worry less regarding other life issues.

## VM context
The purpose of this virtual machine is to teach the importance of secure authentication, regular patching and appropriate ACL's.
Their various methods that exist for providing authentication. It should be common practice in most instances to secure pages with
sensitive information such as a user/password or authentication token within request header. Correctly securing systems
by ensuring the appropriate permissions is far beyond the scope of this text though I hope to shed light on what can happen when procedure's & processes are not thought out correctly.

Though I believe understanding these things would help an administrator or security professional to become more aware of such issue's in specific environments.

## MITRE Framework Alignment

Not including all sub-techniques

| Syntax | Description |
| --- | ----------- |
| T1592 | Acquire Infrastructure: Server |
| T1590 |  Gather Victim Network Information  |
| T1583.002  | Acquire Infrastructure: DNS Server  |
| T1588.005  | Obtain Capabilities: Exploits  |
| T1204.002  |   User Execution: Malicious File   |
| T1548.001 |  Abuse Elevation Control Mechanism: Setuid and Setgid |
| T1222.002  |   File and Directory Permissions Modification |

## Local testing

In order to run this locally I recommend you install a virtual machine. This machine should ideally be running Rocky linux. 
Once installed, and you are able to ssh you can proceed with running the shell script provided to provision the system.

More information is provided with the build guide.

## Guides

#### Best thing would be to create VMWare snapshot's and then the image after performing the build. You need to have access to the network for the initial build.

[madnar-build](build-guide.md)

[madnar-walkthrough](walkthrough.md)


