assert = require 'assert'
acasHome = '../../../..'
samlMetadata = require "#{acasHome}/src/javascripts/ServerAPI/SamlMetadata.js"

redirectFirstMetadata = '''
<md:EntityDescriptor entityID="http://www.okta.com/exkExample" xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <md:IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <md:KeyDescriptor use="signing">
      <ds:KeyInfo>
        <ds:X509Data>
          <ds:X509Certificate>
            MIICERTONE
          </ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
    <md:KeyDescriptor>
      <ds:KeyInfo>
        <ds:X509Data>
          <ds:X509Certificate>MIICERTTWO</ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
    <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.okta.com/post"/>
    <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://example.okta.com/redirect"/>
  </md:IDPSSODescriptor>
</md:EntityDescriptor>
'''

postOnlyMetadata = '''
<EntityDescriptor entityID="http://www.okta.com/exkPostOnly" xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <KeyDescriptor use="signing">
      <ds:KeyInfo>
        <ds:X509Data>
          <ds:X509Certificate>MIIPOSTCERT</ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </KeyDescriptor>
    <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://example.okta.com/post-only"/>
  </IDPSSODescriptor>
</EntityDescriptor>
'''

describe "SAML Metadata helper", ->
  describe "parseMetadataXml", ->
    it "derives issuer, redirect entry point, and signing certificates from IdP metadata", ->
      samlMetadata.parseMetadataXml redirectFirstMetadata
        .then (options) ->
          assert.equal options.issuer, "http://www.okta.com/exkExample"
          assert.equal options.entryPoint, "https://example.okta.com/redirect"
          assert.deepEqual options.idpCert, ["MIICERTONE", "MIICERTTWO"]

    it "falls back to POST when Redirect binding is absent", ->
      samlMetadata.parseMetadataXml postOnlyMetadata
        .then (options) ->
          assert.equal options.issuer, "http://www.okta.com/exkPostOnly"
          assert.equal options.entryPoint, "https://example.okta.com/post-only"
          assert.deepEqual options.idpCert, ["MIIPOSTCERT"]

    it "rejects metadata without a signing certificate", ->
      metadataWithoutCert = '''
      <EntityDescriptor entityID="http://www.okta.com/noCert" xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
        <IDPSSODescriptor>
          <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://example.okta.com/redirect"/>
        </IDPSSODescriptor>
      </EntityDescriptor>
      '''
      samlMetadata.parseMetadataXml metadataWithoutCert
        .then ->
          throw new Error("Expected metadata without certificates to fail")
        .catch (error) ->
          assert.equal /signing certificate/.test(error.message), true

  describe "getSamlStrategyOptions", ->
    baseConfig = ->
      client:
        fullpath: "https://acas.example.com"
      server:
        security:
          saml:
            use: true
            metadataUrl: ""
            entryPoint: "https://explicit.example.com/sso"
            issuer: "explicit-issuer"
            cert: "EXPLICITCERT"
            audience: false
            disableRequestedAuthnContext: true

    it "uses explicit SAML values when metadataUrl is absent", ->
      samlMetadata.getSamlStrategyOptions baseConfig()
        .then (options) ->
          assert.equal options.callbackUrl, "https://acas.example.com/login/callback"
          assert.equal options.entryPoint, "https://explicit.example.com/sso"
          assert.equal options.issuer, "explicit-issuer"
          assert.equal options.idpCert, "EXPLICITCERT"
          assert.equal options.audience, false
          assert.equal options.disableRequestedAuthnContext, true

    it "uses metadata-derived values when metadataUrl is present", ->
      config = baseConfig()
      config.server.security.saml.metadataUrl = "https://idp.example.com/metadata"
      fakeRequest = (options, callback) ->
        callback null, {statusCode: 200}, redirectFirstMetadata

      samlMetadata.getSamlStrategyOptions config, fakeRequest
        .then (options) ->
          assert.equal options.entryPoint, "https://example.okta.com/redirect"
          assert.equal options.issuer, "http://www.okta.com/exkExample"
          assert.deepEqual options.idpCert, ["MIICERTONE", "MIICERTTWO"]

    it "rejects when metadataUrl fetch returns non-2xx", ->
      config = baseConfig()
      config.server.security.saml.metadataUrl = "https://idp.example.com/metadata"
      fakeRequest = (options, callback) ->
        callback null, {statusCode: 404}, "not found"

      samlMetadata.getSamlStrategyOptions config, fakeRequest
        .then ->
          throw new Error("Expected metadata fetch failure")
        .catch (error) ->
          assert.equal /status 404/.test(error.message), true
