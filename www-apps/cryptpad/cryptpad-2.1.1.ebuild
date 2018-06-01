# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd user

DESCRIPTION="The zero knowledge realtime collaborative editor"
HOMEPAGE="https://cryptpad.fr"
SRC_URI="https://github.com/xwiki-labs/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="AGPL-3+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="net-libs/nodejs[npm]"
RDEPEND="${DEPEND}"

DOCS=( docs/{ARCHITECTURE.md,cryptpad-docker.md,example.nginx.conf} )

pkg_setup() {
	has network-sandbox $FEATURES && \
		die "www-apps/cryptpad requires 'network-sandbox' to be disabled in FEATURES"

	enewgroup cryptpad
	enewuser cryptpad -1 -1 -1 cryptpad
}

src_prepare() {
	local CRYPTPAD_DATADIR="${EPREFIX}/var/lib/cryptpad"
	sed -i \
		-e "s:'./tasks':'${CRYPTPAD_DATADIR}/tasks':" \
		-e "s:'./datastore/':'${CRYPTPAD_DATADIR}/datastore':" \
		-e "s:'./pins':'${CRYPTPAD_DATADIR}/pins':" \
		-e "s:'./blob':'${CRYPTPAD_DATADIR}/blob':" \
		-e "s:'./blobstage':'${CRYPTPAD_DATADIR}/blobstage':" \
		config.example.js || die

	default
}

src_compile() {
	export N_PREFIX="${WORKDIR}/npm"
	local PATH="${N_PREFIX}/node_modules/bower/bin:$PATH"
	mkdir "${N_PREFIX}"{,-cache} || die

	# Check if we have bower installed system-wide,
	# otherwise install it locally:
	if ! command -v bower &>/dev/null; then
		ebegin "Installing bower locally"
		pushd "${N_PREFIX}" > /dev/null || die
		npm install --cache "${WORKDIR}"/npm-cache bower || die
		popd > /dev/null || die
		eend $?
	fi

	ebegin "Using bower $(bower --version) to install dependencies"
	npm install --cache "${WORKDIR}"/npm-cache || die
	bower install || die
	eend $?
}

src_install() {
	einstalldocs
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	systemd_dounit "${FILESDIR}"/${PN}.service

	insinto /etc/cryptpad
	newins config.example.js config.js
	dosym ../../../etc/cryptpad/config.js \
		/usr/share/cryptpad/config.js
	# Remove redundant file
	rm config.example.js || die

	insinto /usr/share/cryptpad
	doins -r {customize.dist,node_modules,storage,www}
	doins *.{js,json}

	diropts -o cryptpad -g cryptpad -m 0750
	keepdir /var/{lib,log}/cryptpad
}
