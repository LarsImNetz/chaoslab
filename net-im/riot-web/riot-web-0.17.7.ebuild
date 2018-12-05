# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

ELECTRON_SLOT="3.0"
ELECTRON_V="3.0.10"

DESCRIPTION="A glossy Matrix collaboration client for the web"
HOMEPAGE="https://about.riot.im/"
SRC_URI="https://github.com/vector-im/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND=">=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}"
DEPEND="net-libs/nodejs[npm]"

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
	default

	# Depending on the architecture, in order to accelerate the build process,
	# removes the compilation of ia32 or x64 build.
	if [[ "${ARCH}" == amd64 ]]; then
		sed -i 's| --ia32||g' package.json || die
	elif [[ "${ARCH}" == x86 ]]; then
		sed -i 's| --x64||g' package.json || die
	else
		die "This ebuild doesn't support ${ARCH}"
	fi

	# Reduce build time by removing the creation of a .deb and AppImage
	# Don't waste time trying to package for other OSes
	sed -i \
		-e 's|"deb"|"dir"|g' \
		-e 's|-wml|--linux|g' \
		-e '/electronVersion/d' \
		package.json || die
}

src_compile() {
	npm install || die
	npm run build:electron || die
}

src_install() {
	newbin "${FILESDIR}/${PN}-launcher.sh" "${PN}"
	sed -i \
		-e "s:@@ELECTRON@@:electron-${ELECTRON_SLOT}:" \
		-e "s:@@EPREFIX@@:${EPREFIX}:" \
		"${ED}/usr/bin/${PN}" || die

	insinto /usr/libexec/riot-web
	doins -r electron_app/dist/linux*unpacked/resources/*

	# Install icons and desktop entry
	local size
	for size in 16 24 48 64 96 128 256 512; do
		newicon -s ${size} "electron_app/build/icons/${size}x${size}.png" riot.png
	done
	make_desktop_entry "${PN}" Riot riot \
		"GTK;Network;Chat;InstantMessaging;" \
		"StartupNotify=true\\nStartupWMClass=riot-web"
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
