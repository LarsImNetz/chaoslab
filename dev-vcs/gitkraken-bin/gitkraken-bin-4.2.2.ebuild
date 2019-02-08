# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

ELECTRON_SLOT="2.0"
ELECTRON_V="2.0.12"
ASAR_V="0.14.3"

DESCRIPTION="The intuitive, fast, and beautiful cross-platform Git client"
HOMEPAGE="https://www.gitkraken.com"
SRC_URI="
	https://release.gitkraken.com/linux/GitKraken-v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/elprans/asar/releases/download/v${ASAR_V}-gentoo/asar-build.tar.gz -> asar-${ASAR_V}.tar.gz
"
RESTRICT="mirror"

LICENSE="gitkraken-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="libressl"

RDEPEND="
	>=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}
	gnome-base/libgnome-keyring
	net-misc/curl[ssl]
	!libressl? ( dev-libs/openssl:0 )
	libressl? ( dev-libs/libressl:0 )
"
DEPEND="
	>=dev-util/patchelf-0.9_p20180129
	net-libs/nodejs
"

QA_PREBUILT="usr/libexec/gitkraken/app.asar.unpacked/node_modules/*"

S="${WORKDIR}/gitkraken"

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "${PN} only works on amd64"
}

src_prepare() {
	ebegin "Fixing asar archive"
	easar extract resources/app.asar app

	pushd app/node_modules/@axosoft/nodegit/build/Release > /dev/null || die
	# nodegit.node links against libcurl-gnutls.so.4, which does not exist in Gentoo
	patchelf --replace-needed libcurl-gnutls.so.4 libcurl.so.4 \
		nodegit.node || die "failed to patch libcurl library dependency"
	# Likewise, it links against {libcrypto,libssl}.so.1.0.0, which does
	# not exist in a LibreSSL environment, and perhaps OpenSSL 1.1.x too
	if has_version 'dev-libs/libressl' || has_version '>=dev-libs/openssl-1.1.0'; then
		patchelf --replace-needed libcrypto.so.1.0.0 libcrypto.so \
			nodegit.node || die "failed to patch libcrypto library dependency"
		patchelf --replace-needed libssl.so.1.0.0 libssl.so \
			nodegit.node || die "failed to patch libssl library dependency"
	fi
	popd > /dev/null || die

	easar pack app app.asar
	eend $?
	default
}

src_install() {
	newbin "${FILESDIR}"/gitkraken-launcher.sh gitkraken
	sed "s:@@ELECTRON@@:electron-${ELECTRON_SLOT}:" \
		-i "${ED}"/usr/bin/gitkraken || die

	insinto /usr/libexec/gitkraken
	doins app.asar

	# Note: intentionally not using "doins" so that we preserve +x bits
	cp -r resources/app.asar.unpacked "${ED}"/usr/libexec/gitkraken || die

	doicon -s 512 "${FILESDIR}"/icon/gitkraken.png
	make_desktop_entry gitkraken GitKraken gitkraken Development
}

# asar wrapper, hat tip @elprans (taken from https://github.com/elprans/atom-overlay)
easar() {
	local asar="${WORKDIR}/asar-${ASAR_V}/node_modules/asar/bin/asar"
	echo "asar" "${@}"
	node "${asar}" "${@}" || die
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $? || die
	fi
	xdg_desktop_database_update
}

pkg_postrm() {
	update_caches
}

pkg_postinst() {
	update_caches
}
