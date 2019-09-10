# Armed and Operational
### Making your machine a demo/dev/play DSS powerhouse

There are many advantages to making your machine into a fully-operational standalone DSS demo machine that can show the entire lifecycle of working in our ecosystem. 

 * Demoing when the internet sucks
 * Always having the most up-to-date version of DSS
 * being able to match client version of DSS
 * Ability to look at and explain the data directory
 * Easier to develop plugins and macros
 * Gain a better understanding of the inner workings of DSS
 * Completely control what a client sees in DSS (no one else mucking about in the environment)

 What does it mean to have a machine that can support the entire lifecycle? Let's define it together. It should have, at minimum:

 * Design node
 * Automation node
 * 2 API nodes

In addition it could have:

* At least one database connection
* dkumonitor set up

---


## Plan of attack

1. Set up the tools we need
2. Install design node
3. Install automation node
4. Install API node
5. Configure API deployer
6. Build a project on the design node
7. Install the "push to automation" macro
8. Use the macro to push our bundle to automation
9. From the design node, manually push a API service to the API deployer
9. Create a scenario that checks for accuracy of a model and pushes to the API deployer
10. Update the project on automation and run it to deploy to the API deployer
11. Use Insomnia, postman, the command line, or the apache bench macro to test our api endpoint from outside DSS
12. Modify the upgrade script in this git repo for your machine.
13. Add the auto-startup automator app.

--- Bonus stuff to be done if you finish any of these early (can be done asynchronously):

- install postgresql or mysql
- create a sql connection to your database
- install go
- install dkumonitor

---

## Tooling

Prior to building out our actual DSS setup, we are going to need some tools! What are the bare minimum tools to run DSS locally?

#### You should not need to download these (Installing dataiku will do it for you if you don't have them.)
- linux or osx
- Python 2.7
- nginx
- java
- git

#### You will need to download

- R

Beyond that, in order to interact with Dataiku like sane people, we're going to want some other things. These aren't required for today but will make your life easier and I recommend them.:

- A way of installing software on a Mac that isn't clicking buttons (Homebrew: [https://brew.sh]())
  - This is something that's actually harder on a mac than on Linux. Most flavors of linux have their own package managers.
- A decent terminal (I use terminal.app, which comes built-in, many other people swear by iTerm2)
- A text editor (I use vim, popular alternatives are emacs, sublimetext, Atom, and VS Code.)
- A way of storing API calls (I use Insomnia, other people like Postman)

There's some tools that make life better on a mac, especially when demoing and working with clients:

- Spectacle (for moving windows around)
- Alfred (for finding and opening shit)
- Skitch (for superfast markup)
- MacDown (for writing Markdown)

And a couple mac settings:

