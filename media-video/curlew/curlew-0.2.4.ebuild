# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Easy to use and Free Multimedia Converter for Linux"
HOMEPAGE="https://github.com/chamfay/Curlew"
SRC_URI="https://github.com/chamfay/Curlew/archive/v${PV}.tar.gz -> ${P}.tar.gz"
RESTRICT="mirror"

LICENSE="Waqf-GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="curl"

DEPEND="dev-util/intltool"
RDEPEND="curl? ( net-misc/curl )
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/pyxdg[${PYTHON_USEDEP}]
	gnome-base/librsvg
	media-libs/gstreamer:1.0[introspection]
	media-video/mediainfo
	virtual/ffmpeg[encode,mp3]
	x11-misc/xdg-utils"

S="${WORKDIR}/Curlew-${PV}"
