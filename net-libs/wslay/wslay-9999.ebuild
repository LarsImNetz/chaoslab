# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools git-r3

DESCRIPTION="The WebSocket library written in C"
HOMEPAGE="https://tatsuhiro-t.github.io/wslay/"
EGIT_REPO_URI="https://github.com/tatsuhiro-t/wslay.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""

DEPEND="dev-python/sphinx"

DOCS=( AUTHORS COPYING NEWS README.rst )

src_prepare() {
	default
	eautoreconf
}
