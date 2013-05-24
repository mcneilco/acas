# ACAS
 
 
## Creating a customer branch
 
 
Each customer should have a branch and this is how you create the branch
 
    git clone https://bbolt@bitbucket.org/mcneilco/acas.git
    git checkout -b host3.labsynch.com
    git push origin host3.labsynch.com
 

## Pulling down changes from Master to Branch

This is for when you want to merge all the changes that have been made in the master branch, down to your customer branch

    git checkout -b host3.labsynch.com
    
...make some changes...
...notice master has been updated...
...commit changes to develop...

    git checkout master
    git pull
    
...bring those changes back into develop...

    git checkout host3.labsynch.com
    git rebase master
    
...make some more changes...
...commit them to develop...
...merge them into master...

    git checkout master
    git pull
    git merge develop


## Sites using Hashify Editor
 
  - [Bitbucket  Markdown Tutorial][1]
  - [Markdown editor (for previewing changes)][2]
 
 
[1]:https://confluence.atlassian.com/display/BITBUCKET/Displaying+README+Text+on+the+Overview#DisplayingREADMETextontheOverview-ExampleMarkdownREADME
[2]: http://hashify.me/
