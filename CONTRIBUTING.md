I welcome bug reports, feedbacks and ebuild feature requests; you can use the
[GitLab issue tracker](https://gitlab.com/chaoslab/chaoslab-overlay/issues) or
[e-mail](overlay.xml#L9) ([PGP](README.md#signature)) to provide them.

Code contributions and bug fixes are welcome too, and I encourage the use of
merge requests to _discuss_ and _review_ your ebuild code changes. Before
proposing a large change, please discuss it by raising an issue.

### Before You Begin

This overlay assumes that you have read and properly understood the
[Gentoo Developer Manual](https://devmanual.gentoo.org).

### Making and Submitting Changes

To make the process of merge requests submission as seamless as possible, I ask
for the following:

1. Go ahead and [fork](https://docs.gitlab.com/ee/gitlab-basics/fork-project.html)
   this project.
2. Create your feature branch from the **develop** branch:
   `git checkout -b my-new-feature develop`
3. When your code changes are ready, make sure to run `repoman manifest` and
   `repoman full` in the package directory to ensure that all the Gentoo's QA
   tests pass. This is necessary to assure that nothing was accidentally broken
   by your changes; for the purpose this project integrates
   [GitLab's CI](.gitlab-ci.yml) for _**repoman**_ and _**shellcheck**_ tests.
4. Make sure your git commit messages are in the proper format to make reading
   history easier. Commit your message with `repoman commit`, which should look
   like:

   ```
   category/package-name: short description

   Long description
   ```

   If you have questions about how to write the short/long descriptions,
   please read these blog articles:
   [How to Write a Commit Message](https://chris.beams.io/posts/git-commit/),
   [5 Useful Tips For A Better Commit Message](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message).
   Both of them are excellent resources for learning how to write a well-crafted
   git commit message. If your commit references one or more GitLab issues, or
   other merge requests, please see:
   [Crosslinking Issues](https://docs.gitlab.com/ee/user/project/issues/crosslinking_issues.html)
5. GPG signing your changes is a good idea, but not mandatory.
6. Push your changes in your fork `git push origin my-new-feature`, and then
   submit a [merge request](https://docs.gitlab.com/ee/gitlab-basics/add-merge-request.html)
   against the **develop** branch.

   > **Note:**  If you get in trouble with _**shellcheck's**_ tests, please see
   their [checks guide](https://github.com/koalaman/shellcheck/wiki/Checks).

7. Squash your commits into a single one with `git rebase -i`. It's okay to
   force update your merge request.
8. Comment in the merge request when you are ready for the changes to be
   reviewed: `MR ready for review`.

At this point you are waiting for my feedbacks. I look at pull requests within
few hours. Bear in mind that I may suggest some improvements or alternatives.
