#!/bin/sh

if [ -f /usr/tests/sys/cddl/Kyuafile ]; then
	sed -i '' \
		-e 's,include("zfs/Kyuafile"),-- include("zfs/Kyuafile"),' \
		/usr/tests/sys/cddl/Kyuafile
fi
