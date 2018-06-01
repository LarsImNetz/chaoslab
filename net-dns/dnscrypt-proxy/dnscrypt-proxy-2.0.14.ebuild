# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/jedisct1/${PN}"

inherit fcaps golang-vcs-snapshot systemd user

DESCRIPTION="A flexible DNS proxy, with support for modern encrypted DNS protocols"
HOMEPAGE="https://dnscrypt.info"
SRC_URI="https://${EGO_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="pie systemd"

DOCS=( ChangeLog README.md )
FILECAPS=( cap_net_bind_service+ep usr/bin/dnscrypt-proxy )
QA_PRESTRIPPED="usr/bin/dnscrypt-proxy"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup dnscrypt-proxy
	enewuser dnscrypt-proxy -1 -1 /var/empty dnscrypt-proxy
}

src_prepare() {
	local DNSCRYPT_LOG="${EPREFIX}/var/log/dnscrypt-proxy"
	local DNSCRYPT_CACHE="${EPREFIX}/var/cache/dnscrypt-proxy"

	# shellcheck disable=SC1117
	sed -i \
		-e "s| file = '\([[:graph:]]\+\)'| file = '${DNSCRYPT_LOG}/\1'|g" \
		-e "s|log_file = '\([[:graph:]]\+\)'|log_file = '${DNSCRYPT_LOG}/\1'|g" \
		-e "s|cache_file = '\([[:graph:]]\+\)'|cache_file = '${DNSCRYPT_CACHE}/\1'|g" \
		dnscrypt-proxy/example-dnscrypt-proxy.toml || die

	# shellcheck disable=SC1117
	if use systemd; then
		sed -i "s|\['127.0.0.1:53', '\[::1\]:53'\]|\[\]|" \
			dnscrypt-proxy/example-dnscrypt-proxy.toml || die
	fi

	default
}

src_compile() {
	export GOPATH="${G}"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w"
		-o bin/dnscrypt-proxy
	)
	go build "${mygoargs[@]}" ./dnscrypt-proxy || die
}

src_install() {
	dobin bin/dnscrypt-proxy
	einstalldocs

	newinitd "${FILESDIR}/${PN}-2.initd" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}-2.service" "${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}-2.socket" "${PN}.socket"

	insinto /etc/dnscrypt-proxy
	doins dnscrypt-proxy/example-dnscrypt-proxy.toml
	doins dnscrypt-proxy/example-{blacklist.txt,whitelist.txt}
	doins dnscrypt-proxy/example-{cloaking-rules.txt,forwarding-rules.txt}

	insinto /usr/share/dnscrypt-proxy
	doins -r utils/generate-domains-blacklists/.
}

pkg_postinst() {
	fcaps_pkg_postinst

	if [ ! -e "${EROOT%/}"/etc/dnscrypt-proxy/dnscrypt-proxy.toml ]; then
		elog "No ${PN}.toml found, copying the example over"
		cp "${EROOT%/}"/etc/dnscrypt-proxy/{example-,}dnscrypt-proxy.toml || die
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

	local v
	for v in ${REPLACING_VERSIONS}; do
		if [[ "${v}" = 1.* ]]; then
			elog "Version 2.x.x is a complete rewrite of ${PN}"
			elog "please clean up old config/log files"
			elog
		fi
		if [ "${v}" -lt 2.0.12 ] ; then
			elog "As of version 2.0.12 of ${PN} runs as an 'dnscrypt-proxy' user/group"
			elog "you can remove obsolete 'dnscrypt' accounts from the system"
			elog
		fi
	done

	if systemd_is_booted || has_version sys-apps/systemd; then
		elog "Using systemd socket activation may cause issues with speed"
		elog "latency and reliability of ${PN} and is discouraged by upstream"
		elog "Existing installations advised to disable 'dnscrypt-proxy.socket'"
		elog "It is disabled by default for new installations"
		elog "check $(systemd_get_systemunitdir)/${PN}.service for details"
		elog
	fi

	if [ -z "${REPLACING_VERSIONS}" ]; then
		elog "After starting the service you will need to update your"
		elog "/etc/resolv.conf and replace your current set of resolvers"
		elog "with:"
		elog
		elog "nameserver 127.0.0.1"
		elog
		elog "Also see https://github.com/jedisct1/${PN}/wiki"
	fi
}
