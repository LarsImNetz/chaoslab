# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

GIT_COMMIT="7dc36ae"
EGO_PN="github.com/${PN}/${PN}"

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Grafana is an open source metric analytics & visualization suite"
HOMEPAGE="https://grafana.com"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="!www-apps/grafana-bin"
DEPEND=">=net-libs/nodejs-6
	sys-apps/yarn"

DOCS=( {README,CHANGELOG}.md )

QA_PRESTRIPPED="usr/bin/grafana-cli
	usr/bin/grafana-server
	usr/libexec/grafana/phantomjs"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	# shellcheck disable=SC2086
	has network-sandbox $FEATURES && \
		die "www-apps/grafana requires 'network-sandbox' to be disabled in FEATURES"

	enewgroup grafana
	enewuser grafana -1 -1 /usr/share/grafana grafana
}

src_prepare() {
	# Unfortunately 'network-sandbox' needs to disabled
	# because yarn/npm fetches some dependencies here:
	emake deps
	default
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}/bin"
	# shellcheck disable=SC2207
	local mygoargs=(
		-v -work -x
		$(usex pie '-buildmode=pie' '')
		-asmflags "-trimpath=${S}"
		-gcflags "-trimpath=${S}"
		-ldflags "-s -w
		-X main.version=${PV}
		-X main.commit=${GIT_COMMIT}
		-X main.buildstamp=$(date -u '+%s')"
	)
	go install "${mygoargs[@]}" ./pkg/cmd/grafana-{cli,server} || die

	emake build-js
}

src_test() {
	emake test-go test-js
}

src_install() {
	dobin bin/grafana-{cli,server}
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	exeinto /usr/libexec/grafana
	doexe tools/phantomjs/phantomjs
	scanelf -Xe "${ED%/}"/usr/libexec/grafana/phantomjs || die

	insinto /etc/grafana
	newins conf/sample.ini grafana.ini.example

	insinto /usr/share/grafana/conf
	doins conf/{defaults.ini,ldap.toml}

	insinto /usr/share/grafana
	doins -r public

	insinto /usr/share/grafana/tools/phantomjs
	doins tools/phantomjs/render.js
	dosym ../../../../libexec/grafana/phantomjs \
		/usr/share/grafana/tools/phantomjs/phantomjs

	diropts -o grafana -g grafana -m 0750
	keepdir /var/{lib,log}/grafana
	keepdir /var/lib/grafana/{dashboards,plugins}
}

pkg_postinst() {
	if [ ! -e "${EROOT%/}"/etc/grafana/grafana.ini ]; then
		elog "No grafana.ini found, copying the example over"
		cp "${EROOT%/}"/etc/grafana/grafana.ini{.example,} || die
	else
		elog "grafana.ini found, please check example file for possible changes"
	fi
	einfo
	elog "${PN} has built-in log rotation. Please see [log.file] section of"
	elog "${EROOT%/}/etc/grafana/grafana.ini for related settings."
	einfo
	elog "You may add your own custom configuration for app-admin/logrotate if you"
	elog "wish to use external rotation of logs. In this case, you also need to make"
	elog "sure the built-in rotation is turned off."
	einfo
}
