# ACAS
 
 
## Creating a customer branch
 
 
Each customer should have a branch and this is how you create the branch
 
    git clone https://bbolt@bitbucket.org/mcneilco/acas.git
    git checkout -b host3.labsynch.com
    git push origin host3.labsynch.com
 

## Pulling down changes from Master to Branch

This is for when you want to merge all the changes that have been made in the master branch, down to your customer branch.

The overall idea is that you are taking all your current branch commits and placing them on top of a new master checkout.  This is what git calls "rebasing"

There is a way to undo this so don't worry so much (see undoing rebase below)!

Workflow:

...starting in your branch...

    git checkout host3.labsynch.com
    
...make some changes...
...notice master has been updated...
...commit changes to host3.labsynch.com...

    git checkout master
    git pull
    
...bring those changes back into host3.labsynch.com...

    git checkout host3.labsynch.com
    git rebase master
    
... commit your current changes to your branch...

    git push origin host3.labsynch.com...


## Sites using Hashify Editor
 
  - [Bitbucket  Markdown Tutorial][1]
  - [Markdown editor (for previewing changes)][2]
 
 
[1]:https://confluence.atlassian.com/display/BITBUCKET/Displaying+README+Text+on+the+Overview#DisplayingREADMETextontheOverview-ExampleMarkdownREADME
[2]: http://hashify.me/
