{ ... }: {
  programs.git = {
    enable = true;
    delta = {
      enable = true;
      options = {
        syntax-theme = "gruvbox-dark";
        line-numbers = true;
      };
    };
    ignores = [ ".DS_Store" ".direnv" ];
    includes = [
      {
        path = "~/.config/git/public.gitconfig";
        condition = "gitdir:~/Code/";
      }
      {
        path = "~/.config/git/work.gitconfig";
        condition = "gitdir:~/Work/";
      }
      { path = "~/.config/git/gitalias"; }
    ];
    aliases = { conflicts = "diff --name-only --diff-filter=U"; };
    extraConfig = { core = { editor = "nvim"; }; };
  };

  home.file.".config/git/work.gitconfig".text = ''
    [user]
        email = lucas.rondenet@gmail.com
        name = rucas

    [core]
        fsmonitor = true
        untrackedcache = true
        manyFiles = true
  '';
  home.file.".config/git/public.gitconfig".text = ''
    [user]
        email = lucas.rondenet@gmail.com
        name = rucas
  '';

  home.file.".config/git/gitalias".text = ''
    [alias]
      a = add
      b = branch
      c = commit
      d = diff
      f = fetch
      g = grep
      l = log
      m = merge
      o = checkout
      p = pull
      s = status
      w = whatchanged

      ## add aliases
      aa = add --all

      # add by patch - looks at each change, and asks if we want to put it in the repo.
      ap = add --patch

      # add just the files that are updated.
      au = add --update

      ### branch aliases ###

      # branch and only list branches whose tips are reachable from the specified commit (HEAD if not specified).
      bm = branch --merged

      # branch and only list branches whose tips are not reachable from the specified commit (HEAD if not specified).
      bnm = branch --no-merged

      # branch with edit description
      bed = branch --edit-description

      # branch verbose: When in list mode, show the hash, the commit subject line, etc.
      # This is identical to doing `git b -v`.
      bv = branch --verbose

      # branch verbose verbose: When in list mode, show the hash the commit subject line, the upstream branch, etc.
      # This is identical to doing `git b -vv`.
      bvv = branch --verbose --verbose

      ### commit aliases ###

      # commit - amend the tip of the current branch rather than creating a new commit.
      ca = commit --amend

      # commit - amend the tip of the current branch, and edit the message.
      cam = commit --amend --message

      # commit - amend the tip of the current branch, and do not edit the message.
      cane = commit --amend --no-edit

      # commit interactive
      ci = commit --interactive

      # commit with a message
      cm = commit --message

      ### checkout aliases ###

      # checkout - update the working tree to match a branch or paths. [same as "o" for "out"]
      co = checkout
      cong = checkout --no-guess

      ### cherry-pick aliases ###

      # cherry-pick - apply the changes introduced by some existing commits; useful for moving small chunks of code between branches.
      cp = cherry-pick

      # cherry-pick - abort the picking process
      cpa = cherry-pick --abort

      # cherry-pick - continue the picking process
      cpc = cherry-pick --continue

      # cherry-pick --no-commit a.k.a. without making a commit
      cpn = cherry-pick -n

      # cherry-pick --no-commit a.k.a. without making a commit, and when when recording the commit, append a line that says "(cherry picked from commit ...)"
      cpnx = cherry-pick -n -x

      ### diff aliases ###

      # Show changes not yet staged
      dc = diff --cached

      # Show changes about to be commited
      ds = diff --staged

      # Show changes but by word, not line
      dw = diff --word-diff

      # Show changes with our preferred options; a.k.a. `diff-deep`
      dd = diff-deep

      ### fetch aliases ###

      # Fetch all remotes
      fa = fetch --all

      # Fetch all remotes and use verbose output
      fav = fetch --all --verbose

      ### grep aliases ###

      # grep i.e. search for text
      g = grep

      # grep with -n (--line-number) means show line number
      gn = grep -n

      # Search with our preferred options; a.k.a. `grep-group`
      gg = grep-group

      ### log aliases ###

      # log with a text-based graphical representation of the commit history.
      lg = log --graph

      # log with one line per item.
      lo = log --oneline

      # log with one line per item, in reverse order i.e. recent items first.
      lor = log --oneline --reverse

      # log with patch generation.
      lp = log --patch

      # log with first parent, useful for team branch that only accepts pull requests
      lfp = log --first-parent

      # log with items appearing in topological order, i.e. descendant commits are shown before their parents.
      lto = log --topo-order

      # log list - Show log list with our preferred options, a.k.a. `log-list`
      ll = log-list

      # log list long - Show log list with our preferred options with long information, a.k.a. `log-list-long`
      lll = log-list-long

      ### ls-files aliases ###

      # ls-files - show information about files in the index and the working tree; like Unix "ls" command.
      ls = ls-files

      # lsd - List files with debug information
      lsd = ls-files --debug

      # lsfn - List files with full name.
      lsfn = ls-files --full-name

      # lsio -  list files that git has ignored.
      #
      # git ls-files:
      #
      #     -i, --ignored
      #         Show only ignored files in the output …
      #
      #     -o, --others
      #         Show other (i.e. untracked) files in the output …
      #
      #     --exclude-standard
      #         Add the standard Git exclusions …
      #
      lsio = ls-files --ignored --others --exclude-standard

      ### merge aliases ###

      # merge abort - cancel the merging process
      ma = merge --abort

      # merge - continue the merging process
      mc = merge --continue

      # merge but without autocommit, and with a commit even if the merge resolved as a fast-forward.
      mncnf = merge --no-commit --no-ff

      ### pull aliases ###

      # pf - Pull if a merge can be resolved as a fast-forward, otherwise fail.
      pf = pull --ff-only

      # pp - Pull with rebase in order to provide a cleaner, linear, bisectable history
      #
      # To automatically do "pull --rebase" everywhere:
      #
      #     git config --global pull.rebase true
      #
      # To automatically do "pull --rebase" for any branch based on
      # the branch "main":
      #
      #    git config branch.main.rebase true
      #
      # To automatically do "pull --rebase" for any newly-created branches:
      #
      #     git config --global branch.autosetuprebase always
      #
      # To integrate changes between branches, you can merge or rebase.
      #
      # When we use "git pull", git does a fetch then a merge.
      #
      # If we've made changes locally and someone else has pushed changes
      # to our git host then git will automatically merge these together
      # and create a merge commit that looks like this in the history:
      #
      #    12345678 - Merge branch 'foo' of bar into main
      #
      # When we use "git pull --rebase", git does a fetch then a rebase.
      # A rebase resets the HEAD of your local branch to be the same as
      # the remote HEAD, then replays your local commits back into repo.
      # This means you don't get any noisy merge messages in your history.
      # This gives us a linear history, and also helps with git bisect.
      #
      pr = pull --rebase

      # prp - Pull with rebase preserve of merge commits
      #
      # See <https://stackoverflow.com/questions/21364636/git-pull-rebase-preserve-merges>
      #
      # You should only rebase if you know (in a sort of general sense)
      # what you are doing, and if you do know what you are doing, then you
      # would probably prefer a merge-preserving rebase as a general rule.
      #
      # Although by the time you've decided that rebasing is a good idea,
      # you will probably find that a history that has its own embedded
      # branch-and-merge-points is not necessarily the correct "final
      # rewritten history".
      #
      # That is, if it's appropriate to do a rebase at all, it's at least fairly
      # likely that the history to be rebased is itself linear, so that the
      # preserve-vs-flatten question is moot anyway.
      #
      # See <https://stackoverflow.com/questions/38269092/is-it-possible-to-put-preserve-merges-in-the-gitconfig>
      #
      # While preserving merges is probably generally superior, in at least a
      # few ways, to discarding them when rebasing, the fact is that rebase
      # cannot preserve them. The only thing it can do, once some commits
      # have been copied to new commits, is re-perform them. This can have new
      # and/or different merge conflicts, vs the last time the merge was done.
      # You should also pay close attention to the restrictions on merge
      # preservation in the git rebase documentation.
      #
      # Without getting into a lot of detail, it always seems to me that most
      # commit graph subsets that "should be" rebased, rarely have any
      # internal merges. If such a graph subset has a single final merge, you
      # can simply strip away that merge (with git reset) before rebasing,
      # and re-do that single merge manually at the end. (In fact, git rebase
      # normally drops merge commits entirely, so you don't have to run the git
      # reset itself in some cases. The one where you do have to run it is when
      # the merge is into the branch onto which you intend to rebase. This is
      # where git pull actually does the right thing when it uses
      # `git rebase -p`, except that it fails to check for, and warn about,
      # internal merges, which are sort of warning signs that rebasing might
      # not be a good idea.
      #
      prp = pull --rebase=preserve

      ### rebase aliases ###

      # rebase - forward-port local commits to the updated upstream head.
      rb = rebase

      # rebase abort - cancel the rebasing process
      rba = rebase --abort

      # rebase - continue the rebasing process after resolving a conflict manually and updating the index with the resolution.
      rbc = rebase --continue

      # rebase - restart the rebasing process by skipping the current patch.
      rbs = rebase --skip

      # rebase interactive - do the rebase with prompts.
      rbi = rebase --interactive

      # rbiu - rebase interactive on our unpushed commits.
      #
      # Before we push our local changes, we may want to do some cleanup,
      # to improve our commit messages or squash related commits together.
      #
      # Let's say I've pushed two commits that are related to a new feature and
      # I have another where I made a spelling mistake in the commit message.
      #
      # When I run "git rbiu" I get dropped into my editor with this:
      #
      #     pick 7f06d36 foo
      #     pick ad544d0 goo
      #     pick de3083a hoo
      #
      # Let's say I want to squash the "foo" and "goo" commits together,
      # and also change "hoo" to say "whatever". To do these, I change "pick"
      # to say "s" for squash; this tells git to squash the two together;
      # I also edit "hoo" to rename it to "whatever". I make the file look like:
      #
      #     pick 7f06d36 foo
      #     s ad544d0 goo
      #     r de3083a whatever
      #
      # This gives me two new commit messages to edit, which I update.
      # Now when I push the remote repo host receives two commits
      #
      #     3400455 - foo
      #     5dae0a0 - whatever
      #
      rbiu = rebase --interactive @{upstream}

      # See <https://blog.filippo.io/git-fixup-amending-an-older-commit/>
      # This is a slightly modified version
      fixup = "!f() { TARGET=$(git rev-parse \"$1\"); git commit --fixup=$TARGET && GIT_EDITOR=true git rebase --interactive --autosquash $TARGET~; }; f"

      ### reflog aliases ###

      # reflog - reference log that manages when tips of branches are updated.
      rl = reflog

      ### remote aliases ###

      # remote - manage set of tracked repositories [same as "r"].
      rr = remote

      # remote show - gives some information about the remote <name>.
      rrs = remote show

      # remote update - fetch updates for a named set of remotes in the repository as defined by remotes.
      rru = remote update

      # remote prune - deletes all stale remote-tracking branches under <name>.
      rrp = remote prune

      ### revert aliases ###

      # revert - undo the changes from some existing commits
      rv = revert

      # revert without autocommit; useful when you're reverting more than one commits' effect to your index in a row.
      rvnc = revert --no-commit

      ### show-branch aliases ###

      # show-branch - print a list of branches and their commits.
      sb = show-branch

      ### submodule aliases ###

      # submodule - enables foreign repositories to be embedded within a dedicated subdirectory of the source tree.
      sm = submodule

      # submodule init
      smi = submodule init

      # submodule add
      sma = submodule add

      # submodule sync
      sms = submodule sync

      # submodule update
      smu = submodule update

      # submodule update with initialize
      smui = submodule update --init

      # submodule update with initialize and recursive; this is useful to bring a submodule fully up to date.
      smuir = submodule update --init --recursive

      ### status aliases ###

      # status with short format instead of full details
      ss = status --short

      # status with short format and showing branch and tracking info.
      ssb = status --short --branch

      ### log-* aliases ###

      # Show log of new commits after you fetched, with stats, excluding merges
      log-fresh = log ORIG_HEAD.. --stat --no-merges

      # Show log list with our preferred information, a.k.a. `ll`
      log-list = log --graph --topo-order --date=short --abbrev-commit --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn]%Creset %Cblue%G?%Creset'

      # Show log  list with our preferred information with long formats, a.k.a. `lll`
      log-list-long = log --graph --topo-order --date=iso8601-strict --no-abbrev-commit --decorate --all --boundary --pretty=format:'%Cgreen%ad %Cred%h%Creset -%C(yellow)%d%Creset %s %Cblue[%cn <%ce>]%Creset %Cblue%G?%Creset'

      # Show log for my own commits by my own user email
      log-my = !git log --author $(git config user.email)

      # Show log as a graph
      log-graph = log --graph --all --oneline --decorate

      # Show the date of the first (a.k.a. earliest) commit, in strict ISO 8601 format
      log-date-first = !"git log --date-order --format=%cI | tail -1"

      # Show the date of the last (a.k.a. latest) commit, in strict ISO 8601 format
      log-date-last = log -1 --date-order --format=%cI

      # Show log with the recent hour, day, week, month, year
      log-1-hour  = log --since=1-hour-ago
      log-1-day   = log --since=1-day-ago
      log-1-week  = log --since=1-week-ago
      log-1-month = log --since=1-month-ago
      log-1-year  = log --since=1-year-ago

      # Show log with my own recent hour, day, week, month, year
      log-my-hour  = !git log --author $(git config user.email) --since=1-hour-ago
      log-my-day   = !git log --author $(git config user.email) --since=1-day-ago
      log-my-week  = !git log --author $(git config user.email) --since=1-week-ago
      log-my-month = !git log --author $(git config user.email) --since=1-month-ago
      log-my-year  = !git log --author $(git config user.email) --since=1-year-ago

      # Show a specific format string and its number of log entries
      log-of-format-and-count = "!f() { format=\"$1\"; shift; git log $@ --format=oneline --format="$format" | awk '{a[$0]++}END{for(i in a){print i, a[i], int((a[i]/NR)*100) \"%\"}}' | sort; }; f"
      log-of-count-and-format = "!f() { format=\"$1\"; shift; git log $@ --format=oneline --format="$format" | awk '{a[$0]++}END{for(i in a){print a[i], int((a[i]/NR)*100) \"%\", i}}' | sort -nr; }; f"

      # Show the number of log entries by a specific format string and date format string
      log-of-format-and-count-with-date = "!f() { format=\"$1\"; shift; date_format=\"$1\"; shift; git log $@ --format=oneline --format=\"$format\" --date=format:\"$date_format\" | awk '{a[$0]++}END{for(i in a){print i, a[i], int((a[i]/NR)*100) \"%\"}}' | sort -r; }; f"
      log-of-count-and-format-with-date = "!f() { format=\"$1\"; shift; date_format=\"$1\"; shift; git log $@ --format=oneline --format=\"$format\" --date=format:\"$date_format\" | awk '{a[$0]++}END{for(i in a){print a[i], int((a[i]/NR)*100) \"%\", i}}' | sort -nr; }; f"

      # Show the number of log items by email
      log-of-email-and-count         = "!f() { git log-of-format-and-count \"%aE\" $@; }; f"
      log-of-count-and-email         = "!f() { git log-of-count-and-format \"%aE\" $@; }; f"

      # Show the number of log items by hour
      log-of-hour-and-count          = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%Y-%m-%dT%H\" $@ ; }; f"
      log-of-count-and-hour          = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%Y-%m-%dT%H\" $@ ; }; f"

      # Show the number of log items by day
      log-of-day-and-count           = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%Y-%m-%d\" $@ ; }; f"
      log-of-count-and-day           = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%Y-%m-%d\" $@ ; }; f"

      # Show the number of log items by week
      log-of-week-and-count          = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%Y#%V\" $@; }; f"
      log-of-count-and-week          = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%Y#%V\" $@; }; f"

      # Show the number of log items by month
      log-of-month-and-count         = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%Y-%m\" $@ ; }; f"
      log-of-count-and-month         = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%Y-%m\" $@ ; }; f"

      # Show the number of log items by year
      log-of-year-and-count          = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%Y\" $@ ; }; f"
      log-of-count-and-year          = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%Y\" $@ ; }; f"

      # Show the number of log items by hour of day
      log-of-hour-of-day-and-count   = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%H\" $@; }; f"
      log-of-count-and-hour-of-day   = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%H\" $@; }; f"

      # Show the number of log items by day of week
      log-of-day-of-week-and-count   = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%u\" $@; }; f"
      log-of-count-and-day-of-week   = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%u\" $@; }; f"

      # Show the number of log items by week of year
      log-of-week-of-year-and-count  = "!f() { git log-of-format-and-count-with-date \"%ad\" \"%V\" $@; }; f"
      log-of-count-and-week-of-year  = "!f() { git log-of-count-and-format-with-date \"%ad\" \"%V\" $@; }; f"

      # TODO
      log-refs = log --all --graph --decorate --oneline --simplify-by-decoration --no-merges
      log-timeline = log --format='%h %an %ar - %s'
      log-local = log --oneline origin..HEAD
      log-fetched = log --oneline HEAD..origin/main

      # chart: show a summary chart of activity per author.
      #
      # Example:
      #
      #     $ git chart
      #     ..X..........X...2..12 alice@example.com
      #     ....2..2..13.......... bob@example.com
      #     2.....1....11......... carol@example.com
      #     ..1............1..1... david@example.com
      #     ....1.......1.3.3.22.2 eve@example.com
      #
      # The chart rows are the authors.
      # TODO: sort the rows meaningfully,
      # such as alphabetically, or by count.
      #
      # The chart columns are the days.
      # The chart column prints one character per day.
      #
      #   * For 1-9 commits, show the number.
      #   * For 10 or more commits, show "X" as a visual indicator.
      #   * For no commits, show "." as a visual placeholder.
      #
      # The chart timeline adjusts the date range automatically:
      #
      #   * The timeline starts with the date of the earliest commit.
      #   * The timeline stops with the date of the latest commit.
      #   * The intent is to show the most relevant information.
      #
      # The chart default is to look at the past 6 weeks;
      # this gives a good balance of recency and speed
      # for a team that's currently working on a repo,
      # and also gives a good balance of fitting within
      # one terminal window 80 character width.
      #
      # You can adjust how far back the chart looks,
      # by providing your own `--since` parameter.
      # For example if you want to chart an older repo,
      # that does not have any recent commits, then you
      # you must provide a longer `--since` parameter.
      #
      chart = "!f() { \
        git log \
        --format=oneline \
        --format=\"%aE %at\" \
        --since=6-weeks-ago \
        $* | \
        awk ' \
        function time_to_slot(t) { return strftime(\"%Y-%m-%d\", t, true) } \
        function count_to_char(i) { return (i > 0) ? ((i < 10) ? i : \"X\") : \".\" } \
        BEGIN { \
          time_min = systime(); time_max = 0; \
          SECONDS_PER_DAY=86400; \
        } \
        { \
          item = $1; \
          time = 0 + $2; \
          if (time > time_max){ time_max = time } else if (time < time_min){ time_min = time }; \
          slot = time_to_slot(time); \
          items[item]++; \
          slots[slot]++; \
          views[item, slot]++; \
        } \
        END{ \
          printf(\"Chart time range %s to %s.\\n\", time_to_slot(time_min), time_to_slot(time_max)); \
          time_max_add = time_max += SECONDS_PER_DAY; \
          for(item in items){ \
            row = \"\"; \
            for(time = time_min; time < time_max_add; time += SECONDS_PER_DAY) { \
              slot = time_to_slot(time); \
              count = views[item, slot]; \
              row = row count_to_char(count); \
            } \
            print row, item; \
          } \
        }'; \
      }; f"

      # churn: show log of files that have many changes
      #
      #   * Written by [Corey Haines](http://coreyhaines.com/)
      #   * Scriptified by Gary Bernhardt
      #   * Obtained from <https://github.com/garybernhardt/dotfiles/blob/main/bin/git-churn>
      #   * Edited for GitAlias.com repo by Joel Parker Henderson
      #   * Comments by Mislav <http://mislav.uniqpath.com/2014/02/hidden-documentation/>
      #
      # Show churn for whole repo:
      #
      #   $ git churn
      #
      # Show churn for specific directories:
      #
      #   $ git churn app lib
      #
      # Show churn for a time range:
      #
      #   $ git churn --since=1-month-ago
      #
      # These are all standard arguments to `git log`.
      #
      # It's possible to get valuable insight from history of a project not only
      # by viewing individual commits, but by analyzing sets of changes as a whole.
      # For instance, `git churn` compiles stats about which files change the most.
      #
      # For example, to see where work on an app was focused on in the past month:
      #
      #     $ git churn --since=1-month-ago app/ | tail
      #
      # This can also highlight potential problems with technical debt in a project.
      # A specific file changing too often is generally a red flag, since it probably
      # means the file either needed to be frequently fixed for bugs, or the file
      # holds too much responsibility and should be split into smaller units.
      #
      # Similar methods of history analysis can be employed to see which people were
      # responsible recently for development of a certain part of the codebase.
      #
      # For instance, to see who contributed most to the API part of an application:
      #
      #    $ git log --format='%an' --since=1-month-ago app/controllers/api/ | \
      #      sort | uniq -c | sort -rn | head
      #
      #    109 Alice Anderson
      #    13 Bob Brown
      #    7 Carol Clark
      #
      churn = !"f() { git log --all --find-copies --find-renames --name-only --format='format:' \"$@\" | awk 'NF{a[$0]++}END{for(i in a){print a[i], i}}' | sort -rn;};f"

      # summary: print a helpful summary of some typical metrics
      summary = "!f() { \
        printf \"Summary of this branch...\n\"; \
        printf \"%s\n\" $(git rev-parse --abbrev-ref HEAD); \
        printf \"%s first commit timestamp\n\" $(git log --date-order --format=%cI | tail -1); \
        printf \"%s last commit timestamp\n\" $(git log -1 --date-order --format=%cI); \
        printf \"\nSummary of counts...\n\"; \
        printf \"%d commit count\n\" $(git rev-list --count HEAD); \
        printf \"%d date count\n\" $(git log --format=oneline --format=\"%ad\" --date=format:\"%Y-%m-%d\" | awk '{a[$0]=1}END{for(i in a){n++;} print n}'); \
        printf \"%d tag count\n\" $(git tag | wc -l); \
        printf \"%d author count\n\" $(git log --format=oneline --format=\"%aE\" | awk '{a[$0]=1}END{for(i in a){n++;} print n}'); \
        printf \"%d committer count\n\" $(git log --format=oneline --format=\"%cE\" | awk '{a[$0]=1}END{for(i in a){n++;} print n}'); \
        printf \"%d local branch count\n\" $(git branch | grep -v \" -> \" | wc -l); \
        printf \"%d remote branch count\n\" $(git branch -r | grep -v \" -> \" | wc -l); \
        printf \"\nSummary of this directory...\n\"; \
        printf \"%s\n\" $(pwd); \
        printf \"%d file count via git ls-files\n\" $(git ls-files | wc -l); \
        printf \"%d file count via find command\n\" $(find . | wc -l); \
        printf \"%d disk usage\n\" $(du -s | awk '{print $1}'); \
        printf \"\nMost-active authors, with commit count and %%...\n\"; git log-of-count-and-email | head -7; \
        printf \"\nMost-active dates, with commit count and %%...\n\"; git log-of-count-and-day | head -7; \
        printf \"\nMost-active files, with churn count\n\"; git churn | head -7; \
      }; f"

      # Ours & Theirs - Easy merging when you know which files you want
      #
      # Sometimes during a merge you want to take a file from one side wholesale.
      #
      # The following aliases expose the ours and theirs commands which let you
      # pick a file(s) from the current branch or the merged branch respectively.
      #
      #   * git ours - Checkout our version of a file and add it
      #
      #   * git theirs - Checkout their version of a file and add it
      #
      # N.b. the function is there as hack to get $@ doing
      # what you would expect it to as a shell user.
      #
      # Checkout our version of a file and add it.
      ours   = !"f() { git checkout --ours   $@ && git add $@; }; f"
      # Checkout their version of a file and add it.
      theirs = !"f() { git checkout --theirs $@ && git add $@; }; f"
  '';
}
