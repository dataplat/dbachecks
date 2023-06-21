# Contributing

## TODO
## Welcome

Before we go any further, thanks for being here. Thanks for using dbachecks and especially thanks 
for being here and looking into how you can help!

## Important resources

- docs
- bugs
- communicate with the team
    - slack
    - github discussions?
- presentations\blogs?

## Running the Tests

If want to know how to run this module's tests you can look at the [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/#running-tests)

## Environment details

We strongly believe that 'every repo should have a devcontainer' and therefore we've built one
for this project that includes 3 SQL Servers and everything you need to develop and build the 
dbachecks module.

It's magic!

### Prerequisites:

In order to use the devcontainer there are a few things you need to get started.

- [Docker](https://www.docker.com/get-started)
- [git](https://git-scm.com/downloads)
- [VSCode](https://code.visualstudio.com/download)
- [`Remote Development` Extension for VSCode](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)

### Setup

Once the prerequisites are in place follow these steps to download the repo and start up the
devcontainer. The first time you build the devcontainer it will need to pull down the images
so that could take a hot second depending on your internet speeds.

1. Download the repo from GitHub
    ```PowerShell
    # change directory to where you'd like the repo to go
    cd C:\GitHub\

    # clone the repo from GitHub
    git clone https://github.com/dataplat/dbachecks

    # move into the folder
    cd .\dbachecks\

    # open VSCode
    code .
    ```

754662. Once code opens, there should be a toast in the bottom right that suggests you 'ReOpen in Container'.
1. The first time you do this it may take a little, and you'll need an internet connection, as it'll download the container images used in our demos

### Develop & Build
TODO: sampler instructions - similar to /workspace/developing/Howto.md

### Rebuild

The only way to properly rebuild to ensure that all volumes etc are removed is to open up a console
or PowerShell window outside of the devcontainer and run the following:

```PowerShell
    cd \path-of-dbachecks-folder\.devcontainer 

    docker-compose -f "docker-compose.yml" -p "bitsdbatools_devcontainer" down
```

## How to submit changes: 
TODO:
Pull Request protocol etc. You might also include what response they'll get back from the team on submission, or any caveats about the speed of response.

## How to report a bug: 
TODO:
Bugs are problems in code, in the functionality of an application or in its UI design; you can submit them through "bug trackers" and most projects invite you to do so, so that they may "debug" with more efficiency and the input of a contributor. Take a look at Atom's example for how to teach people to report bugs to your project.

## Templates:
TODO: 
in this section of your file, you might also want to link to a bug report "template" like this one here which contributors can copy and add context to; this will keep your bugs tidy and relevant.

## Style Guide
TODO:
include extensions and vscode settings we use to keep things neat

## Code of Conduct
TODO: maybe beef this out - stolen from data sat repo for now.

We expect and demand that you follow some basic rules. Nothing dramatic here. There will be a proper code of conduct for the websites added soon, but in this repository

BE EXCELLENT TO EACH OTHER

Do I need to say more? If your behaviour or communication does not fit into this statement, we do not wish for you to help us.
