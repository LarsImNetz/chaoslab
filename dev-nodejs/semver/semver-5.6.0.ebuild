# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The semantic version parser used by npm"
HOMEPAGE="https://github.com/npm/node-semver"
SRC_URI="https://registry.npmjs.org/${PN}/-/${P}.tgz"
RESTRICT="mirror"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="net-libs/nodejs[npm]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/npm-build"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_unpack() {
	mkdir npm-build || die
}

src_compile() {
	npm install -g --prefix ./usr "${DISTDIR}/${P}.tgz" || die
}

src_install() {
	cp -r "${WORKDIR}"/npm-build/* "${ED}" || die
}
