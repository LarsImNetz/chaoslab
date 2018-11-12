#!/bin/sh
export NODE_ENV=production
@@ELECTRON@@ --app=/usr/libexec/signal/app.asar $@
