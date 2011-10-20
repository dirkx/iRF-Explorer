#!/bin/sh
mkdir git || exit 1
cd git
git clone git@github.com:dirkx/iRF-Explorer.git || exit 1
git clone  -b gh-pages git@github.com:dirkx/iRF-Explorer.git website || exit 1
cd iRF-Explorer  || exit 1
svn export https://pikmeer.webweaving.org/repos/schier/random-open-source/fred iRfExplorer.new || exit 1
(cd iRfExplorer.new; tar cf - .) | tar xf - -C iRfExplorer || exit 1
rm -rf iRfExplorer.new || exit 1
git add -A



