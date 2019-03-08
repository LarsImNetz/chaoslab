# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

ELECTRON_SLOT="4.0"
ELECTRON_V="4.0.6"
MY_PV="${PV/_rc/-rc.}"

DESCRIPTION="A glossy Matrix collaboration client for desktop"
HOMEPAGE="https://about.riot.im/"
SRC_URI="https://github.com/vector-im/riot-web/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}"
DEPEND="net-libs/nodejs[npm]"

S="${WORKDIR}/riot-web-${MY_PV}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_prepare() {
	sed -i 's|https://riot.im/download/desktop/update/|null|g' \
		electron_app/riot.im/config.json || die

	default
}

src_compile() {
	# Build webapp
	npm install --cache "${WORKDIR}/npm-cache" || die
	npm run build --cache "${WORKDIR}/npm-cache" || die

	pushd electron_app > /dev/null || die
	npm install --cache "${WORKDIR}/npm-cache" || die
	popd > /dev/null || die
}

src_install() {
	newbin "${FILESDIR}/${PN}-launcher.sh" "${PN}"
	sed -i \
		-e "s:@@ELECTRON@@:electron-${ELECTRON_SLOT}:" \
		-e "s:@@EPREFIX@@:${EPREFIX}:" \
		"${ED}/usr/bin/${PN}" || die

	insinto /usr/share/riot
	doins -r webapp/*
	echo "${MY_PV}" > "${ED}"/usr/share/riot/version || die

	insinto /etc/riot
	doins config.sample.json
	doins electron_app/riot.im/config.json
	dosym ../../../etc/riot/config.json /usr/share/riot/config.json

	insinto /usr/libexec/riot
	doins package.json
	doins -r origin_migrator

	dosym ../../share/riot /usr/libexec/riot/webapp

	insinto /usr/libexec/riot/electron_app
	doins -r electron_app/{node_modules,src}

	insinto /usr/libexec/riot/electron_app/img
	doins electron_app/img/riot.png

	# Install icons and desktop entry
	local size
	for size in 16 24 48 64 96 128 256 512; do
		newicon -s ${size} "electron_app/build/icons/${size}x${size}.png" riot.png
	done
	newicon -s scalable res/themes/riot/img/logos/riot-im-logo.svg riot.svg
	make_desktop_entry "${PN}" Riot riot \
		"Network;Chat;InstantMessaging;IRCClient" \
		"Terminal=false\\nStartupNotify=true\\nStartupWMClass=Riot"
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $? || die
	fi
	xdg_desktop_database_update
}

pkg_postinst() {
	update_caches
}

pkg_postrm() {
	update_caches
}
