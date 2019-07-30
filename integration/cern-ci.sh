#!/bin/sh

# Exit in case of error
set -e

# Use the right python tool.
. /acc/local/share/python/L867/setup.sh
python -V

[ x"$CI_COMMIT_SHORT_SHA" != x ] || exit 1

base_destdir=/acc/local/share/ht_tools/noarch/cheby
suffix=$CI_COMMIT_SHORT_SHA
destdir=$base_destdir/cheby-$suffix
prefix=$destdir/lib/python3.6/site-packages/
mkdir -p $prefix

export PYTHONPATH=$PYTHONPATH:$prefix
python3 ./setup.py install --prefix $destdir

cd $base_destdir
ln -sfn cheby-$suffix cheby-latest

if [ -f last ]; then
    old=$(cat last)
    rm -rf ./cheby-$old
fi
echo $suffix > last