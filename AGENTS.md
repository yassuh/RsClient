


When using obscure python libraries use the repl or searching tools to inspect the library code and understand how it works. This will help you to use the library effectively and avoid common pitfalls. Additionally, you can also look for docstrings.

Write code in a modular composable object oriented way. This will make it easier to reuse code and maintain it in the long run.

When editing code you wrote or when writing new code it is worth using the python repl extensively to test out what you are planning to do you can import the code you are working on into the repl and test it out there before you put it into your main codebase. This will help you to catch any errors or bugs early on and save you time in the long run.

Please make sure you keep ARCHITECTURE.md up to date with any changes you make to the codebase. This document is designed for agents to read and write to in order to document specifically what each part of the code does what its intentions are for what the outputs are where those outputs are used and how they are used what the inputs are and where those inputs come from and how they are used. This will help to ensure that the codebase is well documented and that you do not make changes that break other parts of the codebase without realizing it. It will also help other agents to understand the codebase and how to use it effectively. 

Code should be Parallel where possible and worthwhile. We will be using python3.14t this is free threaded version of python and it allows for true parallelism.

you as an agent can use the psql client at any time to query the database and you should use it if you have any questions about the data in the database 
`PGPASSWORD=$(grep POSTGRES_PASSWORD .env | cut -d= -f2) psql -h $(grep POSTGRES_HOST .env | cut -d= -f2) -U $(grep POSTGRES_USER .env | cut -d= -f2) -d $(grep POSTGRES_DB .env | cut -d= -f2)`