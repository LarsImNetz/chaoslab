# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/42wim/${PN}"

inherit golang-vcs-snapshot user

DESCRIPTION="Connect to your Mattermost or Slack using your IRC-client of choice"
HOMEPAGE="https://github.com/42wim/matterircd"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE="pie"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/matterircd"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup matterircd
	enewuser matterircd -1 -1 -1 matterircd
}

src_compile() {
	export GOPATH="${G}"
	local mygoargs=(
		-v -work -x
		"-buildmode=$(usex pie pie default)"
		"-asmflags=all=-trimpath=${S}"
		"-gcflags=all=-trimpath=${S}"
		-ldflags "-s -w"
	)
	go build "${mygoargs[@]}" || die
}

src_install() {
	dobin matterircd
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"

	insinto /etc/matterircd
	doins matterircd.toml.example

	diropts -o matterircd -g matterircd -m 0750
	keepdir /var/log/matterircd
}

pkg_postinst() {
	if [[ ! -e "${EROOT%/}/etc/matterircd/matterircd.toml" ]]; then
		elog "No matterircd.toml found, copying the example over"
		cp "${EROOT%/}"/etc/matterircd/matterircd.toml{.example,} || die
	else
		elog "matterircd.toml found, please check example file for possible changes"
	fi
}
