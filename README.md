# Reference Downloader

Download the reference documentation and user manuals for installed versions of
various programs.

```sh
./get_refs.sh
```

PDF documents are prioritized, and if not available, HTML pages are downloaded
instead.

To download documentaiton only for specific programs, pass the program as a
command line argument:

```sh
./get-refs.sh <program>
```

The supported programs are specified in the `data` file.

**IMPORTANT:** This program is built on the fundamental assumption that software
documentation is versioned and served in a straightforward, predictable way. Any
site that requires version-specific workarounds will not be supported.
