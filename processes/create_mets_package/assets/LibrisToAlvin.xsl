<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="xs marc">
	<xsl:include href="MARC21slimUtils.xsl"/>
	<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes" media-type="text/xml"/>
	<!-- sigel = Libris-sigel -->
	<xsl:variable name="sigel">G</xsl:variable>
	<!-- fulltexturl sätter URL till fulltext-filen -->
	<xsl:variable name="fulltexturl">
		<xsl:text>http://www.ub.uu.se/</xsl:text>
	</xsl:variable>
	<!-- fulltextformat sätter filändelse till fulltext-filen -->
	<xsl:variable name="fulltextformat">
		<xsl:text>.pdf</xsl:text>
	</xsl:variable>
	<xsl:template match="/">
		<modsCollection xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
			<xsl:apply-templates select="xsearch"/>
		</modsCollection>
	</xsl:template>
	<xsl:template match="xsearch">
		<xsl:apply-templates select="marc:collection"/>
	</xsl:template>
	<xsl:template match="marc:collection">
		<xsl:apply-templates select="marc:record"/>
	</xsl:template>
	<xsl:template match="marc:record">
		<!-- fulltext sätter parameter för länk till fulltextfilen -->
		<!-- <xsl:variable name="fulltext" select="marc:controlfield[@tag = '001']"/>-->
		<xsl:variable name="fulltext">0</xsl:variable>
		<!-- Leader till Alvin -->
		<xsl:variable name="leader" select="marc:leader"/>
		<xsl:variable name="leader6" select="substring($leader,7,1)"/>
		<xsl:variable name="leader7" select="substring($leader,8,1)"/>
		<xsl:variable name="leader19" select="substring($leader,20,1)"/>
		<xsl:variable name="controlField008" select="marc:controlfield[@tag='008']"/>
		<xsl:variable name="typeOf008">
			<xsl:choose>
				<xsl:when test="$leader6='a'">
					<xsl:choose>
						<xsl:when test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">BK</xsl:when>
						<xsl:when test="$leader7='b' or $leader7='i' or $leader7='s'">SE</xsl:when>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$leader6='t'">BK</xsl:when>
				<xsl:when test="$leader6='p'">MM</xsl:when>
				<xsl:when test="$leader6='m'">CF</xsl:when>
				<xsl:when test="$leader6='e' or $leader6='f'">MP</xsl:when>
				<xsl:when test="$leader6='g' or $leader6='k' or $leader6='o' or $leader6='r'">VM</xsl:when>
				<xsl:when test="$leader6='c' or $leader6='d' or $leader6='i' or $leader6='j'">MU</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-4.xsd">
			<!-- Alvin publikationstyper = marcgt -->
			<!-- Om monografi -->
			<xsl:if test="$leader7='a' or $leader7='c' or $leader7='d' or $leader7='m'">
				<genre authority="marcgt">book</genre>
			</xsl:if>
			<xsl:if test="substring($controlField008,26,1)='d'">
				<genre authority="marcgt">globe</genre>
			</xsl:if>
			<xsl:if test="marc:controlfield[@tag='007'][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
				<genre authority="marcgt">remote-sensing image</genre>
			</xsl:if>
			<xsl:if test="$typeOf008='MP'">
				<xsl:variable name="controlField008-25" select="substring($controlField008,26,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-25='a' or $controlField008-25='b' or $controlField008-25='c' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
						<genre authority="marcgt">map</genre>
					</xsl:when>
					<xsl:when test="$controlField008-25='e' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
						<genre authority="marcgt">atlas</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$typeOf008='SE'">
				<xsl:variable name="controlField008-21" select="substring($controlField008,22,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-21='d'">
						<genre authority="marcgt">database</genre>
					</xsl:when>
					<xsl:when test="$controlField008-21='l'">
						<genre authority="marcgt">loose-leaf</genre>
					</xsl:when>
					<xsl:when test="$controlField008-21='m'">
						<genre authority="marcgt">series</genre>
					</xsl:when>
					<xsl:when test="$controlField008-21='n'">
						<genre authority="marcgt">newspaper</genre>
					</xsl:when>
					<xsl:when test="$controlField008-21='p'">
						<genre authority="marcgt">periodical</genre>
					</xsl:when>
					<xsl:when test="$controlField008-21='w'">
						<genre authority="marcgt">web site</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$typeOf008='BK' or $typeOf008='SE'">
				<xsl:variable name="controlField008-24" select="substring($controlField008,25,4)"/>
				<xsl:choose>
					<xsl:when test="contains($controlField008-24,'a')">
						<genre authority="marcgt">abstract or summary</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'b')">
						<genre authority="marcgt">bibliography</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'c')">
						<genre authority="marcgt">catalog</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'d')">
						<genre authority="marcgt">dictionary</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'e')">
						<genre authority="marcgt">encyclopedia</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'f')">
						<genre authority="marcgt">handbook</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'g')">
						<genre authority="marcgt">legal article</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'i')">
						<genre authority="marcgt">index</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'k')">
						<genre authority="marcgt">discography</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'l')">
						<genre authority="marcgt">legislation</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'m')">
						<genre authority="marcgt">theses</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'n')">
						<genre authority="marcgt">survey of literature</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'o')">
						<genre authority="marcgt">review</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'p')">
						<genre authority="marcgt">programmed text</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'q')">
						<genre authority="marcgt">filmography</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'r')">
						<genre authority="marcgt">directory</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'s')">
						<genre authority="marcgt">statistics</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'t')">
						<genre authority="marcgt">technical report</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'v')">
						<genre authority="marcgt">legal case and case notes</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'w')">
						<genre authority="marcgt">law report or digest</genre>
					</xsl:when>
					<xsl:when test="contains($controlField008-24,'z')">
						<genre authority="marcgt">treaty</genre>
					</xsl:when>
				</xsl:choose>
				<xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-29='1'">
						<genre authority="marcgt">conference publication</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$typeOf008='CF'">
				<xsl:variable name="controlField008-26" select="substring($controlField008,27,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-26='a'">
						<genre authority="marcgt">numeric data</genre>
					</xsl:when>
					<xsl:when test="$controlField008-26='e'">
						<genre authority="marcgt">database</genre>
					</xsl:when>
					<xsl:when test="$controlField008-26='f'">
						<genre authority="marcgt">font</genre>
					</xsl:when>
					<xsl:when test="$controlField008-26='g'">
						<genre authority="marcgt">game</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$typeOf008='BK'">
				<xsl:if test="substring($controlField008,25,1)='j'">
					<genre authority="marcgt">patent</genre>
				</xsl:if>
				<xsl:if test="substring($controlField008,25,1)='2'">
					<genre authority="marcgt">offprint</genre>
				</xsl:if>
				<xsl:if test="substring($controlField008,31,1)='1'">
					<genre authority="marcgt">festschrift</genre>
				</xsl:if>
				<xsl:variable name="controlField008-34" select="substring($controlField008,35,1)"/>
				<xsl:if test="$controlField008-34='a' or $controlField008-34='b' or $controlField008-34='c' or $controlField008-34='d'">
					<genre authority="marcgt">biography</genre>
				</xsl:if>
				<xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-33='e'">
						<genre authority="marcgt">essay</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='d'">
						<genre authority="marcgt">drama</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='c'">
						<genre authority="marcgt">comic strip</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='l'">
						<genre authority="marcgt">fiction</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='h'">
						<genre authority="marcgt">humor, satire</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='i'">
						<genre authority="marcgt">letter</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='f'">
						<genre authority="marcgt">novel</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='j'">
						<genre authority="marcgt">short story</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='s'">
						<genre authority="marcgt">speech</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="$typeOf008='MU'">
				<xsl:variable name="controlField008-30-31" select="substring($controlField008,31,2)"/>
				<xsl:if test="contains($controlField008-30-31,'b')">
					<genre authority="marcgt">biography</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'c')">
					<genre authority="marcgt">conference publication</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'d')">
					<genre authority="marcgt">drama</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'e')">
					<genre authority="marcgt">essay</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'f')">
					<genre authority="marcgt">fiction</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'o')">
					<genre authority="marcgt">folktale</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'h')">
					<genre authority="marcgt">history</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'k')">
					<genre authority="marcgt">humor, satire</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'m')">
					<genre authority="marcgt">memoir</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'p')">
					<genre authority="marcgt">poetry</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'r')">
					<genre authority="marcgt">rehearsal</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'g')">
					<genre authority="marcgt">reporting</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'s')">
					<genre authority="marcgt">sound</genre>
				</xsl:if>
				<xsl:if test="contains($controlField008-30-31,'l')">
					<genre authority="marcgt">speech</genre>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$typeOf008='VM'">
				<xsl:variable name="controlField008-33" select="substring($controlField008,34,1)"/>
				<xsl:choose>
					<xsl:when test="$controlField008-33='a'">
						<genre authority="marcgt">art original</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='b'">
						<genre authority="marcgt">kit</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='c'">
						<genre authority="marcgt">art reproduction</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='d'">
						<genre authority="marcgt">diorama</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='f'">
						<genre authority="marcgt">filmstrip</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='g'">
						<genre authority="marcgt">legal article</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='i'">
						<genre authority="marcgt">picture</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='k'">
						<genre authority="marcgt">graphic</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='l'">
						<genre authority="marcgt">technical drawing</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='m'">
						<genre authority="marcgt">motion picture</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='n'">
						<genre authority="marcgt">chart</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='o'">
						<genre authority="marcgt">flash card</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='p'">
						<genre authority="marcgt">microscope slide</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='q' or marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
						<genre authority="marcgt">model</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='r'">
						<genre authority="marcgt">realia</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='s'">
						<genre authority="marcgt">slide</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='t'">
						<genre authority="marcgt">transparency</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='v'">
						<genre authority="marcgt">videorecording</genre>
					</xsl:when>
					<xsl:when test="$controlField008-33='w'">
						<genre authority="marcgt">toy</genre>
					</xsl:when>
				</xsl:choose>
			</xsl:if>
			<!-- Resurstyp -->
			<xsl:element name="typeOfResource">
				<xsl:if test="$leader7='c'">
					<xsl:attribute name="collection">yes</xsl:attribute>
				</xsl:if>
				<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
					<xsl:attribute name="manuscript">yes</xsl:attribute>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$leader6='a' or $leader6='t'">text</xsl:when>
					<xsl:when test="$leader6='e' or $leader6='f'">cartographic</xsl:when>
					<xsl:when test="$leader6='c' or $leader6='d'">notated music</xsl:when>
					<xsl:when test="$leader6='i'">sound recording-nonmusical</xsl:when>
					<xsl:when test="$leader6='j'">sound recording-musical</xsl:when>
					<xsl:when test="$leader6='k'">still image</xsl:when>
					<xsl:when test="$leader6='g'">moving image</xsl:when>
					<xsl:when test="$leader6='r'">three dimensional object</xsl:when>
					<xsl:when test="$leader6='m'">software, multimedia</xsl:when>
					<xsl:when test="$leader6='p'">mixed material</xsl:when>
				</xsl:choose>
			</xsl:element>
			<!-- Person -->
			<xsl:apply-templates select="marc:datafield[@tag = '100']|marc:datafield[@tag = '700']"/>
			<!-- Institution -->
			<xsl:for-each select="marc:datafield[@tag='110']">
				<xsl:call-template name="createNameFrom110"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='710']">
				<xsl:call-template name="createNameFrom710"/>
			</xsl:for-each>
			<!-- Konferens -->
			<xsl:for-each select="marc:datafield[@tag='111']">
				<xsl:call-template name="createNameFrom111"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='711']">
				<xsl:call-template name="createNameFrom711"/>
			</xsl:for-each>
			<!-- Titel -->
			<!-- titleInfo -->
			<xsl:for-each select="marc:datafield[@tag='245']">
				<xsl:call-template name="createTitleInfoFrom245"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='210']">
				<xsl:call-template name="createTitleInfoFrom210"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='246']">
				<xsl:call-template name="createTitleInfoFrom246"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='240']">
				<xsl:call-template name="createTitleInfoFrom240"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='740']">
				<xsl:call-template name="createTitleInfoFrom740"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='130']">
				<xsl:call-template name="createTitleInfoFrom130"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag='730']">
				<xsl:call-template name="createTitleInfoFrom730"/>
			</xsl:for-each>
			<!-- Utgivningsinformation -->
			<!-- originInfo 250 and 260 -->
			<originInfo>
				<xsl:for-each select="marc:datafield[(@tag=260 or @tag=250) and marc:subfield[@code='a' or code='b' or @code='c' or code='g']]">
					<xsl:call-template name="z2xx880"/>
				</xsl:for-each>
				<xsl:variable name="MARCpublicationCode" select="normalize-space(substring($controlField008,16,3))"/>
				<xsl:if test="translate($MARCpublicationCode,'|','')">
					<place>
						<placeTerm>
							<xsl:attribute name="type">code</xsl:attribute>
							<xsl:attribute name="authority">marccountry</xsl:attribute>
							<xsl:value-of select="$MARCpublicationCode"/>
						</placeTerm>
					</place>
				</xsl:if>
				<xsl:for-each select="marc:datafield[@tag=044]/marc:subfield[@code='c']">
					<place>
						<placeTerm>
							<xsl:attribute name="type">code</xsl:attribute>
							<xsl:attribute name="authority">iso3166</xsl:attribute>
							<xsl:value-of select="."/>
						</placeTerm>
					</place>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='a']">
					<place>
						<placeTerm>
							<xsl:attribute name="type">text</xsl:attribute>
							<xsl:call-template name="chopPunctuationFront">
								<xsl:with-param name="chopString">
									<xsl:call-template name="chopPunctuation">
										<xsl:with-param name="chopString" select="."/>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</placeTerm>
					</place>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=752]/marc:subfield[@code='d']">
					<place>
						<placeTerm>
							<xsl:attribute name="type"><xsl:text>text</xsl:text></xsl:attribute>
							<xsl:attribute name="lang"><xsl:text>swe</xsl:text></xsl:attribute>
							<xsl:value-of select="."/>
						</placeTerm>
					</place>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='m']">
					<dateValid point="start">
						<xsl:value-of select="."/>
					</dateValid>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='n']">
					<dateValid point="end">
						<xsl:value-of select="."/>
					</dateValid>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='j']">
					<dateModified>
						<xsl:value-of select="."/>
					</dateModified>
				</xsl:for-each>
				<!-- tmee 1.52 -->
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='c']">
					<dateIssued encoding="marc" point="start">
						<xsl:value-of select="."/>
					</dateIssued>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='e']">
					<dateIssued encoding="marc" point="end">
						<xsl:value-of select="."/>
					</dateIssued>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='k']">
					<dateCreated encoding="marc" point="start">
						<xsl:value-of select="."/>
					</dateCreated>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=046]/marc:subfield[@code='l']">
					<dateCreated encoding="marc" point="end">
						<xsl:value-of select="."/>
					</dateCreated>
				</xsl:for-each>
				<!-- tmee 1.35 1.36 dateIssued/nonMSS vs dateCreated/MSS -->
				<xsl:for-each select="marc:datafield[@tag=260]/marc:subfield[@code='b' or @code='c' or @code='g']">
					<xsl:choose>
						<xsl:when test="@code='b'">
							<publisher>
								<xsl:call-template name="chopPunctuation">
									<xsl:with-param name="chopString" select="."/>
									<xsl:with-param name="punctuation">
										<xsl:text>:,;/ </xsl:text>
									</xsl:with-param>
								</xsl:call-template>
							</publisher>
						</xsl:when>
						<xsl:when test="(@code='c')">
							<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
								<dateCreated>
									<xsl:call-template name="chopPunctuation">
										<xsl:with-param name="chopString" select="."/>
									</xsl:call-template>
								</dateCreated>
							</xsl:if>
							<xsl:if test="not($leader6='d' or $leader6='f' or $leader6='p' or $leader6='t')">
								<dateIssued>
									<xsl:call-template name="chopPunctuation">
										<xsl:with-param name="chopString" select="."/>
									</xsl:call-template>
								</dateIssued>
							</xsl:if>
						</xsl:when>
						<xsl:when test="@code='g'">
							<xsl:if test="$leader6='d' or $leader6='f' or $leader6='p' or $leader6='t'">
								<dateCreated>
									<xsl:value-of select="."/>
								</dateCreated>
							</xsl:if>
							<xsl:if test="not($leader6='d' or $leader6='f' or $leader6='p' or $leader6='t')">
								<dateCreated>
									<xsl:value-of select="."/>
								</dateCreated>
							</xsl:if>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				<xsl:variable name="dataField260c">
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString" select="marc:datafield[@tag=260]/marc:subfield[@code='c']"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="controlField008-7-10" select="normalize-space(substring($controlField008, 8, 4))"/>
				<xsl:variable name="controlField008-11-14" select="normalize-space(substring($controlField008, 12, 4))"/>
				<xsl:variable name="controlField008-6" select="normalize-space(substring($controlField008, 7, 1))"/>
				<!-- tmee 1.35 and 1.36 -->
				<xsl:if test="($controlField008-6='e' or $controlField008-6='p' or $controlField008-6='r' or $controlField008-6='s' or $controlField008-6='t') and ($leader6='d' or $leader6='f' or $leader6='p' or $leader6='t')">
					<xsl:if test="$controlField008-7-10 and ($controlField008-7-10 != $dataField260c)">
						<dateCreated encoding="marc">
							<xsl:value-of select="concat($controlField008-7-10, $controlField008-11-14)"/>
						</dateCreated>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='u'">
					<xsl:if test="$controlField008-7-10">
						<dateIssued encoding="marc" point="start">
							<xsl:value-of select="$controlField008-7-10"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$controlField008-6='c' or $controlField008-6='d' or $controlField008-6='i' or $controlField008-6='k' or $controlField008-6='m' or $controlField008-6='u'">
					<xsl:if test="$controlField008-11-14">
						<dateIssued encoding="marc" point="end">
							<xsl:value-of select="$controlField008-11-14"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$controlField008-6='q'">
					<xsl:if test="$controlField008-7-10">
						<dateIssued encoding="marc" point="start" qualifier="questionable">
							<xsl:value-of select="$controlField008-7-10"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$controlField008-6='q'">
					<xsl:if test="$controlField008-11-14">
						<dateIssued encoding="marc" point="end" qualifier="questionable">
							<xsl:value-of select="$controlField008-11-14"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
				<!-- tmee 1.77 008-06 dateIssued for value 's' -->
				<xsl:if test="$controlField008-6='s'">
					<xsl:if test="$controlField008-7-10">
						<dateIssued encoding="marc">
							<xsl:value-of select="$controlField008-7-10"/>
						</dateIssued>
					</xsl:if>
				</xsl:if>
				<xsl:if test="$controlField008-6='t'">
					<xsl:if test="$controlField008-11-14">
						<copyrightDate encoding="marc">
							<xsl:value-of select="$controlField008-11-14"/>
						</copyrightDate>
					</xsl:if>
				</xsl:if>
				<xsl:for-each select="marc:datafield[@tag=033][@ind1=0 or @ind1=1]/marc:subfield[@code='a']">
					<dateCaptured encoding="iso8601">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=033][@ind1=2]/marc:subfield[@code='a'][1]">
					<dateCaptured encoding="iso8601" point="start">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=033][@ind1=2]/marc:subfield[@code='a'][2]">
					<dateCaptured encoding="iso8601" point="end">
						<xsl:value-of select="."/>
					</dateCaptured>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=250]/marc:subfield[@code='a']">
					<edition>
						<xsl:value-of select="."/>
					</edition>
				</xsl:for-each>
			</originInfo>
			<!-- language 041 -->
			<xsl:variable name="controlField008-35-37" select="normalize-space(translate(substring($controlField008,36,3),'|#',''))"/>
			<xsl:if test="$controlField008-35-37">
				<language>
					<languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="substring($controlField008,36,3)"/>
					</languageTerm>
				</language>
			</xsl:if>
			<xsl:for-each select="marc:datafield[@tag=041]">
				<xsl:for-each select="marc:subfield[@code='a' or @code='b' or @code='d' or @code='e' or @code='f' or @code='g' or @code='h']">
					<xsl:variable name="langCodes" select="."/>
					<xsl:choose>
						<xsl:when test="../marc:subfield[@code='2']='rfc3066'">
							<!-- not stacked but could be repeated -->
							<xsl:call-template name="rfcLanguages">
								<xsl:with-param name="nodeNum">
									<xsl:value-of select="1"/>
								</xsl:with-param>
								<xsl:with-param name="usedLanguages">
									<xsl:text/>
								</xsl:with-param>
								<xsl:with-param name="controlField008-35-37">
									<xsl:value-of select="$controlField008-35-37"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- iso -->
							<xsl:variable name="allLanguages">
								<xsl:copy-of select="$langCodes"/>
							</xsl:variable>
							<xsl:variable name="currentLanguage">
								<xsl:value-of select="substring($allLanguages,1,3)"/>
							</xsl:variable>
							<xsl:call-template name="isoLanguage">
								<xsl:with-param name="currentLanguage">
									<xsl:value-of select="substring($allLanguages,1,3)"/>
								</xsl:with-param>
								<xsl:with-param name="remainingLanguages">
									<xsl:value-of select="substring($allLanguages,4,string-length($allLanguages)-3)"/>
								</xsl:with-param>
								<xsl:with-param name="usedLanguages">
									<xsl:if test="$controlField008-35-37">
										<xsl:value-of select="$controlField008-35-37"/>
									</xsl:if>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</xsl:for-each>
			<!-- physicalDescription -->
			<xsl:variable name="physicalDescription">
				<!--3.2 change tmee 007/11 -->
				<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='a']">
					<digitalOrigin>reformatted digital</digitalOrigin>
				</xsl:if>
				<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='b']">
					<digitalOrigin>digitized microfilm</digitalOrigin>
				</xsl:if>
				<xsl:if test="$typeOf008='CF' and marc:controlfield[@tag=007][substring(.,12,1)='d']">
					<digitalOrigin>digitized other analog</digitalOrigin>
				</xsl:if>
				<xsl:variable name="controlField008-23" select="substring($controlField008,24,1)"/>
				<xsl:variable name="controlField008-29" select="substring($controlField008,30,1)"/>
				<xsl:variable name="check008-23">
					<xsl:if test="$typeOf008='BK' or $typeOf008='MU' or $typeOf008='SE' or $typeOf008='MM'">
						<xsl:value-of select="true()"/>
					</xsl:if>
				</xsl:variable>
				<xsl:variable name="check008-29">
					<xsl:if test="$typeOf008='MP' or $typeOf008='VM'">
						<xsl:value-of select="true()"/>
					</xsl:if>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="($check008-23 and $controlField008-23='f') or ($check008-29 and $controlField008-29='f')">
						<form authority="marcform">braille</form>
					</xsl:when>
					<xsl:when test="($controlField008-23=' ' and ($leader6='c' or $leader6='d')) or (($typeOf008='BK' or $typeOf008='SE') and ($controlField008-23=' ' or $controlField008='r'))">
						<form authority="marcform">print</form>
					</xsl:when>
					<xsl:when test="$leader6 = 'm' or ($check008-23 and $controlField008-23='s') or ($check008-29 and $controlField008-29='s')">
						<form authority="marcform">electronic</form>
					</xsl:when>
					<!-- 1.33 -->
					<xsl:when test="$leader6 = 'o'">
						<form authority="marcform">kit</form>
					</xsl:when>
					<xsl:when test="($check008-23 and $controlField008-23='b') or ($check008-29 and $controlField008-29='b')">
						<form authority="marcform">microfiche</form>
					</xsl:when>
					<xsl:when test="($check008-23 and $controlField008-23='a') or ($check008-29 and $controlField008-29='a')">
						<form authority="marcform">microfilm</form>
					</xsl:when>
				</xsl:choose>
				<!-- 1/04 fix -->
				<xsl:if test="marc:datafield[@tag=130]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=130]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:if test="marc:datafield[@tag=240]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=240]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:if test="marc:datafield[@tag=242]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=242]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:if test="marc:datafield[@tag=245]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=245]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:if test="marc:datafield[@tag=246]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=246]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:if test="marc:datafield[@tag=730]/marc:subfield[@code='h']">
					<form authority="gmd">
						<xsl:call-template name="chopBrackets">
							<xsl:with-param name="chopString">
								<xsl:value-of select="marc:datafield[@tag=730]/marc:subfield[@code='h']"/>
							</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:if>
				<xsl:for-each select="marc:datafield[@tag=256]/marc:subfield[@code='a']">
					<form>
						<xsl:value-of select="."/>
					</form>
				</xsl:for-each>
				<xsl:for-each select="marc:controlfield[@tag=007][substring(text(),1,1)='c']">
					<xsl:choose>
						<xsl:when test="substring(text(),14,1)='a'">
							<reformattingQuality>access</reformattingQuality>
						</xsl:when>
						<xsl:when test="substring(text(),14,1)='p'">
							<reformattingQuality>preservation</reformattingQuality>
						</xsl:when>
						<xsl:when test="substring(text(),14,1)='r'">
							<reformattingQuality>replacement</reformattingQuality>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				<!--3.2 change tmee 007/01 -->
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='b']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">chip cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='c']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">computer optical disc cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='j']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">magnetic disc</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='m']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">magneto-optical disc</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='o']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">optical disc</form>
				</xsl:if>
				<!-- 1.38 AQ 1.29 tmee 	1.66 added marccategory and marcsmd as part of 3.4 -->
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='r']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">remote</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='a']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">tape cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='f']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">tape cassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='c'][substring(text(),2,1)='h']">
					<form authority="marccategory">electronic resource</form>
					<form authority="marcsmd">tape reel</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='a']">
					<form authority="marccategory">globe</form>
					<form authority="marcsmd">celestial globe</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='e']">
					<form authority="marccategory">globe</form>
					<form authority="marcsmd">earth moon globe</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='b']">
					<form authority="marccategory">globe</form>
					<form authority="marcsmd">planetary or lunar globe</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='d'][substring(text(),2,1)='c']">
					<form authority="marccategory">globe</form>
					<form authority="marcsmd">terrestrial globe</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='o'][substring(text(),2,1)='o']">
					<form authority="marccategory">kit</form>
					<form authority="marcsmd">kit</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='d']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">atlas</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='g']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">diagram</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='j']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">map</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='q']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">model</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='k']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">profile</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='r']">
					<form authority="marcsmd">remote-sensing image</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='s']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">section</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='a'][substring(text(),2,1)='y']">
					<form authority="marccategory">map</form>
					<form authority="marcsmd">view</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='a']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">aperture card</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='e']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microfiche</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='f']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microfiche cassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='b']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microfilm cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='c']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microfilm cassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='d']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microfilm reel</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='h'][substring(text(),2,1)='g']">
					<form authority="marccategory">microform</form>
					<form authority="marcsmd">microopaque</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='c']">
					<form authority="marccategory">motion picture</form>
					<form authority="marcsmd">film cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='f']">
					<form authority="marccategory">motion picture</form>
					<form authority="marcsmd">film cassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='m'][substring(text(),2,1)='r']">
					<form authority="marccategory">motion picture</form>
					<form authority="marcsmd">film reel</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='n']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">chart</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='c']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">collage</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='d']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">drawing</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='o']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">flash card</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='e']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">painting</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='f']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">photomechanical print</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='g']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">photonegative</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='h']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">photoprint</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='i']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">picture</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='j']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">print</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='k'][substring(text(),2,1)='l']">
					<form authority="marccategory">nonprojected graphic</form>
					<form authority="marcsmd">technical drawing</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='q'][substring(text(),2,1)='q']">
					<form authority="marccategory">notated music</form>
					<form authority="marcsmd">notated music</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='d']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">filmslip</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='c']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">filmstrip cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='o']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">filmstrip roll</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='f']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">other filmstrip type</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='s']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">slide</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='g'][substring(text(),2,1)='t']">
					<form authority="marccategory">projected graphic</form>
					<form authority="marcsmd">transparency</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='r'][substring(text(),2,1)='r']">
					<form authority="marccategory">remote-sensing image</form>
					<form authority="marcsmd">remote-sensing image</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='e']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">cylinder</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='q']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">roll</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='g']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">sound cartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='s']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">sound cassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='d']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">sound disc</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='t']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">sound-tape reel</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='i']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">sound-track film</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='s'][substring(text(),2,1)='w']">
					<form authority="marccategory">sound recording</form>
					<form authority="marcsmd">wire recording</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='c']">
					<form authority="marccategory">tactile material</form>
					<form authority="marcsmd">braille</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='b']">
					<form authority="marccategory">tactile material</form>
					<form authority="marcsmd">combination</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='a']">
					<form authority="marccategory">tactile material</form>
					<form authority="marcsmd">moon</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='f'][substring(text(),2,1)='d']">
					<form authority="marccategory">tactile material</form>
					<form authority="marcsmd">tactile, with no writing system</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='c']">
					<form authority="marccategory">text</form>
					<form authority="marcsmd">braille</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='b']">
					<form authority="marccategory">text</form>
					<form authority="marcsmd">large print</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='a']">
					<form authority="marccategory">text</form>
					<form authority="marcsmd">regular print</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='t'][substring(text(),2,1)='d']">
					<form authority="marccategory">text</form>
					<form authority="marcsmd">text in looseleaf binder</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='c']">
					<form authority="marccategory">videorecording</form>
					<form authority="marcsmd">videocartridge</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='f']">
					<form authority="marccategory">videorecording</form>
					<form authority="marcsmd">videocassette</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='d']">
					<form authority="marccategory">videorecording</form>
					<form authority="marcsmd">videodisc</form>
				</xsl:if>
				<xsl:if test="marc:controlfield[@tag=007][substring(text(),1,1)='v'][substring(text(),2,1)='r']">
					<form authority="marccategory">videorecording</form>
					<form authority="marcsmd">videoreel</form>
				</xsl:if>
				<xsl:for-each select="marc:datafield[@tag=856]/marc:subfield[@code='q'][string-length(.)&gt;1]">
					<internetMediaType>
						<xsl:value-of select="."/>
					</internetMediaType>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=300]">
					<extent>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abce3fg</xsl:with-param>
						</xsl:call-template>
					</extent>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=337]">
					<form type="media">
						<xsl:attribute name="authority"><xsl:value-of select="marc:subfield[@code=2]"/></xsl:attribute>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:for-each>
				<xsl:for-each select="marc:datafield[@tag=338]">
					<form type="carrier">
						<xsl:attribute name="authority"><xsl:value-of select="marc:subfield[@code=2]"/></xsl:attribute>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</form>
				</xsl:for-each>
				<!-- 1.43 tmee 351 $3$a$b$c-->
				<xsl:for-each select="marc:datafield[@tag=351]">
					<note type="arrangement">
						<xsl:for-each select="marc:subfield[@code='3']">
							<xsl:value-of select="."/>
							<xsl:text>: </xsl:text>
						</xsl:for-each>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abc</xsl:with-param>
						</xsl:call-template>
					</note>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="string-length(normalize-space($physicalDescription))">
				<xsl:element name="physicalDescription">
					<!-- Sidor -->
					<xsl:for-each select="marc:datafield[@tag = '300']/marc:subfield[@code = 'a']">
						<xsl:element name="note">
							<xsl:attribute name="type"><xsl:text>extent</xsl:text></xsl:attribute>
							<xsl:choose>
								<xsl:when test="contains(.,'s.')">
									<xsl:value-of select="substring-before(.,' s.')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:for-each>
					<!-- Sidor -->
					<xsl:for-each select="marc:datafield[@tag = '300']/marc:subfield[@code = 'b']">
						<xsl:element name="note">
							<xsl:attribute name="type"><xsl:text>other</xsl:text></xsl:attribute>
							<xsl:choose>
								<xsl:when test="substring(., string-length(.)) = ';'">
									<xsl:value-of select="substring-before(.,' ;')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="."/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:for-each>
					<!-- Storlek -->
					<xsl:for-each select="marc:datafield[@tag = '300']/marc:subfield[@code = 'c']">
						<xsl:element name="note">
							<xsl:attribute name="type"><xsl:text>dimensions</xsl:text></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:datafield[@tag=300]">
						<!-- Template checks for altRepGroup - 880 $6 -->
						<xsl:call-template name="z3xx880"/>
					</xsl:for-each>
					<xsl:for-each select="marc:datafield[@tag=337]">
						<!-- Template checks for altRepGroup - 880 $6 -->
						<xsl:call-template name="xxx880"/>
					</xsl:for-each>
					<xsl:for-each select="marc:datafield[@tag=338]">
						<!-- Template checks for altRepGroup - 880 $6 -->
						<xsl:call-template name="xxx880"/>
					</xsl:for-each>
					<xsl:copy-of select="$physicalDescription"/>
				</xsl:element>
			</xsl:if>
			<!-- Serier -->
			<xsl:for-each select="marc:datafield[@tag = '440']">
				<xsl:element name="relatedItem">
					<xsl:attribute name="type"><xsl:text>series</xsl:text></xsl:attribute>
					<xsl:element name="titleInfo">
						<xsl:element name="title">
							<xsl:call-template name="chopPunctuation">
								<xsl:with-param name="chopString">
									<xsl:call-template name="subfieldSelect">
										<xsl:with-param name="codes">a</xsl:with-param>
									</xsl:call-template>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:element>
						<xsl:call-template name="part"/>
					</xsl:element>
					<xsl:for-each select="marc:subfield[@code = 'x']">
						<xsl:if test="not(starts-with(.,'99-'))">
							<xsl:element name="identifier">
								<xsl:attribute name="type"><xsl:text>issn</xsl:text></xsl:attribute>
								<xsl:choose>
									<xsl:when test="substring(., string-length(.)) = ';'">
										<xsl:value-of select="substring-before(.,' ;')"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="."/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'v']">
						<xsl:element name="identifier">
							<xsl:attribute name="type"><xsl:text>issue number</xsl:text></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:for-each>
			<!-- Identifikatorer -->
			<!-- ISBN -->
			<xsl:for-each select="marc:datafield[@tag = '020']">
				<xsl:element name="identifier">
					<xsl:attribute name="type"><xsl:text>isbn</xsl:text></xsl:attribute>
					<xsl:choose>
						<xsl:when test="contains(marc:subfield[@code = 'a'],' (')">
							<xsl:value-of select="substring-before(marc:subfield[@code = 'a'],' (')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="marc:subfield[@code = 'a']"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:for-each>
			<!-- Libris-ID -->
			<xsl:for-each select="marc:controlfield[@tag = '001']">
				<xsl:element name="identifier">
					<xsl:attribute name="type"><xsl:text>libris</xsl:text></xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:for-each>
			<!-- Ämnesord -->
			<xsl:for-each select="marc:datafield[@tag = '650']">
				<xsl:if test="not(marc:subfield[@code = '5'])">
					<xsl:for-each select="marc:subfield[@code = 'a']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="topic">
								<xsl:value-of select="."/>
								<xsl:for-each select="../marc:subfield[@code = 'x']">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="."/>
								</xsl:for-each>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'z']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="geographic">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'y']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="temporal">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<!-- Ämnesord geographic -->
			<xsl:for-each select="marc:datafield[@tag = '651']">
				<xsl:if test="not(marc:subfield[@code = '5'])">
					<xsl:for-each select="marc:subfield[@code = 'a']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="geographic">
								<xsl:value-of select="."/>
								<xsl:for-each select="../marc:subfield[@code = 'x']">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="."/>
								</xsl:for-each>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'z']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="geographic">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'y']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="temporal">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<!-- Ämnesord occupation -->
			<xsl:for-each select="marc:datafield[@tag = '656']">
				<xsl:if test="not(marc:subfield[@code = '5'])">
					<xsl:for-each select="marc:subfield[@code = 'a']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="occupation">
								<xsl:value-of select="."/>
								<xsl:for-each select="../marc:subfield[@code = 'x']">
									<xsl:text>: </xsl:text>
									<xsl:value-of select="."/>
								</xsl:for-each>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'z']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="geographic">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="marc:subfield[@code = 'y']">
						<xsl:element name="subject">
							<xsl:call-template name="subjectAuthority2"/>
							<xsl:element name="temporal">
								<xsl:value-of select="."/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
			<!-- Abstract -->
			<xsl:for-each select="marc:datafield[@tag=520]">
				<xsl:call-template name="createAbstractFrom520"/>
			</xsl:for-each>
			<!-- TOC -->
			<xsl:for-each select="marc:datafield[@tag=505]">
				<xsl:call-template name="createTOCFrom505"/>
			</xsl:for-each>
			<!-- 245c 362az 502-585 5XX-->
			<xsl:for-each select="marc:datafield[@tag=245]">
				<xsl:call-template name="createNoteFrom245c"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=362]">
				<xsl:call-template name="createNoteFrom362"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=500]">
				<xsl:if test="not(marc:subfield[@code = '5'])">
					<xsl:call-template name="createNoteFrom500"/>
				</xsl:if>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=502]">
				<xsl:call-template name="createNoteFrom502"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=504]">
				<xsl:call-template name="createNoteFrom504"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=508]">
				<xsl:call-template name="createNoteFrom508"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=511]">
				<xsl:call-template name="createNoteFrom511"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=515]">
				<xsl:call-template name="createNoteFrom515"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=518]">
				<xsl:call-template name="createNoteFrom518"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=524]">
				<xsl:call-template name="createNoteFrom524"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=530]">
				<xsl:call-template name="createNoteFrom530"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=533]">
				<xsl:call-template name="createNoteFrom533"/>
			</xsl:for-each>
			<!--
		<xsl:for-each select="marc:datafield[@tag=534]">
			<xsl:call-template name="createNoteFrom534"/>
		</xsl:for-each>
