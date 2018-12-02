#!/bin/sh
export NODE_ENV=production
@@ELECTRON@@ --app=/usr/libexec/oni/app $@
