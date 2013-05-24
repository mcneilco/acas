
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

**Workflow:**

...starting in your branch...

...you notice master has been updated and want those changes...

...first commit all your changes to host3.labsynch.com...

...then go to the master branch...

    git checkout master
    
... pull down the latest changes...

    git pull
    
...switch back to your branch and rebase your commits on top of this master...

    git checkout host3.labsynch.com
    git rebase master
    
... you can then push your changes back up to the origin branch with your new master base...

    git push origin host3.labsynch.com...


## Sites using Hashify Editor
 
  - [Bitbucket  Markdown Tutorial][1]
  - [Markdown editor (for previewing changes)][2]
 
 
[1]:https://confluence.atlassian.com/display/BITBUCKET/Displaying+README+Text+on+the+Overview#DisplayingREADMETextontheOverview-ExampleMarkdownREADME
[2]: http://hashify.me/