- set caps lock to ctrl
- set key repeat speed to max
- add an automator script to automatically spin up your local DSS instances when you turn on your computer. [https://dataiku.slack.com/archives/CDXD799NG/p1561871234015600](https://dataiku.slack.com/archives/CDXD799NG/p1561871234015600)

#### Basic skills

Dataiku runs on Linux (and Mac, which is close enough.) The way we interact with linux is the shell. This means that at bare minimum, it's extremely helpful to know some basic shell commands.
https://docs.google.com/presentation/d/1r4z3dNbZZgNMhEdh1Ao6ua5NgoaJnFdRZFahmEeRVsw/edit?usp=drive_web&ouid=114494509991412750512
https://dataiku.slack.com/archives/CDXD799NG/p1561871234015600

Dataiku uses git heavily underneat the covers. You should have git installed and a github account. If you do not have a github account sign up now. 
We'll wait...

Okay, now navigate to 
github.com/JedIV/dataiku-se-materials
git clone [https://github.com/JedIV/dataiku-se-materials.git]()

-- ADVANCED --

Or generate a keypair. Note that this is something you'll need if you are going to ssh into a client box without a password, or if you are going to ssh into a blank aws box.

[https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent]()

If you create a keypair, you can associate it with your github account (google it) and then use:

git clone [git@github.com:JedIV/dataiku-se-materials.git]()

-- END ADVANCED --

## Install Design Node

Create a directory underneath you users main directory. Your license should be in your email from the sender: dkulicense@test1.dataiku.com. Copy your license into a file called license.json and save it inside this directory.

```bash
## make sure you're not root
whoami
cd
mkdir dataiku
cd dataiku
wget https://downloads.dataiku.com/public/dss/5.1.5/dataiku-dss-5.1.5-osx.tar.gz
tar -xzf dataiku-dss-5.1.5-osx.tar.gz
mkdir dss-design
dataiku-dss-5.1.5-osx/installer.sh -d dss-design -p 20000 -l license.json
```

Navigate into your dss design directory and start it up:

```bash
dss-design/bin/dss start
```

Now go to [http://localhost:20000](https://downloads.dataiku.com/public/dss/5.1.5/dataiku-dss-5.1.5-osx.tar.gz) and add your license. Your license should be in your email from the sender: dkulicense@test1.dataiku.com

## Install Automation Node


```bash
mkdir dss-automation
dataiku-dss-5.1.5-osx/installer.sh -d dss-automation -p 30000 -l license.json -t automation 
```

Navigate into your dss automation directory and start it up:

```bash
dss-automation/bin/dss start
```

## Install API Node


```bash
mkdir dss-api
dataiku-dss-5.1.5-osx/installer.sh -d dss-api -p 40000 -l license.json -t api 
```

Navigate into your dss api directory and start it up:

```bash
dss-api/bin/dss start
```

## Configure API deployer

We are going to use the API deployer on the automation node as our primary deployer.

Connect your Design and Automation instances
Next, you are going to configure your Design node so that it can publish their API services to the API Deployer set up on the Automation node

####Generate an admin API key on the API Deployer

On the Automation node's API Deployer, go to Administration > Security > Global API keys and generate a new API key. This key must have global admin privileges. Take note of the secret.

####Setup the key on the Design node

On the Design node:


Go to Administration > Settings > API Designer & Deployer

Set the API Deployer mode to “Remote” to indicate that we’ll connect to another node

Enter the base URL of the API Deployer node that you installed

Enter the secret of the API key

Repeat for each Design or Automation node that you wish to connect to the API Deployer.

#### Create an infrastructure on the deployer

[https://doc.dataiku.com/dss/latest/apinode/installing-apideployer.html#create-your-first-infrastructure
](https://doc.dataiku.com/dss/latest/apinode/installing-apideployer.html#create-your-first-infrastructure)

## Build a project on the design node

If you correctly cloned the git repo, you should have a folder inside of it with 5 csvs. They should be familiar to you. Build the CLV project.

## Download the Push to Automation Macro

If you've correctly set up git, you can pull the macro directly from Dataiku's dku-contrib repo. 

## Push your project to automation

You'll need to create an admin key on the automation node, then put it into the macro inside your project on the design node.

## From the design node, manually push a service that includes a model to the API deployer

Construct an Api service from your model. You can construct multiple endpoints on this service if you choose. When building your model, I recommend using as few features as possible. This makes for easier an easier to modify feature set. if you want to build another endpoint, I suggest doing a python function endpoint that performs some sort of "hello world" action.

## Create a scenario that checks for accuracy of a model and pushes an updated service to the API deployer

Exercise left to the reader.

## Update the project on automation and run its scenario to deploy  a new version of your service to the API deployer

Again, use the push to Automation macro to send a new version of your project to the automation node. This new version should have the API service and the scenario that updates that service. 

## Use Insomnia, postman, the command line, or the apache bench macro to test our api endpoint from outside DSS

You should be able to use a modified version of this curl script to query your API endpoint:

```bash
curl --request POST \
  --url http://localhost:30000/public/api/v1/benchmarking/sql_query/query \
  --header 'content-type: application/json' \
  --data '{
   "customer_id": "ac91f77186"
}'
```

## Modify the upgrade script in this git repo for your machine.

Inside the repo you pulled you should find a script called `upgrade_dss.sh`

You should move it to the dataiku directory, (how do we do this using the command line?)

Open it, and modify the variables at the top to match where you saved your instances:

```

URL="https://cdn.downloads.dataiku.com/public/studio"

DESIGN="dss_beta"
AUTOMATION="dss_beta_automation"
API="dss_beta_api"
ROOT_DIRECTORY_PATH="~/dataiku"

```

You can also modify the download url location. This script is run with the following command from the dataiku directory. For example to upgrade all of your instances to 5.1.5:

```
./upgrade_dss.sh -v 5.1.5
```

