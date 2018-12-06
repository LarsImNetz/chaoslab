# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/dannyvankooten/${PN}"

inherit golang-vcs-snapshot-r1

DESCRIPTION="WebExtension host binary for app-admin/pass, a UNIX password manager"
HOMEPAGE="https://www.passwordstore.org"
SRC_URI="https://${EGO_PN}/releases/download/${PV}/${PN}-src.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug pie"

RDEPEND="
	app-admin/pass
	|| (
		www-client/firefox
		www-client/firefox-bin
		www-client/google-chrome
		www-client/chromium
		www-client/ungoogled-chromium
		www-client/ungoogled-chromium-bin
	)
"

DOCS=( README.md )
QA_PRESTRIPPED="usr/libexec/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

src_prepare() {
	sed -i "s:%%replace%%:${EPREFIX}/usr/libexec/browserpass:" \
		firefox/host.json chrome/host.json || die

	default
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie exe)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "$(usex !debug '-s -w' '')"
	)
	go build "${mygoargs[@]}" ./cmd/browserpass || die
}

src_install() {
	exeinto /usr/libexec
	doexe browserpass
	use debug && dostrip -x /usr/libexec/browserpass

	if has_version www-client/firefox || \
		has_version www-client/firefox-bin; then
		insinto "/usr/$(get_libdir)/mozilla/native-messaging-hosts"
		newins firefox/host.json com.dannyvankooten.browserpass.json
	fi

	if has_version www-client/google-chrome || \
		has_version www-client/chromium || \
		has_version www-client/ungoogled-chromium || \
		has_version www-client/ungoogled-chromium-bin; then
		insinto /etc/chromium/native-messaging-hosts
		newins chrome/host.json com.dannyvankooten.browserpass.json
	fi

	einstalldocs
}

pkg_postinst() {
	if [[ -z "$REPLACING_VERSIONS" ]]; then
		elog "To use Browserpass, you must install the extention to your browser"
		if has_version www-client/firefox || \
			has_version www-client/firefox-bin; then
				elog "- https://addons.mozilla.org/en-US/firefox/addon/browserpass-ce/"
		fi
		if has_version www-client/google-chrome || \
			has_version www-client/chromium || \
			has_version www-client/ungoogled-chromium || \
			has_version www-client/ungoogled-chromium-bin; then
				elog "- https://chrome.google.com/webstore/detail/browserpass-ce/naepdomgkenhinolocfifgehidddafch"
		fi
	fi
}
