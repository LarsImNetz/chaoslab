# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="A tool to encrypt files to yourself for long-term archival"
HOMEPAGE="https://github.com/skeeto/enchive"
SRC_URI="https://github.com/skeeto/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
DOCS=( README.md )

RESTRICT="mirror"

src_prepare() {
	# Leave optimization level to user CFLAGS
	sed -i \
		-e 's:CFLAGS =:CFLAGS +=:' \
		-e 's:-pedantic -Wall -Wextra -O3 ::g' \
		Makefile || die

	default
}

src_install() {
	emake \
		PREFIX="${EPREFIX}/usr" \
		DESTDIR="${D}" install

	einstalldocs
}
