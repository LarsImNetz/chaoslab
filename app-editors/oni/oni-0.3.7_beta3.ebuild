# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop xdg-utils

ELECTRON_SLOT="2.0"
ELECTRON_V="2.0.8"
MY_PV="${PV/_/-}"

DESCRIPTION="Code editor with a modern twist on modal editing, powered by Neovim"
HOMEPAGE="https://www.onivim.io"
SRC_URI="https://github.com/onivim/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-editors/neovim
	>=dev-util/electron-bin-${ELECTRON_V}:${ELECTRON_SLOT}
"
DEPEND="
	sys-apps/nvm
	sys-apps/yarn
"

QA_PRESTRIPPED="usr/libexec/oni/app/node_modules/oni-ripgrep/bin/rg"

S="${WORKDIR}/${PN}-${MY_PV}"

pkg_pretend() {
	# shellcheck disable=SC2086
	if has network-sandbox ${FEATURES} && [[ "${MERGE_TYPE}" != binary ]]; then
		ewarn
		ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
		ewarn
		die "[network-sandbox] is enabled in FEATURES"
	fi
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

	# Download modules and build Oni
	yarn install || die
	yarn run build || die
	yarn run pack --dir || die

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

	insinto /usr/libexec/oni
	doins -r dist/linux-unpacked/resources/app

	# Install icons and desktop entry
	newicon -s scalable images/oni-icon-no-border.svg oni.svg
	make_desktop_entry oni Oni oni \
		"GNOME;GTK;Utility;TextEditor;Development;" \
		"MimeType=text/plain;\\nStartupNotify=true\\nStartupWMClass=oni"
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
