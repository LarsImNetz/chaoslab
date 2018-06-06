# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="github.com/caarlos0/${PN}"
# Note: Keep EGO_VENDOR in sync with Gopkg.lock
EGO_VENDOR=(
	"github.com/pierrre/gotestcover 924dca7"
	"github.com/alecthomas/kingpin 1087e65"
	"github.com/alecthomas/template a0175ee"
	"github.com/alecthomas/units 2efee85"
	"github.com/beorn7/perks 4c0e845"
	"github.com/golang/protobuf 130e6b0"
	"github.com/masterminds/semver 517734c"
	"github.com/matttproud/golang_protobuf_extensions 3247c84"
	"github.com/pkg/errors 645ef00"
	"github.com/prometheus/client_golang c5b7fcc"
	"github.com/prometheus/client_model 6f38060"
	"github.com/prometheus/common 2f17f4a"
	"github.com/prometheus/procfs e645f4e"
	"github.com/sirupsen/logrus f006c2a"
	"golang.org/x/crypto 9419663 github.com/golang/crypto"
	"golang.org/x/sys 314a259 github.com/golang/sys"
	"gopkg.in/alecthomas/kingpin.v2 1087e65 github.com/alecthomas/kingpin"
)

inherit golang-vcs-snapshot systemd user

DESCRIPTION="Exports the expiration time of your domains as prometheus metrics"
HOMEPAGE="https://github.com/caarlos0/version_exporter"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${EGO_VENDOR_URI}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="pie test"

DOCS=( README.md )
QA_PRESTRIPPED="usr/bin/version_exporter"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_setup() {
	enewgroup version_exporter
	enewuser version_exporter -1 -1 -1 version_exporter
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
		-ldflags "-s -w -X main.version=${PV}"
	)
	go build "${mygoargs[@]}" || die

	if use test; then
		go install ./vendor/github.com/pierrre/gotestcover || die
	fi
}

src_test() {
	local PATH="${S}/bin:$PATH"
	default
}

src_install() {
	dobin version_exporter
	einstalldocs

	newinitd "${FILESDIR}/${PN}.initd" "${PN}"
	newconfd "${FILESDIR}/${PN}.confd" "${PN}"
	systemd_dounit "${FILESDIR}/${PN}.service"

	diropts -o version_exporter -g version_exporter -m 0750
	keepdir /var/log/version_exporter
}
