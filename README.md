# correlaidx-challenge2022-munich2

**Summary**

**Project structure**

```
.
├── notebooks                <- Jupyter notebooks
├── reports                  <- Generated analysis as HTML, PDF, LaTeX, etc./
│   └── figures              <- Generated graphics and figures to be used in reporting
├── src                      <- Source code for use in this project cyphers, e.g, neo4j-cyphers, python, ...
├── .gitignore               <- Specifies files and folders ignored by git
├── .pre-commit-config.yaml  <- Git hook script to support code standards
└── README.md                <- Project summary, development guidelines, ...
```

## Development

**Pre-commit Hooks**

>Git hook scripts are useful for identifying simple issues before submission to code review. We run our hooks on every
> commit to automatically point out issues in code such as missing semicolons, trailing whitespace, and debug
> statements.[[1]](https://pre-commit.com/#install)

If you'd like to benefit from pre-commit hooks configured in the `.pre-commit-config.yaml`, please follow the
[installation instructions](https://pre-commit.com/#install). After you've installed the git hook script,
it may happen that your first commit fails because at least one commit hook failed. Your committed files should be
automatically reformatted so that a second commit should work.
