# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CHROMIUM_LANGS="
	am ar bg bn ca cs da de el en-GB en-US es-419 es et fa fi fil fr gu he hi hr
	hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv sw
	ta te th tr uk vi zh-CN zh-TW
"

inherit chromium-2 desktop readme.gentoo-r1 xdg-utils

MY_PV="${PV/_p/-}"
MY_PN="${PN/-bin}"
MY_P="${MY_PN}_${MY_PV}_linux"
DESCRIPTION="Modifications to Chromium for removing Google integration and enhancing privacy"
HOMEPAGE="https://github.com/Eloston/ungoogled-chromium"
SRC_URI="https://github.com/intika/uc-arch-binaries/releases/download/${MY_PV}/${MY_P}.tar.xz -> ${PN}-${MY_PV}.tar.xz"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE="+suid widevine"

RDEPEND="
	app-accessibility/at-spi2-atk:2
	app-arch/bzip2
	>=net-print/cups-1.3.11
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.26
	>=media-libs/alsa-lib-1.0.19
	media-libs/fontconfig
	media-libs/freetype
	>=media-libs/harfbuzz-1.6.0
	media-libs/libpng
	sys-apps/dbus
	sys-apps/pciutils
	virtual/opengl
	virtual/ttf-fonts
	virtual/udev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3[X]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libXi-1.6.0
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
	widevine? ( www-plugins/chrome-binary-plugins[widevine(-)] )
	!www-client/chromium
	!www-client/ungoogled-chromium
"

DEPEND="app-arch/xz-utils"

DISABLE_AUTOFORMATTING="yes"
DOC_CONTENTS="
Some web pages may require additional fonts to display properly.
Try installing some of the following packages if some characters
are not displayed properly:
- media-fonts/arphicfonts
- media-fonts/droid
- media-fonts/ipamonafont
- media-fonts/noto
- media-fonts/ja-ipafonts
- media-fonts/takao-fonts
- media-fonts/wqy-microhei
- media-fonts/wqy-zenhei

To fix broken icons on the Downloads page, you should install an icon
theme that covers the appropriate MIME types, and configure this as your
GTK+ icon theme.
"

QA_PREBUILT="*"
S="${WORKDIR}/${MY_P}"

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "${PN} only works on amd64"
}

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_install() {
	local CHROMIUM_HOME="/opt/chromium-browser"
	exeinto "${CHROMIUM_HOME}"
	doexe chrome

	if use suid; then
		newexe chrome_sandbox chrome-sandbox
		fperms 4755 "${CHROMIUM_HOME}/chrome-sandbox"
	fi

	if use widevine; then
		dosym "../../usr/$(get_libdir)/chromium/libwidevinecdm.so" \
			"${CHROMIUM_HOME}/libwidevinecdm.so"
	fi

	doexe chromedriver

	newexe "${FILESDIR}/${PN}-launcher-r3.sh" chromium-launcher.sh
	sed -i "s:/usr/lib/:/usr/$(get_libdir)/:g" \
		"${ED}${CHROMIUM_HOME}/chromium-launcher.sh" || die

	# It is important that we name the target "chromium-browser",
	# xdg-utils expect it (bug #355517)
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium-browser
	# keep the old symlink around for consistency
	dosym "${CHROMIUM_HOME}/chromium-launcher.sh" /usr/bin/chromium

	dosym "${CHROMIUM_HOME}/chromedriver" /usr/bin/chromedriver

	# Allow users to override command-line options (bug #357629)
	insinto /etc/chromium
	newins "${FILESDIR}/${PN}.default" "default"

	pushd locales > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	insinto "${CHROMIUM_HOME}"
	doins ./*.bin
	doins ./*.pak
	doins ./*.so
	doins icudtl.dat

	doins -r locales
	doins -r resources

	# Install icons and desktop entry
	newicon -s 48 "product_logo_48.png" chromium-browser.png

	local mime_types="text/html;text/xml;application/xhtml+xml;"
	mime_types+="x-scheme-handler/http;x-scheme-handler/https;" # bug #360797
	mime_types+="x-scheme-handler/ftp;" # bug #412185
	mime_types+="x-scheme-handler/mailto;x-scheme-handler/webcal;" # bug #416393
	# shellcheck disable=SC1117
	make_desktop_entry \
		chromium-browser \
		"Chromium" \
		chromium-browser \
		"Network;WebBrowser" \
		"MimeType=${mime_types}\nStartupWMClass=chromium-browser"
	sed -i "/^Exec/s/$/ %U/" "${ED}"/usr/share/applications/*.desktop || die

	# Install GNOME default application entry (bug #303100)
	insinto /usr/share/gnome-control-center/default-apps
	doins "${FILESDIR}/chromium-browser.xml"

	readme.gentoo_create_doc
}

update_caches() {
	if type gtk-update-icon-cache &>/dev/null; then
		ebegin "Updating GTK icon cache"
		gtk-update-icon-cache "${EROOT}/usr/share/icons/hicolor"
		eend $?
	fi
	xdg_desktop_database_update
}

pkg_postrm() {
	update_caches
}

pkg_postinst() {
	update_caches
	readme.gentoo_print_elog
}
