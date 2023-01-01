# Developing with Sampler set up

Super quick introduction. I have altered the project to use Sampler by Gael to scaffold and later to improve the CI/CD pipeline.

I have also updated the devcontainer so that we have 3 containers 2 based on dbatools/sqlinstance and dbatools/sqlinstance2 but also a SQL2022 container with the sqlinstance objects copied into it. The default container also has GitVersion and Sampler installed as well as few other bits to make thigns easier and to save having to do the build everytime (as installing gitversion was a PITA and lengthy)

The containers are all now hosted in the dbachecks docker hub account.

What does this mean?

It means that as well as using a dev container to develop in, thus ensuring that everyone is using the same environment, we will also be using the Sampler build and test process to ensure that we are __always__ using a clean build of the code we are writing and testing. :-)

So to develop you need to understand the following:

The code in the source directory is the code that will be built and deployed to the PowerShell Gallery. This is the directory that you will be changing the code in.

The code in the output directory is the code that is built by Sampler. It is in the gitignore file so that it is not committed to the repo. This is the code that you can test with the 3 SQL instances. The advantage is that the Sampler build process will create a clean environment and add the built module into the PSModulePath. 

# Workflow

## Once in a session
- Run `.\build.ps1 -ResolveDependency -Tasks noop` to download all required dependencies and set up the environment. 

## Coding

- Code in the source directory
- Save the files
- Run the build.ps1 script 
    - with Tasks build `./build.ps1 -Tasks build`
    - This will build the code and copy it to the output directory.
    <img width="741" alt="image" src="https://user-images.githubusercontent.com/6729780/204135400-c324ef33-c7c2-4031-a408-d70d174fecd5.png">

<img width="588" alt="image" src="https://user-images.githubusercontent.com/6729780/204135445-9f071e4e-ef36-4e15-8357-9da7d541285f.png">

<img width="259" alt="image" src="https://user-images.githubusercontent.com/6729780/204135493-2f51c768-51b1-440a-9e2b-1559dd854f22.png">

Once you have finished doing some coding and want to test
    - With Tasks build test `./build.ps1 -Tasks build,test`
    - This will build the code and run the Pester Tests.
    <img width="854" alt="image" src="https://user-images.githubusercontent.com/6729780/204135632-e3918657-60b0-4f8b-9c29-65beb4c5a391.png">
    - if you have failed tests, you can 
        - Run Pester manually `Invoke-Pester tests`
        <img width="922" alt="image" src="https://user-images.githubusercontent.com/6729780/204135673-78751e7b-cb5c-46c8-961d-07e5f25652c0.png">
        - You can check the test results in the browser by creating a html page
        `.\tests\extent.exe -i .\output\testResults\NUnitXml_dbachecks_v2.0.18.Linux.PSv.7.3.0.xml -o .\output\testResults\reports -r v3html` and then __outside of the container__ `ii .\output\testResults\reports\index.html # outside of container`
        <img width="1172" alt="image" src="https://user-images.githubusercontent.com/6729780/204135720-775f4932-05a1-464a-9323-e0d5fe8a2210.png">
    - Fix the broken tests or add more code and rinse and repeat.