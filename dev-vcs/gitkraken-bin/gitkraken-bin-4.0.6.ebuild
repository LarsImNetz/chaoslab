# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit gnome2-utils

ELECTRON_SLOT="2.0"
ASAR_V="0.14.3"

DESCRIPTION="The intuitive, fast, and beautiful cross-platform Git client"
HOMEPAGE="https://www.gitkraken.com"
SRC_URI="
	https://release.gitkraken.com/linux/GitKraken-v${PV}.tar.gz -> ${P}.tar.gz
	patchelf-fix? ( https://github.com/elprans/asar/releases/download/v${ASAR_V}-gentoo/asar-build.tar.gz -> asar-${ASAR_V}.tar.gz )
"
RESTRICT="mirror"

LICENSE="gitkraken-EULA"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="libressl +patchelf-fix"

DEPEND="
	patchelf-fix? (
		net-libs/nodejs
		>=dev-util/patchelf-0.9_p20180129
	)
"
RDEPEND="
	dev-util/electron-bin:${ELECTRON_SLOT}
	gnome-base/libgnome-keyring
	net-misc/curl[ssl]
	!libressl? ( dev-libs/openssl:0 )
	libressl? ( dev-libs/libressl:0 )
"

QA_PREBUILT="usr/libexec/gitkraken/app.asar.unpacked/node_modules/*"

S="${WORKDIR}/gitkraken"

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "${PN} only works on amd64"
}

src_install() {
	newbin "${FILESDIR}"/gitkraken-launcher.sh-r1 gitkraken
	sed "s:%%ELECTRON%%:electron-${ELECTRON_SLOT}:" \
		-i "${ED%/}"/usr/bin/gitkraken || die

	insinto /usr/libexec/gitkraken

	# TODO: Do we really need this?
	#doins resources/default_app.asar
	#doins resources/electron.asar

	if use patchelf-fix; then
		ebegin "Fixing asar archive"
		easar extract resources/app.asar app

		pushd app/node_modules/nodegit/build/Release || die
		# GitKraken links against libcurl-gnutls.so.4,
		# which does not exist in Gentoo
		patchelf --replace-needed libcurl-gnutls.so.4 libcurl.so.4 \
			nodegit.node || die "failed to patch libcurl library dependency"
		if use libressl; then
			patchelf --replace-needed libcrypto.so.1.0.0 libcrypto.so \
				nodegit.node || die "failed to patch libcrypto library dependency"
			patchelf --replace-needed libssl.so.1.0.0 libssl.so \
				nodegit.node || die "failed to patch libssl library dependency"
		fi
		popd || die

		easar pack app app.asar
		eend $?
		doins app.asar
	else
		doins resources/app.asar
		dosym libcurl.so.4 "/usr/$(get_libdir)/libcurl-gnutls.so.4"
		if use libressl; then
			dosym libcrypto.so "/usr/$(get_libdir)/libcrypto.so.1.0.0"
			dosym libssl.so "/usr/$(get_libdir)/libssl.so.1.0.0"
		fi
	fi

	# Note: intentionally not using "doins" so that we preserve +x bits
	cp -R resources/app.asar.unpacked "${ED%/}"/usr/libexec/gitkraken || die

	doicon -s 512 "${FILESDIR}"/icon/gitkraken.png
	make_desktop_entry gitkraken GitKraken gitkraken Development
}

pkg_postinst() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	gnome2_icon_cache_update
}

# asar wrapper (taken from atom-overlay)
easar() {
	local asar="${WORKDIR}/asar-${ASAR_V}/node_modules/asar/bin/asar"
	echo "asar" "${@}"
	node "${asar}" "${@}" || die
}
