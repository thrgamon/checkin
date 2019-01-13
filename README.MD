# Slack Checkin Script

A small command line script to help autogenerate slack checkin messages 'cus your lazy like me.

Will give you three prompts in the command line to fill in yesterday's achievements, todays goals and any current blockers. Returning a blank line will skip to the next section.

By default, it will store your goals in a file in the repo directory so you can use the recap command (see below). It will also, by default, copy your checkin to your clipboard. If you want to override either of these, just update the `run_checkin.rb` file overriding those options.

Pro Tip: I would recommend aliasing it in your bash_profile to make it super easy to check in.

`alias checkin='ruby ~/path/to/file/run_checkin.rb'`

## Recap

Woah - recap is basically like time travel, but with 38% fewer paradoxes.

Bind the recap alias and it will return what your goals were for the last week. GNARLY!

`alias recap='ruby ~/path/to/file/run_recap.rb'`

Note. It stores your goals every time you do a checkin through the script so recap won't work until you have done at least one checkin.

The goals are stored in a plain .yml in the scripts directory, so you can check it out if you want to see your history.


## Git Review

A NEW UTILITY - many codes. much review.

Git log outouts a log of all your commits for a given directory. However, at an agency, you are often working among several projects and therefore several directories.

This takes a root directory and then goes into each sub directory (1 level deep) and calls `git log` if that directory is a git repository.

It then outputs the result divided by either day or project. I find this useful to remind myself what I have worked on that week.

Neat eh?
    
It takes three command line arguments.
```
-f --format | Takes either 'day' or 'project' and will output the results by either the day of commit or the project folder. Default is by project.
-e --email | The email of the git user you want to see the commits of. If left blank it will return everyone.
-p --path | The path of the project parent directory - if left blank will run in current directory.
```

Note, It assumes that you keep all your projects in one directory parent directory, nested one level deep like so.

```
projects
    -client_project_1
    -client_project_2
```

An example:

`ruby run_git_review.rb -f day -e thrgamon@gmail.com -p /Users/tomgamon/projects/`

This would output

```
Wednesday
---------
goldeneye

2fd611c Prevent useage of Martini#stir

Thursday
--------
jurassic_park

c475d86 Add long grass
3b7f0ef Introduce Velociraptor class
e326f68 Add Velociraptor#escape
cf58fd4 Add warning on entrance to long grass

Friday
------
temple_of_doom

cf58fd4 Prevent bug where sand mistaken for jewels

```

etc.

####Known Issues
Not very respectful of the This Week/Last Week division so on a monday will list like this. 

Sunday (Yesterday)

Monday (Today)

Tuesday (last Tuesday)

Wednesday (last Sednesday)

etc.
