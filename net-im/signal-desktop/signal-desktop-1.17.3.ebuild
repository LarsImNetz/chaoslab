# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit desktop gnome2-utils

ELECTRON_SLOT="2.0"
ELECTRON_V="2.0.8"
MY_PN="Signal-Desktop"

DESCRIPTION="Signal Private Messenger for the Desktop"
HOMEPAGE="https://signal.org/"
SRC_URI="https://github.com/signalapp/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="libressl"

RDEPEND="
	>=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}
	!libressl? ( dev-libs/openssl:0 )
	libressl? ( dev-libs/libressl:0 )
"
DEPEND="
	sys-apps/nvm
	sys-apps/yarn
"

S="${WORKDIR}/${MY_PN}-${PV}"

pkg_setup() {
	# shellcheck disable=SC2086
	if has network-sandbox $FEATURES && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
}

src_prepare() {
	# Use sqlcipher w/o bundled openssl
	sed -i 's|@journeyapps/sqlcipher": ".*|@journeyapps/sqlcipher": "3.2.1",|' \
		package.json || die

	# Fix Gruntfile.js to play nicely with source tarball. It's not pretty,
	# but works for now. (github.com/signalapp/Signal-Desktop/issues/2376)
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
	newbin "${FILESDIR}"/signal-launcher.sh "${PN}"
	sed "s:@@ELECTRON@@:electron-${ELECTRON_SLOT}:" \
		-i "${ED%/}/usr/bin/${PN}" || die

	insinto /usr/libexec/signal
	doins -r release/linux-unpacked/resources/*

	# Install icons and desktop entry
	local size
	for size in 16 24 32 48 64 128 256 512; do
		newicon -s ${size} "build/icons/png/${size}x${size}.png" signal.png
	done
	# shellcheck disable=SC1117
	make_desktop_entry "${PN}" Signal signal \
		"GTK;Network;Chat;InstantMessaging;" \
		"StartupNotify=true\nStartupWMClass=Signal"
	domenu "${FILESDIR}"/signal-tray.desktop

	# sqlcipher links against libcrypto.so.1.0.0, which does not exist
	# in a LibreSSL environment, and perhaps OpenSSL 1.1.x too
	if has_version 'dev-libs/libressl' || has_version '>=dev-libs/openssl-1.1.0'; then
		dosym libcrypto.so "/usr/$(get_libdir)/libcrypto.so.1.0.0"
	fi
}

update_caches() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	update_caches
}

pkg_postinst() {
	update_caches
}
