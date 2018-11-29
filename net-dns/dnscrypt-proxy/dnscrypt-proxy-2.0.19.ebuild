# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGO_PN="github.com/jedisct1/${PN}"

inherit fcaps golang-vcs-snapshot-r1 systemd user

DESCRIPTION="A flexible DNS proxy, with support for modern encrypted DNS protocols"
HOMEPAGE="https://dnscrypt.info"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
#RESTRICT="mirror"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="debug pie systemd"

FILECAPS=( cap_net_bind_service+ep usr/bin/dnscrypt-proxy )

DOCS=( ChangeLog README.md )
QA_PRESTRIPPED="usr/bin/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup dnscrypt-proxy
	enewuser dnscrypt-proxy -1 -1 -1 dnscrypt-proxy
}

# shellcheck disable=SC1117
src_prepare() {
	local DNSCRYPT_LOG="${EPREFIX}/var/log/dnscrypt-proxy"
	local DNSCRYPT_CACHE="${EPREFIX}/var/cache/dnscrypt-proxy"

	sed -i \
		-e "s| file = '\([[:graph:]]\+\)'| file = '${DNSCRYPT_LOG}/\1'|g" \
		-e "s|log_file = '\([[:graph:]]\+\)'|log_file = '${DNSCRYPT_LOG}/\1'|g" \
		-e "s|cache_file = '\([[:graph:]]\+\)'|cache_file = '${DNSCRYPT_CACHE}/\1'|g" \
		dnscrypt-proxy/example-dnscrypt-proxy.toml || die

	if use systemd; then
		sed -i "s|\['127.0.0.1:53', '\[::1\]:53'\]|\[\]|" \
			dnscrypt-proxy/example-dnscrypt-proxy.toml || die
	fi

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
		-o bin/dnscrypt-proxy
	)
	go build "${mygoargs[@]}" ./dnscrypt-proxy || die
}

src_install() {
	dobin bin/dnscrypt-proxy
	use debug && dostrip -x /usr/bin/dnscrypt-proxy

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service" "${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}.socket" "${PN}.socket"

	insinto /etc/dnscrypt-proxy
	doins dnscrypt-proxy/example-dnscrypt-proxy.toml
	doins dnscrypt-proxy/example-{blacklist.txt,whitelist.txt}
	doins dnscrypt-proxy/example-{cloaking-rules.txt,forwarding-rules.txt}

	insinto /usr/share/dnscrypt-proxy
	doins -r utils/generate-domains-blacklists/.

	einstalldocs
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [[ ! -e "${EROOT}/etc/dnscrypt-proxy/dnscrypt-proxy.toml" ]]; then
		elog "No ${PN}.toml found, copying the example over"
		cp "${EROOT}"/etc/dnscrypt-proxy/{example-,}dnscrypt-proxy.toml || die
	else
		elog "${PN}.toml found, please check example file for possible changes"
	fi

	if ! use systemd; then
		if ! use filecaps; then
			ewarn
			ewarn "'filecaps' USE flag is disabled"
			ewarn "${PN} will fail to listen on port 53 if started via OpenRC"
			ewarn "please either change port to > 1024, configure to run ${PN} as root"
			ewarn "or re-enable 'filecaps'"
			ewarn
		fi
	fi

	if systemd_is_booted || has_version sys-apps/systemd; then
		elog "Using systemd socket activation may cause issues with speed"
		elog "latency and reliability of ${PN} and is discouraged by upstream"
		elog "Existing installations advised to disable 'dnscrypt-proxy.socket'"
		elog "It is disabled by default for new installations"
		elog "check $(systemd_get_systemunitdir)/${PN}.service for details"
		elog
	fi

	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		elog "After starting the service you will need to update your"
		elog "/etc/resolv.conf and replace your current set of resolvers"
		elog "with:"
		elog
		elog "nameserver 127.0.0.1"
		elog
		elog "Also see https://github.com/jedisct1/${PN}/wiki"
	fi
}
