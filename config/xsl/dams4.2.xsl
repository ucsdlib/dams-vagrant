<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dams42="http://library.ucsd.edu/ontology/dams42#"
    xmlns:dams="http://library.ucsd.edu/ontology/dams#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:edm="http://www.europeana.eu/schemas/edm/"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:gn="http://www.geonames.org/ontology#"
    xmlns:mads="http://www.loc.gov/mads/rdf/v1#"
    xmlns:marcrel="http://id.loc.gov/vocabulary/relators/"
    xmlns:mix="http://www.loc.gov/mix/v20#"
    xmlns:modsrdf="http://www.loc.gov/mods/rdf/v1#"
    xmlns:premis="http://www.loc.gov/premis/rdf/v1#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:rights="http://projecthydra.org/rights#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:works="http://projecthydra.org/ns/works#">

  <xsl:output method="xml"/>
  <xsl:variable name="oldns">http://library.ucsd.edu/ark:/20775</xsl:variable>
  <xsl:param name="repositoryURL">http://localhost:8080/rest</xsl:param>

  <!-- records ================================================================================ -->
  
  <xsl:template match="/rdf:RDF">
    <rdf:RDF>
      <xsl:apply-templates/>

      <!-- collections -->
      <xsl:for-each select="//dams:AssembledCollection|//dams:ProvenanceCollection|//dams:ProvenanceCollectionPart">
        <xsl:call-template name="collection"/>
      </xsl:for-each>
      <xsl:for-each select="//dams:Unit">
        <xsl:call-template name="unit"/>
      </xsl:for-each>

      <!-- subjects -->
      <xsl:for-each select="//mads:ComplexSubject">
        <xsl:call-template name="complex-subject"/>
      </xsl:for-each>
      <xsl:for-each select="//mads:BuiltWorkPlace|//mads:CulturalContext|//mads:Function|//mads:GenreForm|//mads:Geographic|//mads:Language|//mads:Iconography|//mads:Occupation|//mads:ScientificName|//mads:StylePeriod|//mads:Technique|//mads:Temporal|//mads:Topic">
        <xsl:call-template name="subject"/>
      </xsl:for-each>
      <xsl:for-each select="//mads:ConferenceName|//mads:CorporateName|//mads:FamilyName|//mads:Name|//mads:PersonalName">
        <xsl:call-template name="agent"/>
      </xsl:for-each>

      <!-- files -->
      <xsl:call-template name="files"/>

    </rdf:RDF>

  </xsl:template>

  <xsl:template match="dams:Object">
    <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
    <works:GenericWork rdf:about="{$id}">
      <xsl:apply-templates/>
      <rdf:type rdf:resource="http://fedora.info/definitions/v4/indexing#indexable"/>
      <xsl:call-template name="rights-statement"/>
    </works:GenericWork>
  </xsl:template>

  <!-- collection records -->
  <xsl:template name="collection">
    <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
    <works:Collection rdf:about="{$id}">
      <xsl:apply-templates/>
    </works:Collection>
  </xsl:template>
  <xsl:template match="dams:hasAssembledCollection|dams:hasProvenanceCollection|dams:hasPart|dams:hasCollection">
    <xsl:for-each select="dams:AssembledCollection|dams:ProvenanceCollection|dams:ProvenanceCollectionPart">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <works:memberOf rdf:resource="{$id}"/>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="unit">
    <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
    <works:AdministrativeSet rdf:about="{$id}">
      <dcterms:title><xsl:value-of select="dams:unitName"/></dcterms:title>
      <dcterms:description><xsl:value-of select="dams:unitDescription"/></dcterms:description>
      <dc:relation rdf:resource="{dams:unitURI}"/>
    </works:AdministrativeSet>
  </xsl:template>

  <xsl:template name="agent">
    <xsl:if test="mads:authoritativeLabel">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <edm:Agent rdf:about="{$id}">
        <skos:prefLabel><xsl:value-of select="mads:authoritativeLabel"/></skos:prefLabel>
        <xsl:for-each select="mads:isMemberOfMADSScheme/mads:MADSScheme/mads:hasExactExternalAuthority[@rdf:resource]">
          <skos:inScheme rdf:resource="{@rdf:resource}"/>
        </xsl:for-each>
      </edm:Agent>
    </xsl:if>
  </xsl:template>
  <xsl:template name="subject">
    <xsl:if test="mads:authoritativeLabel">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <skos:Concept rdf:about="{$id}">
        <skos:prefLabel><xsl:value-of select="mads:authoritativeLabel"/></skos:prefLabel>
        <xsl:for-each select="mads:isMemberOfMADSScheme/mads:MADSScheme/mads:hasExactExternalAuthority[@rdf:resource]">
          <skos:inScheme rdf:resource="{@rdf:resource}"/>
        </xsl:for-each>
      </skos:Concept>
    </xsl:if>
  </xsl:template>
  <xsl:template name="complex-subject">
    <xsl:if test="mads:authoritativeLabel">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <dams42:ComplexSubject rdf:about="{$id}">
        <skos:prefLabel><xsl:value-of select="mads:authoritativeLabel"/></skos:prefLabel>
        <xsl:for-each select="mads:isMemberOfMADSScheme/mads:MADSScheme/mads:hasExactExternalAuthority[@rdf:resource]">
          <skos:inScheme rdf:resource="{@rdf:resource}"/>
        </xsl:for-each>
        <xsl:for-each select="mads:componentList/*">
          <!-- TODO inline subjects -->
          <xsl:variable name="cid" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
          <xsl:choose>
            <xsl:when test="local-name() = 'BuiltWorkPlace'"><dams42:builtWorkPlace rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'ConferenceName'"><dams42:conferenceName rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'CorporateName'"><dams42:corporateName rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'CulturalContext'"><dams42:culturalContext rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'FamilyName'"><dams42:familyName rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Function'"><dams42:function rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'GenreForm'"><dams42:genreForm rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Geographic'"><dams42:geographic rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Iconography'"><dams42:iconography rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Language'"><dams42:language rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Name'"><dams42:name rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Occupation'"><dams42:occupation rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'PersonalName'"><dams42:personalName rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'ScientificName'"><dams42:scientificName rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'StylePeriod'"><dams42:stylePeriod rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Technique'"><dams42:technique rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Temporal'"><dams42:temporal rdf:resource="{$cid}"/></xsl:when>
            <xsl:when test="local-name() = 'Topic'"><dams42:topic rdf:resource="{$cid}"/></xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </dams42:ComplexSubject>
    </xsl:if>
  </xsl:template>

  <!-- fields ================================================================================= -->

  <!-- cartographics -->
  <xsl:template match="dams:cartographics">
    <xsl:for-each select="dams:Cartographics">
      <dcterms:spatial>
        <edm:Place>
          <xsl:for-each select="dams:point|dams:line|dams:polygon">
            <gn:geometry><xsl:value-of select="."/></gn:geometry>
          </xsl:for-each>
        </edm:Place>
      </dcterms:spatial>
    </xsl:for-each>
  </xsl:template>

  <!-- collections -->
  <xsl:template match="dams:assembledCollection|dams:provenanceCollection|dams:provenanceCollectionPart">
    <xsl:for-each select="dams:AssembledCollection|dams:ProvenanceCollection|dams:ProvenanceCollectionPart">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <works:memberOf rdf:resource="{$id}"/>
    </xsl:for-each>
  </xsl:template>

  <!-- components -->
  <xsl:template match="dams:hasComponent">
    <xsl:for-each select="dams:Component">
      <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <works:hasMember>
        <works:GenericWork rdf:about="{$id}">
          <xsl:apply-templates/>
        </works:GenericWork>
      </works:hasMember>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="dams:order">
    <!-- TODO ore proxy -->
    <dams42:order><xsl:value-of select="."/></dams42:order>
  </xsl:template>

  <!-- dates -->
  <xsl:template match="dams:date">
    <xsl:for-each select="dams:Date">
      <xsl:choose>
        <xsl:when test="dams:type = 'creation' or dams:type = 'created'">
          <dcterms:created><xsl:call-template name="timespan"/></dcterms:created>
        </xsl:when>
        <xsl:when test="dams:type = 'collected' or dams:type = 'date collected'">
          <dams42:collectionDate><xsl:call-template name="timespan"/></dams42:collectionDate>
        </xsl:when>
        <xsl:when test="dams:type = 'event'">
          <dams42:eventDate><xsl:call-template name="timespan"/></dams42:eventDate>
        </xsl:when>
        <xsl:when test="dams:type = 'copyright'">
          <dcterms:copyright><xsl:call-template name="timespan"/></dcterms:copyright>
        </xsl:when>
        <xsl:when test="dams:type = 'issued' or dams:type = 'date issued'">
          <dcterms:issued><xsl:call-template name="timespan"/></dcterms:issued>
        </xsl:when>
        <xsl:otherwise>
          <dc:date><xsl:call-template name="timespan"/></dc:date>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="timespan">
    <xsl:variable name="num" select="count(../preceding-sibling::dams:date)"/>
    <edm:TimeSpan rdf:about="{concat($repositoryURL, substring-after(../../@rdf:about, $oldns))}/date-{$num}">
      <xsl:if test="rdf:value != ''">
        <skos:prefLabel><xsl:value-of select="rdf:value"/></skos:prefLabel>
      </xsl:if>
      <xsl:if test="dams:beginDate != ''">
        <edm:begin><xsl:value-of select="dams:beginDate"/></edm:begin>
      </xsl:if>
      <xsl:if test="dams:endDate != ''">
        <edm:end><xsl:value-of select="dams:endDate"/></edm:end>
      </xsl:if>
    </edm:TimeSpan>
  </xsl:template>

  <!-- events -->
  <xsl:template match="dams:event"/>
  <!-- TODO events -->

  <!-- files -->
  <xsl:template match="dams:hasFile"/>
  <xsl:template name="files">
    <xsl:for-each select="//dams:File">
      <xsl:sort select="@rdf:about"/>
      <xsl:variable name="fid" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
      <works:GenericFile rdf:about="{$fid}/fcr:metadata">
        <dc:format><xsl:value-of select="dams:mimeType"/></dc:format>
        <premis:dateCreatedByApplication><xsl:value-of select="dams:dateCreated"/></premis:dateCreatedByApplication>

        <!-- XXX conflict with fcrepo4 managed predicates:
        <premis:hasSize><xsl:value-of select="dams:size"/></premis:hasSize>
        <xsl:for-each select="dams:crc32checksum">
          <premis:hasMessageDigest rdf:resource="urn:crc32:{.}"/>
        </xsl:for-each>
        <xsl:for-each select="dams:mdams42">
          <premis:hasMessageDigest rdf:resource="urn:mdams42:{.}"/>
        </xsl:for-each>
        <xsl:for-each select="dams:sha1checksum">
          <premis:hasMessageDigest rdf:resource="urn:sha1:{.}"/>
        </xsl:for-each>
        <xsl:for-each select="dams:sourceFileName">
          <premis:hasOriginalName><xsl:value-of select="."/></premis:hasOriginalName>
        </xsl:for-each>
        -->

        <premis:hasFormatName><xsl:value-of select="dams:formatName"/></premis:hasFormatName>
        <premis:hasFormatVersion><xsl:value-of select="dams:formatVersion"/></premis:hasFormatVersion>
        <premis:hasObjectCategory><xsl:value-of select="dams:objectCategory"/></premis:hasObjectCategory>
        <premis:hasPreservationLevel><xsl:value-of select="dams:preservationLevel"/></premis:hasPreservationLevel>
        <dams42:quality><xsl:value-of select="dams:quality"/></dams42:quality>
        <xsl:for-each select="dams:sourcePath">
          <dams42:sourcePath><xsl:value-of select="."/></dams42:sourcePath>
        </xsl:for-each>

        <!-- mix -->
        <xsl:for-each select="mix:sourceType">
          <mix:sourceType><xsl:value-of select="dams:sourceType"/></mix:sourceType>
        </xsl:for-each>
        <xsl:for-each select="mix:imageProducer">
          <mix:imageProducer><xsl:value-of select="dams:imageProducer"/></mix:imageProducer>
        </xsl:for-each>
        <xsl:for-each select="mix:captureSource">
          <mix:captureSource><xsl:value-of select="dams:captureSource"/></mix:captureSource>
        </xsl:for-each>
        <xsl:for-each select="mix:scannerManufacturer">
          <mix:scannerManufacturer><xsl:value-of select="dams:scannerManufacturer"/></mix:scannerManufacturer>
        </xsl:for-each>
        <xsl:for-each select="mix:scannerModelName">
          <mix:scannerModelName><xsl:value-of select="dams:scannerModelName"/></mix:scannerModelName>
        </xsl:for-each>
        <xsl:for-each select="mix:scanningSoftware">
          <mix:scanningSoftware><xsl:value-of select="dams:scanningSoftware"/></mix:scanningSoftware>
        </xsl:for-each>
        <xsl:for-each select="mix:scanningSoftwareVersion">
          <mix:scanningSoftwareVersion><xsl:value-of select="dams:scanningSoftwareVersion"/></mix:scanningSoftwareVersion>
        </xsl:for-each>

        <dams42:use><xsl:value-of select="dams:use"/></dams42:use> <!-- TODO convert to ds name -->
      </works:GenericFile>
    </xsl:for-each>
  </xsl:template>

  <!-- mads subjects -->
  <xsl:template match="dams:builtWorkPlace|dams:conferenceName|dams:corporateName|dams:culturalContext|dams:familyName|dams:function|dams:genreForm|dams:geographic|dams:language|dams:iconography|dams:name|dams:occupation|dams:otherName|dams:personalName|dams:scientificName|dams:stylePeriod|dams:technique|dams:temporal|dams:topic">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@rdf:resource != ''">
          <xsl:value-of select="@rdf:resource"/>
        </xsl:when>
        <xsl:when test="*/@rdf:about != ''">
          <xsl:value-of select="*/@rdf:about"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$oldns"/>/XXXXXXXX</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="dams42:{local-name()}">
      <xsl:attribute name="rdf:resource">
        <xsl:value-of select="concat($repositoryURL, substring-after($id, $oldns))"/>
      </xsl:attribute>
    </xsl:element>
  </xsl:template>
  <xsl:template match="dams:complexSubject">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="@rdf:resource != ''">
          <xsl:value-of select="@rdf:resource"/>
        </xsl:when>
        <xsl:when test="*/@rdf:about != ''">
          <xsl:value-of select="*/@rdf:about"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$oldns"/>/XXXXXXXX</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <dams42:complexSubject rdf:resource="{concat($repositoryURL, substring-after($id, $oldns))}"/>
  </xsl:template>

  <!-- notes -->
  <xsl:template match="dams:note">
    <xsl:for-each select="dams:Note">
      <xsl:choose>
        <xsl:when test="dams:type = 'identifier'">
          <dcterms:identifier rdf:resource="urn:{dams:displayLabel}:{rdf:value}"/>
        </xsl:when>
        <xsl:when test="dams:type = 'extent'">
          <dcterms:extent><xsl:value-of select="rdf:value"/></dcterms:extent>
        </xsl:when>
        <xsl:when test="dams:type = 'preferred citation'">
          <dcterms:bibliographicCitation><xsl:value-of select="rdf:value"/></dcterms:bibliographicCitation>
        </xsl:when>
        <xsl:when test="dams:type = 'table of contents'">
          <dcterms:tableOfContents><xsl:value-of select="rdf:value"/></dcterms:tableOfContents>
        </xsl:when>
        <xsl:when test="dams:type = 'arrangement'">
          <dams42:arrangement><xsl:value-of select="rdf:value"/></dams42:arrangement>
        </xsl:when>
        <xsl:when test="dams:type = 'bibliography'">
          <dams42:bibliography><xsl:value-of select="rdf:value"/></dams42:bibliography>
        </xsl:when>
        <xsl:when test="dams:type = 'biography'">
          <dams42:biography><xsl:value-of select="rdf:value"/></dams42:biography>
        </xsl:when>
        <xsl:when test="dams:type = 'classification'">
          <dams42:classification><xsl:value-of select="rdf:value"/></dams42:classification>
        </xsl:when>
        <xsl:when test="dams:type = 'credits'">
          <dams42:credits><xsl:value-of select="rdf:value"/></dams42:credits>
        </xsl:when>
        <xsl:when test="dams:type = 'custodial history'">
          <dams42:custodialHistory><xsl:value-of select="rdf:value"/></dams42:custodialHistory>
        </xsl:when>
        <xsl:when test="dams:type = 'description'">
          <dcterms:abstract><xsl:value-of select="rdf:value"/></dcterms:abstract>
        </xsl:when>
        <xsl:when test="dams:type = 'digital origin'">
          <dams42:digitalOrigin><xsl:value-of select="rdf:value"/></dams42:digitalOrigin>
        </xsl:when>
        <xsl:when test="dams:type = 'edition'">
          <dams42:edition><xsl:value-of select="rdf:value"/></dams42:edition>
        </xsl:when>
        <xsl:when test="dams:type = 'inscription'">
          <dams42:inscription><xsl:value-of select="rdf:value"/></dams42:inscription>
        </xsl:when>
        <xsl:when test="dams:type = 'local attribution'">
          <dams42:localAttribution><xsl:value-of select="rdf:value"/></dams42:localAttribution>
        </xsl:when>
        <xsl:when test="dams:type = 'location of originals'">
          <dams42:locationOfOriginals><xsl:value-of select="rdf:value"/></dams42:locationOfOriginals>
        </xsl:when>
        <xsl:when test="dams:type = 'material details'">
          <xsl:choose>
            <xsl:when test="dams:displaLabel = 'finds'">
              <dams42:finds><xsl:value-of select="rdf:value"/></dams42:finds>
            </xsl:when>
            <xsl:when test="dams:displaLabel = 'limits'">
              <dams42:limits><xsl:value-of select="rdf:value"/></dams42:limits>
            </xsl:when>
            <xsl:when test="dams:displaLabel = 'relationship to other loci'">
              <dams42:relationshipToOtherLoci><xsl:value-of select="rdf:value"/></dams42:relationshipToOtherLoci>
            </xsl:when>
            <xsl:when test="dams:displaLabel = 'storage method'">
              <dams42:storageMethod><xsl:value-of select="rdf:value"/></dams42:storageMethod>
            </xsl:when>
            <xsl:when test="dams:displaLabel = 'water depth'">
              <dams42:waterDepth><xsl:value-of select="rdf:value"/></dams42:waterDepth>
            </xsl:when>
            <xsl:otherwise>
              <dams42:materialDetails><xsl:value-of select="rdf:value"/></dams42:materialDetails>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="dams:type = 'performers'">
          <dams42:performers><xsl:value-of select="rdf:value"/></dams42:performers>
        </xsl:when>
        <xsl:when test="dams:type = 'physical description'">
          <dams42:physicalDescription><xsl:value-of select="rdf:value"/></dams42:physicalDescription>
        </xsl:when>
        <xsl:when test="dams:type = 'publication'">
          <dams42:publication><xsl:value-of select="rdf:value"/></dams42:publication>
        </xsl:when>
        <xsl:when test="dams:type = 'scope and content'">
          <dams42:scopeAndContent><xsl:value-of select="rdf:value"/></dams42:scopeAndContent>
        </xsl:when>
        <xsl:when test="dams:type = 'series'">
          <dams42:series><xsl:value-of select="rdf:value"/></dams42:series>
        </xsl:when>
        <xsl:when test="dams:type = 'statement of responsibility'">
          <dams42:statementOfResponsibility><xsl:value-of select="rdf:value"/></dams42:statementOfResponsibility>
        </xsl:when>
        <xsl:when test="dams:type = 'technical requirements'">
          <dams42:techincalRequirements><xsl:value-of select="rdf:value"/></dams42:techincalRequirements>
        </xsl:when>
        <xsl:when test="dams:type = 'thesis'">
          <dams42:thesis><xsl:value-of select="rdf:value"/></dams42:thesis>
        </xsl:when>
        <xsl:when test="dams:type = 'venue'">
          <dams42:venue><xsl:value-of select="rdf:value"/></dams42:venue>
        </xsl:when>
        <xsl:otherwise>
          <dcterms:description><xsl:value-of select="rdf:value"/></dcterms:description>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="dams:custodialResponsibilityNote">
    <dams42:statementOfResponsibility>
      <xsl:value-of select="dams:CustodialResponsibilityNote/rdf:value"/>
    </dams42:statementOfResponsibility>
  </xsl:template>
  <xsl:template match="dams:preferredCitationNote">
    <dcterms:bibliographicCitation>
      <xsl:value-of select="dams:PreferredCitationNote/rdf:value"/>
    </dcterms:bibliographicCitation>
  </xsl:template>
  <xsl:template match="dams:scopeContentNote">
    <dams42:scopeAndContent>
      <xsl:value-of select="dams:ScopeContentNote/rdf:value"/>
    </dams42:scopeAndContent>
  </xsl:template>

  <!-- related resources -->
  <xsl:template match="dams:relatedCollection">
    <dc:relation rdf:resource="{@rdf:resource}"/>
  </xsl:template>
  <xsl:template match="dams:relatedResource">
    <xsl:for-each select="dams:RelatedResource">
      <xsl:choose>
        <xsl:when test="@rdf:about">
          <xsl:variable name="tmp" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
          <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>

          <xsl:choose>
            <xsl:when test="dams:type='area'"><dams42:area rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='depiction'"><dams42:depiction rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='online exhibit'"><dams42:exhibit rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='online finding aid'"><dams42:findingAid rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='locus'"><dams42:locus rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='news release'"><dams42:newsRelease rdf:resource="{$id}"/></xsl:when>
            <xsl:when test="dams:type='stratum'"><dams42:stratum rdf:resource="{$id}"/></xsl:when>
            <xsl:otherwise><dcterms:relation rdf:resource="{$id}"/></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!-- TODO directly attach thumbnail, or link to URL? -->
          <dams42:thumbnail rdf:resource="{dams:uri/@rdf:resource|dams:uri/text()}"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- relationships -->
  <xsl:template match="dams:relationship">
    <xsl:for-each select="dams:Relationship">
      <xsl:variable name="roleid" select="dams:role/@rdf:resource"/>

      <xsl:variable name="code">
        <xsl:choose>
          <xsl:when test="dams:role/mads:Authority/mads:code">
            <xsl:value-of select="dams:role/mads:Authority/mads:code"/>
          </xsl:when>
          <xsl:when test="//mads:Authority[@rdf:about=$roleid]/mads:code">
            <xsl:value-of select="//mads:Authority[@rdf:about=$roleid]/mads:code"/>
          </xsl:when>
          <xsl:when test="dams:role/mads:Authority[mads:authoritativeLabel='donor']">dnr</xsl:when>
          <xsl:when test="dams:role/mads:Authority[mads:authoritativeLabel='producer']">pro</xsl:when>
          <xsl:otherwise>cre</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="ns">
        <xsl:choose>
          <xsl:when test="$code = 'cpi' or $code = 'pri'">dams42</xsl:when>
          <xsl:otherwise>marcrel</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="name" select="dams:personalName/mads:PersonalName/@rdf:about|dams:corporateName/mads:CorporateName/@rdf:about|dams:conferenceName/mads:ConferenceName/@rdf:about|dams:familyName/mads:FamilyName/@rdf:about|dams:otherName/mads:Name/@rdf:about|dams:name/mads:Name/@rdf:about|dams:personalName/@rdf:resource|dams:corporateName/@rdf:resource|dams:conferenceName/@rdf:resource|dams:familyName/@rdf:resource|dams:otherName/@rdf:resource/dams:name/@rdf:resource"/>
      <xsl:variable name="nameid" select="concat($repositoryURL, substring-after($name, $oldns))"/>

      <xsl:element name="{$ns}:{$code}">
        <xsl:attribute name="rdf:resource"><xsl:value-of select="$nameid"/></xsl:attribute>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <!-- rights -->

  <!-- suppress rights from main body (see rights statement) -->
  <xsl:template match="dams:copyright"/>
  <xsl:template match="dams:license"/>
  <xsl:template match="dams:otherRights"/>
  <xsl:template match="dams:rightsHolder"/>
  <xsl:template match="dams:rightsHolderName"/>
  <xsl:template match="dams:rightsHolderCorporate"/>
  <xsl:template match="dams:rightsHolderPersonal"/>
  <xsl:template match="dams:statute"/>

  <!-- new hydra-plus rights statement -->
  <xsl:template match="dams:visibility">
    <!-- TODO does this map to rights? -->
    <dams42:visibility><xsl:value-of select="."/></dams42:visibility>
  </xsl:template>
  <xsl:template name="rights-statement">
      <!-- TODO dcterms:rights = {xsd:anyURI}  pending rights discussion and vocab -->

      <xsl:for-each select="dams:copyright/dams:Copyright">
        <xsl:for-each select="dams:copyrightJurisdiction">
          <premis:hasCopyrightJurisdiction><xsl:value-of select="."/></premis:hasCopyrightJurisdiction>
        </xsl:for-each>
        <xsl:for-each select="dams:copyrightStatus">
          <premis:hasCopyrightStatus><xsl:value-of select="."/></premis:hasCopyrightStatus>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="dams:license/dams:License">
        <xsl:choose>
          <xsl:when test="@rdf:about">
            <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
            <premis:hasLicenseTerms rdf:resource="{$id}"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="dams:licenseNote">
              <premis:hasLicenseTerms><xsl:value-of select="."/></premis:hasLicenseTerms>
            </xsl:for-each>
            <xsl:for-each select="dams:restriction/dams:Restriction/dams:endDate">
              <rights:embargoExpires><xsl:value-of select="."/></rights:embargoExpires>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:for-each select="dams:otherRights/dams:OtherRights/dams:otherRightsBasis">
        <dams42:otherRights><xsl:value-of select="."/></dams42:otherRights>
      </xsl:for-each>

      <xsl:for-each select="dams:rightsHolder/*|dams:rightsHolderCorporate/*|dams:rightsHolderPersonal/*|dams:rightsHolderName/*">
        <xsl:variable name="id" select="concat($repositoryURL, substring-after(@rdf:about, $oldns))"/>
        <dcterms:rightsHolder rdf:resource="{$id}"/>
      </xsl:for-each>

      <xsl:for-each select="dams:statute">
        <!-- we don't actually have this... -->
      </xsl:for-each>
  </xsl:template>

  <!-- titles -->
  <xsl:template match="dams:title">
    <xsl:for-each select="mads:Title">
      <xsl:for-each select="mads:elementList/mads:MainTitleElement">
        <dcterms:title><xsl:value-of select="mads:elementValue"/></dcterms:title>
      </xsl:for-each>
      <xsl:for-each select="mads:elementList/mads:SubTitleElement">
        <dams42:subtitle><xsl:value-of select="mads:elementValue"/></dams42:subtitle>
      </xsl:for-each>
      <xsl:for-each select="mads:elementList/mads:PartNameElement">
        <modsrdf:partName><xsl:value-of select="mads:elementValue"/></modsrdf:partName>
      </xsl:for-each>
      <xsl:for-each select="mads:elementList/mads:PartNumberElement">
        <modsrdf:partNumber><xsl:value-of select="mads:elementValue"/></modsrdf:partNumber>
      </xsl:for-each>
      <xsl:for-each select="mads:hasVariant/mads:Variant|mads:hasTranslationVariant/mads:Variant">
        <dcterms:alternative><xsl:value-of select="mads:variantLabel"/></dcterms:alternative>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dams:typeOfResource">
    <xsl:choose>
      <xsl:when test="text() = 'image'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/StillImage"/>
      </xsl:when>
      <xsl:when test="text() = 'text'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/Text"/>
      </xsl:when>
      <xsl:when test="text() = 'data'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/Dataset"/>
      </xsl:when>
      <xsl:when test="text() = 'sound recording'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/Sound"/>
      </xsl:when>
      <xsl:when test="text() = 'sound recording-nonmusical'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/Sound"/>
      </xsl:when>
      <xsl:when test="text() = 'video'">
        <dcterms:type rdf:resource="http://purl.org/dc/dcmitype/MovingImage"/>
      </xsl:when>
    </xsl:choose>
