Scrapes the entire [Maven Central](http://repo1.maven.org/maven2/)
to build a full list
of artifacts, their versions and dates.

Run it like this, to scape all artifacts starting from `org/`:

```
ruby scrape.rb org/
```

If you want to scrape the entire index:

```
ruby scrape.rb ''
```

To exclude something from the list:

```
ruby scrape.rb '' org/,net/
```

This will exclude `org/*` and `net/*` artifacts.


