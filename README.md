# pr_patterns
Visualization of Pull Request Patterns

Check out `scratch.rb` to see the env vars you need to set to grab some PR review information from your favorite Github repo

Running `ruby scratch.rb` could then generate for you a file called `graphFile2.json` which you can then display via:

```
ruby -run -e httpd . -p 9090
```

Then open `localhost:9090` in a browser

This is all just getting started - PRs welcome - edit index.html to use `graphFile.json` to check that d3 graph is working for you.

## TODO

* [ ] allow experimentation with force parameters a la https://gist.github.com/steveharoz/8c3e2524079a8c440df60c1ab72b5d03
* [ ] get set to pull in multiple pages of PR data
* [ ] clean up and get a better description for folks checking this out for the first time
