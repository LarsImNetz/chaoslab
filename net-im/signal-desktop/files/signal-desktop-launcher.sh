#!/bin/sh

export NODE_ENV=production
@@ELECTRON@@ @@EPREFIX@@/usr/libexec/signal/app.asar "$@"
