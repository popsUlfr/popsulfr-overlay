# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/luvcview/luvcview-0.2.6.ebuild,v 1.1 2011/03/28 03:25:17 ssuominen Exp $

EAPI=2
inherit eutils toolchain-funcs

PATCH_LEVEL=4

DESCRIPTION="USB Video Class grabber"
HOMEPAGE="http://packages.qa.debian.org/l/luvcview.html"
SRC_URI="mirror://debian/pool/main/l/${PN}/${PN}_${PV}.orig.tar.gz
	mirror://debian/pool/main/l/${PN}/${PN}_${PV}-${PATCH_LEVEL}.diff.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-libs/libsdl
	media-libs/libv4l"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/sdl-multilib.patch
	EPATCH_OPTS="-p1" epatch "${WORKDIR}"/${PN}_${PV}-${PATCH_LEVEL}.diff
	EPATCH_FORCE=yes EPATCH_SUFFIX=patch epatch debian/patches
	sed -i -e 's:videodev.h:videodev2.h:' *.{c,h} || die
	sed -i -e 's:-O2::' Makefile || die
	sed -i 's|-I\$(SDLFLAGS)|\$(SDLFLAGS)|' Makefile || die
}

src_compile() {
	emake CC="$(tc-getCC) ${LDFLAGS}" || die
}

src_install() {
	dobin luvcview || die
	doman debian/luvcview.1 || die
	dodoc Changelog README ToDo || die
}
