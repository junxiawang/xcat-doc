#!/bin/sh
SRCDIR="src"
HTMLDIR="html"

for page in $(cd $SRCDIR; ls *.md)
do
    pagename=$(echo "$page" | sed 's/\.md$//')
    echo "page = $page, pagename = $pagename"
    echo "Building doc ${pagename}.html..."
    pandoc -s --toc "${SRCDIR}/$page" -o "${HTMLDIR}/${pagename}.html"
done

