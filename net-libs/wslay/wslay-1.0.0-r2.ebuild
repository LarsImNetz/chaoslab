# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
RESTRICT="mirror"

inherit autotools

MY_PV="release-${PV}"
DESCRIPTION="The WebSocket library written in C"
HOMEPAGE="https://tatsuhiro-t.github.io/wslay/"
SRC_URI="https://github.com/tatsuhiro-t/${PN}/archive/${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="dev-python/sphinx"

DOCS=( AUTHORS COPYING NEWS README.rst )

S="${WORKDIR}/${PN}-${MY_PV}"

src_prepare() {
	default
	eautoreconf
}
