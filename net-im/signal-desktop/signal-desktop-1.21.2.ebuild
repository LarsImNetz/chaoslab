# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

ELECTRON_SLOT="3.0"
ELECTRON_V="3.0.14"
MY_PN="Signal-Desktop"
MY_PV="${PV/_beta/-beta.}"

DESCRIPTION="Signal Private Messenger for the Desktop"
HOMEPAGE="https://signal.org/"
SRC_URI="https://github.com/signalapp/${MY_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="start-in-tray"

RDEPEND=">=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}"
DEPEND="
	sys-apps/nvm
	sys-apps/yarn
"

S="${WORKDIR}/${MY_PN}-${MY_PV}"

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
	# Fix Gruntfile.js to play nicely without a proper git repository. It's not
	# pretty, but works for now. If you know a better fix, please contribute.
	# See https://github.com/signalapp/Signal-Desktop/issues/2376
	local buildexp
	buildexp="$(date -Iseconds -u -d '+90 days')"
	echo "{\"buildExpiration\":$(date -d "${buildexp}" +'%s%3N')}" \
		> config/local-production.json || die
	sed -i "/ 'date',/d" Gruntfile.js || die

	default
}

src_compile() {
	local myprefix
	export npm_config_cache="${S}/npm_cache"
	mkdir "${npm_config_cache}" || die
	myprefix="$(npm config get prefix)"
	npm config delete prefix || die

	# Switch to required node version
	# shellcheck source=/dev/null
	source "${EPREFIX}/usr/share/nvm/init-nvm.sh" --install
	nvm install || die
	nvm use || die

	# Download modules and build Signal
	yarn install || die
	yarn generate || die
	yarn build-release --dir || die

	# Restore config
	npm config set prefix "${myprefix}" || die
	nvm unalias default || die
}

src_install() {
	newbin "${FILESDIR}/${PN}-launcher.sh" "${PN}"
	sed -i \
		-e "s:@@ELECTRON@@:electron-${ELECTRON_SLOT}:" \
		-e "s:@@EPREFIX@@:${EPREFIX}:" \
		"${ED}/usr/bin/${PN}" || die

	insinto /usr/libexec/signal
	doins -r release/linux-unpacked/resources/*

	# Install icons and desktop entry
	local size
	for size in 16 24 32 48 64 128 256 512; do
		newicon -s ${size} "build/icons/png/${size}x${size}.png" signal.png
	done
	make_desktop_entry "${PN}" Signal signal \
		"GTK;Network;Chat;InstantMessaging;" \
		"StartupNotify=true\\nStartupWMClass=Signal"
	use start-in-tray && domenu "${FILESDIR}"/signal-desktop-tray.desktop
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
