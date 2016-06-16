# youtube-search-example

This is a simple shell tool written in Haskell for using youtube API to search for your keyword.

If you are looking for a simple, but real-life example of using Aeson to parse JSON, this may be useful to you.

If youtube-dl is installed, this can also be used to call it.

It can also pass on an option to produce mp3 with youtube-dl.

You might need libavcodec-extra-53 (on Ubuntu) or something similar installed for the mp3 encoding to work.

## Building

It is written in Haskell.

You will probably need stackage working on your machine to build this.

```
> stack init

> stack build

> stack exec youtube-search-example-exe -- --key=<Your youtube search key> --keyword=<Your search keyword> --format=mp3
```

The `format` is currently only useful if you use "mp3". `--format` is optional but you need the key and keyword.

## Licence

See the LICENSE file included in the repo.

