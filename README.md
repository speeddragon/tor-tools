# TorTools

This is a set of tools to use with Linux/OSX machines to fetch list of files from a onion (TOR) web page.

## Features

- Auto-resume
- File size check

## Scripts

### download_links.sh <URL>

Given a URL, it will search for '<a href=""></a>' to extract the URL and add to a TXT file. It will ignore link that starts with `/` and `?`.

### check_missing.sh

Check if the files downloaded from the link are all there.

### verify.sh 

Verify if downloaded files have the exact bytes as the ones in the web. Because on large files might exist before downloading the hole file.

## Limitations

- [ ] Only supports flat structure (don't go deep into folders).

## Context

Due to some research I've decided to create a set of bash scripts to download files using the TOR network. I've found some unexpected issues (connection issues) and decided to improve both on download and verification.
