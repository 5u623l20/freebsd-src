#!/bin/sh

set -ex

rm -fr ${MAKEOBJDIRPREFIX}

MAKECONF=${MAKECONF:-/dev/null}
SRCCONF=${SRCCONF:-/dev/null}

if [ -f "${WORKSPACE}/.cirrus-ci/scripts/build/config/build-world-kernel-${TARGET_ARCH}-src.conf" ]; then
    SRCCONF=${WORKSPACE}/.cirrus-ci/scripts/build/config/build-world-kernel-${TARGET_ARCH}-src.conf
fi

if [ -f "${WORKSPACE}/.cirrus-ci/scripts/build/config/build-world-kernel-${TARGET_ARCH}-make.conf" ]; then
    MAKECONF=${WORKSPACE}/.cirrus-ci/scripts/build/config/build-world-kernel-${TARGET_ARCH}-make.conf
fi

if [ -n "${CROSS_TOOLCHAIN}" ]; then
    CROSS_TOOLCHAIN_PARAM=CROSS_TOOLCHAIN=${CROSS_TOOLCHAIN}
fi

make -j ${JFLAG} -DNO_CLEAN \
    buildworld \
    TARGET=${TARGET} \
    TARGET_ARCH=${TARGET_ARCH} \
    ${CROSS_TOOLCHAIN_PARAM} \
    __MAKE_CONF=${MAKECONF} \
    SRCCONF=${SRCCONF}
make -j ${JFLAG} -DNO_CLEAN \
    buildkernel \
    TARGET=${TARGET} \
    TARGET_ARCH=${TARGET_ARCH} \
    ${CROSS_TOOLCHAIN_PARAM} \
    __MAKE_CONF=${MAKECONF} \
    SRCCONF=${SRCCONF}

cd ${WORKSPACE}/release

make clean
make -DNOPORTS -DNOSRC -DNODOC packagesystem \
    TARGET=${TARGET} TARGET_ARCH=${TARGET_ARCH} \
    MAKE="make -DDB_FROM_SRC __MAKE_CONF=${MAKECONF} SRCCONF=${SRCCONF}"

mkdir -p ${ARTIFACT_DEST}
mv ${MAKEOBJDIRPREFIX}/${WORKSPACE}/${TARGET}.${TARGET_ARCH}/release/*.txz ${ARTIFACT_DEST}
mv ${MAKEOBJDIRPREFIX}/${WORKSPACE}/${TARGET}.${TARGET_ARCH}/release/MANIFEST ${ARTIFACT_DEST}

echo "${GIT_COMMIT}" | sudo tee ${ARTIFACT_DEST}/revision.txt

echo "USE_GIT_COMMIT=${GIT_COMMIT}" > ${WORKSPACE}/trigger.property
