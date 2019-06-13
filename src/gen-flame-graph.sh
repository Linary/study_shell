#!/bin/bash

# Usage: ./gen.sh collected-stacks.txt

TMPSTACKS=/tmp/flamegraph-stacks-collapsed.txt
TMPPALETTE=/tmp/flamegraph-palette.map

./stackcollapse-jstack.pl $1 > $TMPSTACKS

# 1st run - hot: default
./flamegraph.pl --cp $TMPSTACKS > stacks.svg

# 2nd run - blue: I/O
cp palette.map $TMPPALETTE
cat $TMPPALETTE | grep -v '\.read' | grep -v '\.write' | grep -v 'socketRead' | grep -v 'socketWrite' | grep -v 'socketAccept' > palette.map
./flamegraph.pl --cp --colors=io $TMPSTACKS > stacks.svg

echo "Done! Now see the output in stacks.svg"
