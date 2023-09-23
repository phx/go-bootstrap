# go-bootstrap

`go-bootstrap` sets up a full Golang environment automagically with the latest version of Go.

It also installs `[glide](https://github.com/Masterminds/glide/)` from the latest GitHub Release to better handle dependency management.

This has probably already been done before, but I wanted to do it myself to make sure it was done right.

## Details

`go-bootstrap` is currently only for Linux AMD64 because I needed a Go environment set up and took a little extra time to make it reproducable for others and myself in the future.

I will make the necessary changes in the future for cross-platform use.

If you get antsy, just fork it and submit a PR.

## Dependencies

- `bash`
- `curl`

No `sudo` required.

Now Go. Get! No wait, Glide. Peace.
