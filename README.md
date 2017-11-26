Scrapes the entire [Maven Central](http://repo1.maven.org/maven2/)
to build a full list
of artifacts, their versions and dates.

First, clone the repository and run:

```
bundle install
```

Run it like this, to scape all artifacts starting from `org/`:

```
ruby scrape.rb --root=org/
```

If you want to scrape the entire index:

```
ruby scrape.rb
```

To exclude something from the list
(this will exclude `org/*` and `net/*` artifacts):

```
ruby scrape.rb --ignore=org/ --ignore=net/
```

To skip everything until certain path (works only for the first level):

```
ruby scrape.rb --start=org/takes/
```

