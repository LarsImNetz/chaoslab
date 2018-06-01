# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit linux-info

DESCRIPTION="A firewall for humans..."
HOMEPAGE="https://firehol.org"
SRC_URI="https://github.com/${PN}/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="doc ipv6 ipset qos"

RDEPEND="net-firewall/iptables
	sys-apps/iproute2[-minimal,ipv6?]
	net-misc/iputils[ipv6?]
	net-misc/iprange
	net-analyzer/traceroute
	virtual/modutils
	app-arch/gzip
	ipset? ( net-firewall/ipset )"
DEPEND="${RDEPEND}"

pkg_setup() {
	local KCONFIG_OPTS=" \
		~IP_NF_FILTER \
		~IP_NF_IPTABLES \
		~IP_NF_MANGLE \
		~IP_NF_TARGET_MASQUERADE
		~IP_NF_TARGET_REDIRECT \
		~IP_NF_TARGET_REJECT \
		~NETFILTER_XT_MATCH_LIMIT \
		~NETFILTER_XT_MATCH_OWNER \
		~NETFILTER_XT_MATCH_STATE \
		~NF_CONNTRACK \
		~NF_CONNTRACK_IPV4 \
		~NF_CONNTRACK_MARK \
		~NF_NAT \
		~NF_NAT_FTP \
		~NF_NAT_IRC \
	"

	if use qos; then
		KCONFIG_OPTS+=" \
			~IFB \
			~NET_SCH_HTB \
			~NET_SCH_FQ_CODEL \
			~NET_SCH_INGRESS \
			~NET_CLS_U32 \
			~NET_CLS_ACT \
			~NET_ACT_MIRRED \
			~NET_CLS_IND \
			~NETFILTER_XT_TARGET_CLASSIFY \
		"
	fi

	CONFIG_CHECK="${KCONFIG_OPTS}"
	linux-info_pkg_setup
}

src_configure() {
	# shellcheck disable=SC2207
	myeconf=(
		--disable-vnetbuild
		$(use_enable ipset update-ipsets)
		$(use_enable doc)
		$(use_enable ipv6)
		$(use_enable qos fireqos)
	)
	econf "${myeconf[@]}"
}

src_install() {
	default

	newconfd "${FILESDIR}"/firehol.confd firehol
	newinitd "${FILESDIR}"/firehol.initd firehol

	if use qos; then
		newconfd "${FILESDIR}"/fireqos.confd fireqos
		newinitd "${FILESDIR}"/fireqos.initd fireqos
	fi
}