-->
			<xsl:for-each select="marc:datafield[@tag=535]">
				<xsl:call-template name="createNoteFrom535"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=536]">
				<xsl:call-template name="createNoteFrom536"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=538]">
				<xsl:call-template name="createNoteFrom538"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=541]">
				<xsl:call-template name="createNoteFrom541"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=545]">
				<xsl:call-template name="createNoteFrom545"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=546]">
				<xsl:if test="not(marc:subfield[@code = '5'])">
					<xsl:call-template name="createNoteFrom546"/>
				</xsl:if>
			</xsl:for-each>
			<!--
			<xsl:for-each select="marc:datafield[@tag=561]">
				<xsl:call-template name="createNoteFrom561"/>
			</xsl:for-each>
			-->
			<xsl:for-each select="marc:datafield[@tag=562]">
				<xsl:call-template name="createNoteFrom562"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=581]">
				<xsl:call-template name="createNoteFrom581"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=583]">
				<xsl:call-template name="createNoteFrom583"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=585]">
				<xsl:call-template name="createNoteFrom585"/>
			</xsl:for-each>
			<xsl:for-each select="marc:datafield[@tag=501 or @tag=507 or @tag=513 or @tag=514 or @tag=516 or @tag=522 or @tag=525 or @tag=526 or @tag=544 or @tag=547 or @tag=550 or @tag=552 or @tag=555 or @tag=556 or @tag=565 or @tag=567 or @tag=580 or @tag=584 or @tag=586]">
				<xsl:call-template name="createNoteFrom5XX"/>
			</xsl:for-each>
			<!-- Länk till fulltextfil -->
			<xsl:if test="$fulltext &gt; 0">
				<xsl:element name="location">
					<xsl:element name="url">
						<xsl:attribute name="displayLabel"><xsl:text>fulltext</xsl:text></xsl:attribute>
						<xsl:attribute name="note"><xsl:text>application/pdf</xsl:text></xsl:attribute>
						<xsl:value-of select="$fulltexturl"/>
						<xsl:value-of select="$fulltext"/>
						<xsl:value-of select="$fulltextformat"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!--  location  852 856 -->
			<!--	location	-->
			<xsl:for-each select="marc:datafield[@tag=852]">
				<xsl:if test="marc:subfield[@code='5'] = $sigel ">
					<xsl:call-template name="createLocationFrom852"/>
				</xsl:if>
			</xsl:for-each>
		</mods>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag = '100']|marc:datafield[@tag = '700']">
		<xsl:param name="family">
			<xsl:choose>
				<xsl:when test="@ind1 = 1">
					<xsl:value-of select="substring-before(marc:subfield[@code = 'a'],', ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(marc:subfield[@code = 'a'],' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="given">
			<xsl:choose>
				<xsl:when test="@ind1 = 1">
					<xsl:value-of select="substring-after(marc:subfield[@code = 'a'],', ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(marc:subfield[@code = 'a'],' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:element name="name" namespace="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>personal</xsl:text></xsl:attribute>
			<xsl:if test="marc:subfield[@code = '0']">
				<xsl:attribute name="authority"><xsl:text>libris</xsl:text></xsl:attribute>
				<xsl:attribute name="valueURI"><xsl:text>http://data.libris.kb.se/open/auth/</xsl:text><xsl:value-of select="marc:subfield[@code = '0']"/><xsl:text>.xml</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
				<xsl:attribute name="type"><xsl:text>family</xsl:text></xsl:attribute>
				<xsl:choose>
					<xsl:when test="substring($family, string-length($family)) = ','">
						<xsl:value-of select="substring-before($family,',')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$family"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
				<xsl:attribute name="type"><xsl:text>given</xsl:text></xsl:attribute>
				<xsl:choose>
					<xsl:when test="substring($given, string-length($given)) = ','">
						<xsl:value-of select="substring-before($given,',')"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$given"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:for-each select="marc:subfield[@code = 'd']">
				<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>date</xsl:text></xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:for-each>
			<!-- Roll -->
			<xsl:element name="role" namespace="http://www.loc.gov/mods/v3">
				<xsl:element name="roleTerm" namespace="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
					<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
					<xsl:choose>
						<xsl:when test="marc:subfield[@code = '4']">
							<xsl:value-of select="marc:subfield[@code = '4']"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>aut</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template match="marc:datafield[@tag = '600']">
		<xsl:param name="subjectfamily">
			<xsl:choose>
				<xsl:when test="@ind1 = 1">
					<xsl:value-of select="substring-before(marc:subfield[@code = 'a'],', ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-after(marc:subfield[@code = 'a'],' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="subjectgiven">
			<xsl:choose>
				<xsl:when test="@ind1 = 1">
					<xsl:value-of select="substring-after(marc:subfield[@code = 'a'],', ')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(marc:subfield[@code = 'a'],' ')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:if test="not(marc:subfield[@code = '5'])">
			<xsl:element name="subject" namespace="http://www.loc.gov/mods/v3">
				<xsl:element name="name" namespace="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>personal</xsl:text></xsl:attribute>
					<xsl:if test="marc:subfield[@code = '0']">
						<xsl:attribute name="authority"><xsl:text>libris</xsl:text></xsl:attribute>
						<xsl:attribute name="valueURI"><xsl:text>http://data.libris.kb.se/open/auth/</xsl:text><xsl:value-of select="marc:subfield[@code = '0']"/><xsl:text>.xml</xsl:text></xsl:attribute>
					</xsl:if>
					<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
						<xsl:attribute name="type"><xsl:text>family</xsl:text></xsl:attribute>
						<xsl:choose>
							<xsl:when test="substring($subjectfamily, string-length($subjectfamily)) = ','">
								<xsl:value-of select="substring-before($subjectfamily,',')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$subjectfamily"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
						<xsl:attribute name="type"><xsl:text>given</xsl:text></xsl:attribute>
						<xsl:choose>
							<xsl:when test="substring($subjectgiven, string-length($subjectgiven)) = ','">
								<xsl:value-of select="substring-before($subjectgiven,',')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$subjectgiven"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
					<xsl:for-each select="marc:subfield[@code = 'd']">
						<xsl:element name="namePart" namespace="http://www.loc.gov/mods/v3">
							<xsl:attribute name="type"><xsl:text>date</xsl:text></xsl:attribute>
							<xsl:value-of select="."/>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template name="getLanguage">
		<xsl:param name="langString"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="length" select="string-length($langString)"/>
		<xsl:choose>
			<xsl:when test="$length=0"/>
			<xsl:when test="$controlField008-35-37=substring($langString,1,3)">
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="language" xmlns="http://www.loc.gov/mods/v3">
					<languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="substring($langString,1,3)"/>
					</languageTerm>
				</xsl:element>
				<xsl:call-template name="getLanguage">
					<xsl:with-param name="langString" select="substring($langString,4,$length)"/>
					<xsl:with-param name="controlField008-35-37" select="$controlField008-35-37"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="isoLanguage">
		<xsl:param name="currentLanguage"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="remainingLanguages"/>
		<xsl:choose>
			<xsl:when test="string-length($currentLanguage)=0"/>
			<xsl:when test="not(contains($usedLanguages, $currentLanguage))">
				<xsl:element name="language" xmlns="http://www.loc.gov/mods/v3">
					<xsl:if test="@code!='a'">
						<xsl:attribute name="objectPart"><xsl:choose><xsl:when test="@code='b'">summary</xsl:when><xsl:when test="@code='d'">sung or spoken text</xsl:when><xsl:when test="@code='e'">libretto</xsl:when><xsl:when test="@code='f'">table of contents</xsl:when><xsl:when test="@code='g'">accompanying material</xsl:when><xsl:when test="@code='h'">translation</xsl:when></xsl:choose></xsl:attribute>
					</xsl:if>
					<languageTerm authority="iso639-2b" type="code">
						<xsl:value-of select="$currentLanguage"/>
					</languageTerm>
				</xsl:element>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="isoLanguage">
					<xsl:with-param name="currentLanguage">
						<xsl:value-of select="substring($remainingLanguages,1,3)"/>
					</xsl:with-param>
					<xsl:with-param name="usedLanguages">
						<xsl:value-of select="concat($usedLanguages,$currentLanguage)"/>
					</xsl:with-param>
					<xsl:with-param name="remainingLanguages">
						<xsl:value-of select="substring($remainingLanguages,4,string-length($remainingLanguages))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="chopBrackets">
		<xsl:param name="chopString"/>
		<xsl:variable name="string">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="$chopString"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="substring($string, 1,1)='['">
			<xsl:value-of select="substring($string,2, string-length($string)-2)"/>
		</xsl:if>
		<xsl:if test="substring($string, 1,1)!='['">
			<xsl:value-of select="$string"/>
		</xsl:if>
	</xsl:template>
	<xsl:template name="rfcLanguages">
		<xsl:param name="nodeNum"/>
		<xsl:param name="usedLanguages"/>
		<xsl:param name="controlField008-35-37"/>
		<xsl:variable name="currentLanguage" select="."/>
		<xsl:choose>
			<xsl:when test="not($currentLanguage)"/>
			<xsl:when test="$currentLanguage!=$controlField008-35-37 and $currentLanguage!='rfc3066'">
				<xsl:if test="not(contains($usedLanguages,$currentLanguage))">
					<xsl:element name="language" xmlns="http://www.loc.gov/mods/v3">
						<xsl:if test="@code!='a'">
							<xsl:attribute name="objectPart"><xsl:choose><xsl:when test="@code='b'">summary or subtitle</xsl:when><xsl:when test="@code='d'">sung or spoken text</xsl:when><xsl:when test="@code='e'">libretto</xsl:when><xsl:when test="@code='f'">table of contents</xsl:when><xsl:when test="@code='g'">accompanying material</xsl:when><xsl:when test="@code='h'">translation</xsl:when></xsl:choose></xsl:attribute>
						</xsl:if>
						<languageTerm authority="rfc3066" type="code">
							<xsl:value-of select="$currentLanguage"/>
						</languageTerm>
					</xsl:element>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise> </xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- titleInfo 130 730 245 246 240 740 210 -->
	<xsl:template name="xxx880">
		<xsl:if test="child::marc:subfield[@code='6']">
			<xsl:variable name="sf06" select="normalize-space(child::marc:subfield[@code='6'])"/>
			<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
			<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
			<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
			<xsl:variable name="scriptCode" select="substring($sf06, 8, 2)"/>
			<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$sf06b"/></xsl:attribute>
				<xsl:attribute name="script"><xsl:choose><xsl:when test="$scriptCode=''">Latn</xsl:when><xsl:when test="$scriptCode='(3'">Arab</xsl:when><xsl:when test="$scriptCode='(4'">Arab</xsl:when><xsl:when test="$scriptCode='(B'">Latn</xsl:when><xsl:when test="$scriptCode='!E'">Latn</xsl:when><xsl:when test="$scriptCode='$1'">CJK</xsl:when><xsl:when test="$scriptCode='(N'">Cyrl</xsl:when><xsl:when test="$scriptCode='(Q'">Cyrl</xsl:when><xsl:when test="$scriptCode='(2'">Hebr</xsl:when><xsl:when test="$scriptCode='(S'">Grek</xsl:when></xsl:choose></xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="part">
		<xsl:variable name="partNumber">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">n</xsl:with-param>
				<xsl:with-param name="anyCodes">n</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="partName">
			<xsl:call-template name="specialSubfieldSelect">
				<xsl:with-param name="axis">p</xsl:with-param>
				<xsl:with-param name="anyCodes">p</xsl:with-param>
				<xsl:with-param name="afterCodes">fgkdlmor</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string-length(normalize-space($partNumber))">
			<xsl:element name="partNumber" xmlns="http://www.loc.gov/mods/v3">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partNumber"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
		<xsl:if test="string-length(normalize-space($partName))">
			<xsl:element name="partName" xmlns="http://www.loc.gov/mods/v3">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="$partName"/>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template name="subtitle">
		<xsl:if test="marc:subfield[@code='b']">
			<xsl:element name="subTitle" xmlns="http://www.loc.gov/mods/v3">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="marc:subfield[@code='b']"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template name="specialSubfieldSelect">
		<xsl:param name="anyCodes"/>
		<xsl:param name="axis"/>
		<xsl:param name="beforeCodes"/>
		<xsl:param name="afterCodes"/>
		<xsl:variable name="str">
			<xsl:for-each select="marc:subfield">
				<xsl:if test="contains($anyCodes, @code) or (contains($beforeCodes,@code) and following-sibling::marc:subfield[@code=$axis])      or (contains($afterCodes,@code) and preceding-sibling::marc:subfield[@code=$axis])">
					<xsl:value-of select="text()"/>
					<xsl:text> </xsl:text>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
	</xsl:template>
	<xsl:template name="z2xx880">
		<!-- Evaluating the 260 field -->
		<xsl:variable name="x260">
			<xsl:choose>
				<xsl:when test="@tag='260' and marc:subfield[@code='6']">
					<xsl:variable name="sf06260" select="normalize-space(child::marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06260a" select="substring($sf06260, 1, 3)"/>
					<xsl:variable name="sf06260b" select="substring($sf06260, 5, 2)"/>
					<xsl:variable name="sf06260c" select="substring($sf06260, 7)"/>
					<xsl:value-of select="$sf06260b"/>
				</xsl:when>
				<xsl:when test="@tag='250' and ../marc:datafield[@tag='260']/marc:subfield[@code='6']">
					<xsl:variable name="sf06260" select="normalize-space(../marc:datafield[@tag='260']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06260a" select="substring($sf06260, 1, 3)"/>
					<xsl:variable name="sf06260b" select="substring($sf06260, 5, 2)"/>
					<xsl:variable name="sf06260c" select="substring($sf06260, 7)"/>
					<xsl:value-of select="$sf06260b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="x250">
			<xsl:choose>
				<xsl:when test="@tag='250' and marc:subfield[@code='6']">
					<xsl:variable name="sf06250" select="normalize-space(../marc:datafield[@tag='250']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06250a" select="substring($sf06250, 1, 3)"/>
					<xsl:variable name="sf06250b" select="substring($sf06250, 5, 2)"/>
					<xsl:variable name="sf06250c" select="substring($sf06250, 7)"/>
					<xsl:value-of select="$sf06250b"/>
				</xsl:when>
				<xsl:when test="@tag='260' and ../marc:datafield[@tag='250']/marc:subfield[@code='6']">
					<xsl:variable name="sf06250" select="normalize-space(../marc:datafield[@tag='250']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06250a" select="substring($sf06250, 1, 3)"/>
					<xsl:variable name="sf06250b" select="substring($sf06250, 5, 2)"/>
					<xsl:variable name="sf06250c" select="substring($sf06250, 7)"/>
					<xsl:value-of select="$sf06250b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$x250!='' and $x260!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="concat($x250, $x260)"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x250!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x250"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x260!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x260"/></xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']"> </xsl:if>
	</xsl:template>
	<!-- titleInfo 130 730 245 246 240 740 210 -->
	<!-- 130 -->
	<xsl:template name="createTitleInfoFrom130">
		<xsl:for-each select="marc:datafield[@tag='130'][@ind2!='2']">
			<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
				<xsl:attribute name="type"><xsl:text>uniform</xsl:text></xsl:attribute>
				<title>
					<xsl:variable name="str">
						<xsl:for-each select="marc:subfield">
							<xsl:if test="(contains('s',@code))">
								<xsl:value-of select="text()"/>
								<xsl:text> </xsl:text>
							</xsl:if>
							<xsl:if test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
								<xsl:value-of select="text()"/>
								<xsl:text> </xsl:text>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
						</xsl:with-param>
					</xsl:call-template>
				</title>
				<xsl:call-template name="part"/>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="createTitleInfoFrom730">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>uniform</xsl:text></xsl:attribute>
			<title>
				<xsl:variable name="str">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('s',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:if test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
					</xsl:with-param>
				</xsl:call-template>
			</title>
			<xsl:call-template name="part"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createTitleInfoFrom210">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>abbreviated</xsl:text></xsl:attribute>
			<xsl:if test="marc:datafield[@tag='210'][@ind2='2']">
				<xsl:attribute name="authority"><xsl:value-of select="marc:subfield[@code='2']"/></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="xxx880"/>
			<title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">a</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</title>
			<xsl:call-template name="subtitle"/>
		</xsl:element>
	</xsl:template>
	<!-- 1.79 -->
	<xsl:template name="createTitleInfoFrom245">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="marc:subfield[@code='b']">
						<xsl:call-template name="specialSubfieldSelect">
							<xsl:with-param name="axis">b</xsl:with-param>
							<xsl:with-param name="beforeCodes">afgks</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abfgks</xsl:with-param>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="titleChop">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="$title"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="@ind2&gt;0">
					<xsl:if test="@tag!='880'">
						<nonSort>
							<xsl:value-of select="substring($titleChop,1,@ind2)"/>
						</nonSort>
					</xsl:if>
					<title>
						<xsl:value-of select="substring($titleChop,@ind2+1)"/>
					</title>
				</xsl:when>
				<xsl:otherwise>
					<title>
						<xsl:value-of select="$titleChop"/>
					</title>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="marc:subfield[@code='b']">
				<subTitle>
					<xsl:call-template name="chopPunctuation">
						<xsl:with-param name="chopString">
							<xsl:call-template name="specialSubfieldSelect">
								<xsl:with-param name="axis">b</xsl:with-param>
								<xsl:with-param name="anyCodes">b</xsl:with-param>
								<xsl:with-param name="afterCodes">afgks</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</subTitle>
			</xsl:if>
			<xsl:call-template name="part"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createTitleInfoFrom246">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>alternative</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:for-each select="marc:subfield[@code='i']">
				<xsl:attribute name="displayLabel"><xsl:value-of select="text()"/></xsl:attribute>
			</xsl:for-each>
			<title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<!-- 1/04 removed $h, $b -->
							<xsl:with-param name="codes">af</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</title>
			<xsl:call-template name="subtitle"/>
			<xsl:call-template name="part"/>
		</xsl:element>
	</xsl:template>
	<!-- 240 nameTitleGroup-->
	<xsl:template name="createTitleInfoFrom240">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>uniform</xsl:text></xsl:attribute>
			<xsl:if test="//marc:datafield[@tag='100']|//marc:datafield[@tag='110']|//marc:datafield[@tag='111']">
				<xsl:attribute name="nameTitleGroup"><xsl:text>1</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="xxx880"/>
			<title>
				<xsl:variable name="str">
					<xsl:for-each select="marc:subfield">
						<xsl:if test="(contains('s',@code))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
						<xsl:if test="(contains('adfklmors',@code) and (not(../marc:subfield[@code='n' or @code='p']) or (following-sibling::marc:subfield[@code='n' or @code='p'])))">
							<xsl:value-of select="text()"/>
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
					</xsl:with-param>
				</xsl:call-template>
			</title>
			<xsl:call-template name="part"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createTitleInfoFrom740">
		<xsl:element name="titleInfo" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>alternative</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<title>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">ah</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</title>
			<xsl:call-template name="part"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="z3xx880">
		<!-- Evaluating the 300 field -->
		<xsl:variable name="x300">
			<xsl:choose>
				<xsl:when test="@tag='300' and marc:subfield[@code='6']">
					<xsl:variable name="sf06300" select="normalize-space(child::marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06300a" select="substring($sf06300, 1, 3)"/>
					<xsl:variable name="sf06300b" select="substring($sf06300, 5, 2)"/>
					<xsl:variable name="sf06300c" select="substring($sf06300, 7)"/>
					<xsl:value-of select="$sf06300b"/>
				</xsl:when>
				<xsl:when test="@tag='351' and ../marc:datafield[@tag='300']/marc:subfield[@code='6']">
					<xsl:variable name="sf06300" select="normalize-space(../marc:datafield[@tag='300']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06300a" select="substring($sf06300, 1, 3)"/>
					<xsl:variable name="sf06300b" select="substring($sf06300, 5, 2)"/>
					<xsl:variable name="sf06300c" select="substring($sf06300, 7)"/>
					<xsl:value-of select="$sf06300b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="x351">
			<xsl:choose>
				<xsl:when test="@tag='351' and marc:subfield[@code='6']">
					<xsl:variable name="sf06351" select="normalize-space(../marc:datafield[@tag='351']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06351a" select="substring($sf06351, 1, 3)"/>
					<xsl:variable name="sf06351b" select="substring($sf06351, 5, 2)"/>
					<xsl:variable name="sf06351c" select="substring($sf06351, 7)"/>
					<xsl:value-of select="$sf06351b"/>
				</xsl:when>
				<xsl:when test="@tag='300' and ../marc:datafield[@tag='351']/marc:subfield[@code='6']">
					<xsl:variable name="sf06351" select="normalize-space(../marc:datafield[@tag='351']/marc:subfield[@code='6'])"/>
					<xsl:variable name="sf06351a" select="substring($sf06351, 1, 3)"/>
					<xsl:variable name="sf06351b" select="substring($sf06351, 5, 2)"/>
					<xsl:variable name="sf06351c" select="substring($sf06351, 7)"/>
					<xsl:value-of select="$sf06351b"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="x337">
			<xsl:if test="@tag='337' and marc:subfield[@code='6']">
				<xsl:variable name="sf06337" select="normalize-space(child::marc:subfield[@code='6'])"/>
				<xsl:variable name="sf06337a" select="substring($sf06337, 1, 3)"/>
				<xsl:variable name="sf06337b" select="substring($sf06337, 5, 2)"/>
				<xsl:variable name="sf06337c" select="substring($sf06337, 7)"/>
				<xsl:value-of select="$sf06337b"/>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="x338">
			<xsl:if test="@tag='338' and marc:subfield[@code='6']">
				<xsl:variable name="sf06338" select="normalize-space(child::marc:subfield[@code='6'])"/>
				<xsl:variable name="sf06338a" select="substring($sf06338, 1, 3)"/>
				<xsl:variable name="sf06338b" select="substring($sf06338, 5, 2)"/>
				<xsl:variable name="sf06338c" select="substring($sf06338, 7)"/>
				<xsl:value-of select="$sf06338b"/>
			</xsl:if>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$x351!='' and $x300!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="concat($x351, $x300, $x337, $x338)"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x351!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x351"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x300!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x300"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x337!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x351"/></xsl:attribute>
			</xsl:when>
			<xsl:when test="$x338!=''">
				<xsl:attribute name="altRepGroup"><xsl:value-of select="$x300"/></xsl:attribute>
			</xsl:when>
		</xsl:choose>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']"> </xsl:if>
	</xsl:template>
	<!-- note 245c thru 585 -->
	<xsl:template name="createNoteFrom245c">
		<xsl:choose>
			<xsl:when test="//marc:datafield[@tag='245'] and //marc:datafield[@tag=880]/marc:subfield[@code=6][contains(text(),'245')]">
				<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>statement of responsibility</xsl:text></xsl:attribute>
					<xsl:attribute name="altRepGroup"><xsl:text>00</xsl:text></xsl:attribute>
					<xsl:call-template name="scriptCode"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">c</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
			<xsl:when test="//marc:datafield[@tag='245']/marc:subfield[@code=c]">
				<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>statement of responsibility</xsl:text></xsl:attribute>
					<xsl:call-template name="scriptCode"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">c</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="createNoteFrom362">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>date/sequential designation</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom500">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:value-of select="marc:subfield[@code='a']"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom502">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>thesis</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom504">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>bibliography</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom508">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>creation/production credits</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='u' and @code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom511">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>performers</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom515">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>numbering</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom518">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>venue</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom524">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>	preferred citation</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom530">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>additional physical form</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='u' and @code!='3' and @code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom533">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>reproduction</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<!-- tmee
	<xsl:template name="createNoteFrom534">
		<note type="original version">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
-->
	<xsl:template name="createNoteFrom535">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>original location</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom536">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>funding</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom538">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>system details</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom541">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>acquisition</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom545">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>biographical/historical</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom546">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>language</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom561">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>ownership</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom562">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>version identification</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom581">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>publications</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom583">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>action</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom585">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>exhibitions</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNoteFrom5XX">
		<xsl:element name="note" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:variable name="str">
				<xsl:for-each select="marc:subfield[@code!='6' and @code!='8']">
					<xsl:value-of select="."/>
					<xsl:text> </xsl:text>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of select="substring($str,1,string-length($str)-1)"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="uri">
		<xsl:for-each select="marc:subfield[@code='u']|marc:subfield[@code='0']">
			<xsl:attribute name="xlink:href"><xsl:value-of select="."/></xsl:attribute>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="scriptCode">
		<xsl:variable name="sf06" select="normalize-space(child::marc:subfield[@code='6'])"/>
		<xsl:variable name="sf06a" select="substring($sf06, 1, 3)"/>
		<xsl:variable name="sf06b" select="substring($sf06, 5, 2)"/>
		<xsl:variable name="sf06c" select="substring($sf06, 7)"/>
		<xsl:variable name="scriptCode" select="substring($sf06, 8, 2)"/>
		<xsl:if test="//marc:datafield/marc:subfield[@code='6']">
			<xsl:attribute name="script"><xsl:choose><xsl:when test="$scriptCode=''">Latn</xsl:when><xsl:when test="$scriptCode='(3'">Arab</xsl:when><xsl:when test="$scriptCode='(4'">Arab</xsl:when><xsl:when test="$scriptCode='(B'">Latn</xsl:when><xsl:when test="$scriptCode='!E'">Latn</xsl:when><xsl:when test="$scriptCode='$1'">CJK</xsl:when><xsl:when test="$scriptCode='(N'">Cyrl</xsl:when><xsl:when test="$scriptCode='(Q'">Cyrl</xsl:when><xsl:when test="$scriptCode='(2'">Hebr</xsl:when><xsl:when test="$scriptCode='(S'">Grek</xsl:when></xsl:choose></xsl:attribute>
		</xsl:if>
	</xsl:template>
	<xsl:template name="createNameFrom710">
		<xsl:element name="name" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="nameABCDN"/>
			<xsl:call-template name="role"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNameFrom711">
		<xsl:element name="name" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>conference</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="nameACDEQ"/>
			<xsl:call-template name="role"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNameFrom110">
		<xsl:element name="name" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:if test="//marc:datafield[@tag='240']">
				<xsl:attribute name="nameTitleGroup"><xsl:text>1</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="nameABCDN"/>
			<xsl:call-template name="role"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="createNameFrom111">
		<xsl:element name="name" xmlns="http://www.loc.gov/mods/v3">
			<xsl:attribute name="type"><xsl:text>conference</xsl:text></xsl:attribute>
			<xsl:call-template name="xxx880"/>
			<xsl:if test="//marc:datafield[@tag='240']">
				<xsl:attribute name="nameTitleGroup"><xsl:text>1</xsl:text></xsl:attribute>
			</xsl:if>
			<xsl:call-template name="nameACDEQ"/>
			<xsl:call-template name="role"/>
		</xsl:element>
	</xsl:template>
	<xsl:template name="nameABCDN">
		<xsl:for-each select="marc:subfield[@code='a']">
			<xsl:element name="namePart" xmlns="http://www.loc.gov/mods/v3">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</xsl:element>
		</xsl:for-each>
		<xsl:for-each select="marc:subfield[@code='b']">
			<xsl:element name="namePart" xmlns="http://www.loc.gov/mods/v3">
				<xsl:value-of select="."/>
			</xsl:element>
		</xsl:for-each>
		<xsl:if test="marc:subfield[@code='c'] or marc:subfield[@code='d'] or marc:subfield[@code='n']">
			<xsl:element name="namePart" xmlns="http://www.loc.gov/mods/v3">
				<xsl:call-template name="subfieldSelect">
					<xsl:with-param name="codes">cdn</xsl:with-param>
				</xsl:call-template>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<xsl:template name="nameABCDQ">
		<xsl:element name="namePart" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">aq</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
				<xsl:with-param name="punctuation">
					<xsl:text>:,;/ </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:element>
		<xsl:call-template name="termsOfAddress"/>
		<xsl:call-template name="nameDate"/>
	</xsl:template>
	<xsl:template name="nameACDEQ">
		<xsl:element name="namePart" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">acdeq</xsl:with-param>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	<xsl:template name="role">
		<xsl:for-each select="marc:subfield[@code='4']">
			<xsl:element name="role" xmlns="http://www.loc.gov/mods/v3">
				<xsl:element name="roleTerm" xmlns="http://www.loc.gov/mods/v3">
					<xsl:attribute name="type"><xsl:text>code</xsl:text></xsl:attribute>
					<xsl:attribute name="authority"><xsl:text>marcrelator</xsl:text></xsl:attribute>
					<xsl:value-of select="."/>
				</xsl:element>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- location 852 856 -->
	<xsl:template name="createLocationFrom852">
		<xsl:element name="location" xmlns="http://www.loc.gov/mods/v3">
			<xsl:if test="marc:subfield[@code='a' or @code='b' or @code='e']">
				<xsl:element name="physicalLocation" xmlns="http://www.loc.gov/mods/v3">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">abe</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
			<xsl:if test="marc:subfield[@code='u']">
				<xsl:element name="physicalLocation" xmlns="http://www.loc.gov/mods/v3">
					<xsl:call-template name="uri"/>
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">u</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
			<!-- 1.78 -->
			<xsl:if test="marc:subfield[@code='h' or @code='i' or @code='j' or @code='k' or @code='l' or @code='m' or @code='t']">
				<xsl:element name="shelfLocator" xmlns="http://www.loc.gov/mods/v3">
					<xsl:call-template name="subfieldSelect">
						<xsl:with-param name="codes">hijklmt</xsl:with-param>
					</xsl:call-template>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	<!-- tOC 505 -->
	<xsl:template name="createTOCFrom505">
		<xsl:element name="tableOfContents" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">agrt</xsl:with-param>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	<!-- abstract 520 -->
	<xsl:template name="createAbstractFrom520">
		<xsl:element name="abstract" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="uri"/>
			<xsl:call-template name="subfieldSelect">
				<xsl:with-param name="codes">ab</xsl:with-param>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	<!-- 610 -->
	<xsl:template name="createSubNameFrom610">
		<xsl:element name="subject" xmlns="http://www.loc.gov/mods/v3">
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<xsl:element name="name" xmlns="http://www.loc.gov/mods/v3">
				<xsl:attribute name="type"><xsl:text>corporate</xsl:text></xsl:attribute>
				<xsl:for-each select="marc:subfield[@code='a']">
					<namePart>
						<xsl:value-of select="."/>
					</namePart>
				</xsl:for-each>
				<xsl:for-each select="marc:subfield[@code='b']">
					<namePart>
						<xsl:value-of select="."/>
					</namePart>
				</xsl:for-each>
				<xsl:if test="marc:subfield[@code='c' or @code='d' or @code='n' or @code='p']">
					<namePart>
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">cdnp</xsl:with-param>
						</xsl:call-template>
					</namePart>
				</xsl:if>
				<xsl:call-template name="role"/>
			</xsl:element>
			<!-- 
			<xsl:if test="marc:subfield[@code='t']">
				<titleInfo>
					<title>
						<xsl:call-template name="chopPunctuation">
							<xsl:with-param name="chopString">
								<xsl:call-template name="subfieldSelect">
									<xsl:with-param name="codes">t</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
						</xsl:call-template>
					</title>
					<xsl:call-template name="part"/>
				</titleInfo>
			</xsl:if>
			
			-->
			<!--
			<xsl:call-template name="subjectAnyOrder"/>
			-->
		</xsl:element>
	</xsl:template>
	<xsl:template name="subjectAuthority">
		<xsl:if test="@ind2!=4">
			<xsl:if test="@ind2!=' '">
				<xsl:if test="@ind2!=8">
					<xsl:if test="@ind2!=9">
						<xsl:attribute name="authority"><xsl:choose><xsl:when test="@ind2=0">lcsh</xsl:when><xsl:when test="@ind2=1">lcshac</xsl:when><xsl:when test="@ind2=2">mesh</xsl:when><!-- 1/04 fix --><xsl:when test="@ind2=3">nal</xsl:when><xsl:when test="@ind2=5">csh</xsl:when><xsl:when test="@ind2=6">rvm</xsl:when><xsl:when test="@ind2=7"><xsl:value-of select="marc:subfield[@code='2']"/></xsl:when></xsl:choose></xsl:attribute>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="subjectAuthority2">
		<xsl:if test="../@ind2!=4">
			<xsl:if test="../@ind2!=' '">
				<xsl:if test="../@ind2!=8">
					<xsl:if test="../@ind2!=9">
						<xsl:attribute name="authority"><xsl:choose><xsl:when test="../@ind2=0">lcsh</xsl:when><xsl:when test="../@ind2=1">lcshac</xsl:when><xsl:when test="../@ind2=2">mesh</xsl:when><!-- 1/04 fix --><xsl:when test="../@ind2=3">nal</xsl:when><xsl:when test="../@ind2=5">csh</xsl:when><xsl:when test="../@ind2=6">rvm</xsl:when><xsl:when test="../@ind2=7"><xsl:value-of select="../marc:subfield[@code='2']"/></xsl:when></xsl:choose></xsl:attribute>
					</xsl:if>
				</xsl:if>
			</xsl:if>
		</xsl:if>
	</xsl:template>
	<xsl:template name="subjectAnyOrder">
		<xsl:for-each select="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">
			<xsl:choose>
				<xsl:when test="@code='v'">
					<xsl:call-template name="subjectGenre"/>
				</xsl:when>
				<xsl:when test="@code='x'">
					<xsl:call-template name="subjectTopic"/>
				</xsl:when>
				<xsl:when test="@code='y'">
					<xsl:call-template name="subjectTemporalY"/>
				</xsl:when>
				<xsl:when test="@code='z'">
					<xsl:call-template name="subjectGeographicZ"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="subjectGeographicZ">
		<geographic>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</geographic>
	</xsl:template>
	<xsl:template name="subjectTemporalY">
		<temporal>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</temporal>
	</xsl:template>
	<xsl:template name="subjectTopic">
		<topic>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</topic>
	</xsl:template>
	<xsl:template name="subjectGenre">
		<genre>
			<xsl:call-template name="chopPunctuation">
				<xsl:with-param name="chopString" select="."/>
			</xsl:call-template>
		</genre>
	</xsl:template>
	<xsl:template name="termsOfAddress">
		<xsl:if test="marc:subfield[@code='b' or @code='c']">
			<namePart type="termsOfAddress">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">bc</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</namePart>
		</xsl:if>
	</xsl:template>
	<xsl:template name="nameDate">
		<xsl:for-each select="marc:subfield[@code='d']">
			<namePart type="date">
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString" select="."/>
				</xsl:call-template>
			</namePart>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="affiliation">
		<xsl:for-each select="marc:subfield[@code='u']">
			<affiliation>
				<xsl:value-of select="."/>
			</affiliation>
		</xsl:for-each>
	</xsl:template>
	<xsl:template name="createSubTopFrom650">
		<subject>
			<xsl:call-template name="xxx880"/>
			<xsl:call-template name="subjectAuthority"/>
			<topic>
				<xsl:call-template name="chopPunctuation">
					<xsl:with-param name="chopString">
						<xsl:call-template name="subfieldSelect">
							<xsl:with-param name="codes">abcd</xsl:with-param>
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</topic>
			<!--
			<xsl:call-template name="subjectAnyOrder"/>
			-->
		</subject>
	</xsl:template>
</xsl:stylesheet>