<!--
DCMIType vocab:
	http://purl.org/dc/dcmitype/Collection
	http://purl.org/dc/dcmitype/Dataset
	http://purl.org/dc/dcmitype/Event
	http://purl.org/dc/dcmitype/Image
	http://purl.org/dc/dcmitype/InteractiveResource
	http://purl.org/dc/dcmitype/MovingImage
	http://purl.org/dc/dcmitype/PhysicalObject
	http://purl.org/dc/dcmitype/Service
	http://purl.org/dc/dcmitype/Software
	http://purl.org/dc/dcmitype/Sound
	http://purl.org/dc/dcmitype/StillImage
	http://purl.org/dc/dcmitype/Text

XXX Unmapped values:
	Cartographic - can just skip because these also have image or text
	Mixed material - these should be updated with the individual types
-->
  </xsl:template>

  <xsl:template match="dams:unit">
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="dams:Unit/@rdf:about != ''">
          <xsl:value-of select="concat($repositoryURL, substring-after(dams:Unit/@rdf:about, $oldns))"/>
        </xsl:when>
        <xsl:when test="@rdf:resource">
          <xsl:value-of select="concat($repositoryURL, substring-after(@rdf:resource, $oldns))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($repositoryURL, '/XXXXXX')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <works:isContainedBy rdf:resource="{$id}"/>
  </xsl:template>

  <!-- suppress events -->
  <xsl:template match="rdf:Description[dams:event/dams:DAMSEvent/dams:type='record deleted']"/>

  <xsl:template match="*">
    <XXX><xsl:value-of select="name()"/></XXX>
  </xsl:template>

</xsl:stylesheet>
