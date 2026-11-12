###
  SAML IdP metadata helpers for configuring Passport-SAML.
###
ACAS_HOME = "../../.."
serverUtilityFunctions = require "#{ACAS_HOME}/routes/ServerUtilityFunctions.js"
xml2js = require 'xml2js'

request = serverUtilityFunctions.requestAdapter

exports.isPresent = (value) ->
  return false unless value?
  "#{value}".trim() isnt ""

asArray = (value) ->
  return [] unless value?
  if Array.isArray(value) then value else [value]

localName = (name) ->
  parts = "#{name}".split ':'
  parts[parts.length - 1]

childKeysFor = (node, wantedName) ->
  return [] unless node?
  Object.keys(node).filter (key) -> localName(key) is wantedName

childrenFor = (node, wantedName) ->
  matches = []
  for key in childKeysFor(node, wantedName)
    matches = matches.concat asArray(node[key])
  matches

firstChild = (node, wantedName) ->
  childrenFor(node, wantedName)[0]

attr = (node, name) ->
  node?.$?[name]

findEntityDescriptors = (parsed) ->
  descriptors = childrenFor(parsed, 'EntityDescriptor')
  return descriptors if descriptors.length > 0

  rootKey = Object.keys(parsed)[0]
  root = parsed[rootKey]
  if localName(rootKey) is 'EntityDescriptor'
    return [root]

  descriptors = childrenFor(root, 'EntityDescriptor')
  return descriptors if descriptors.length > 0
  []

hasIdpDescriptor = (entityDescriptor) ->
  firstChild(entityDescriptor, 'IDPSSODescriptor')?

findIdpEntityDescriptor = (parsed) ->
  descriptors = findEntityDescriptors(parsed)
  idpDescriptors = descriptors.filter hasIdpDescriptor
  idpDescriptors[0] or descriptors[0]

collectCertificateText = (node, output) ->
  return unless node?
  if typeof node is 'string'
    return
  for key, value of node
    if key is '$'
      continue
    if localName(key) is 'X509Certificate'
      for certNode in asArray(value)
        certText = if typeof certNode is 'string' then certNode else certNode?._
        if exports.isPresent certText
          output.push certText.replace(/\s+/g, '')
    else if typeof value is 'object'
      for child in asArray(value)
        collectCertificateText child, output

extractSigningCertificates = (idpDescriptor) ->
  certs = []
  for keyDescriptor in childrenFor(idpDescriptor, 'KeyDescriptor')
    use = attr(keyDescriptor, 'use')
    if !use? or use is 'signing'
      collectCertificateText keyDescriptor, certs
  certs

extractEntryPoint = (idpDescriptor) ->
  services = childrenFor(idpDescriptor, 'SingleSignOnService')
  redirectService = services.find (service) ->
    /HTTP-Redirect$/.test attr(service, 'Binding') or "#{attr(service, 'Binding')}".indexOf('HTTP-Redirect') >= 0
  postService = services.find (service) ->
    /HTTP-POST$/.test attr(service, 'Binding') or "#{attr(service, 'Binding')}".indexOf('HTTP-POST') >= 0
  selected = redirectService or postService or services.find (service) -> exports.isPresent attr(service, 'Location')
  attr selected, 'Location'

exports.parseMetadataXml = (metadataXml) ->
  new Promise (resolve, reject) ->
    parser = new xml2js.Parser
      explicitArray: false
      attrkey: '$'
      charkey: '_'
      trim: true
    parser.parseString metadataXml, (error, parsed) ->
      return reject error if error?
      entityDescriptor = findIdpEntityDescriptor parsed
      return reject new Error("SAML metadata does not contain an EntityDescriptor") unless entityDescriptor?
      idpDescriptor = firstChild entityDescriptor, 'IDPSSODescriptor'
      return reject new Error("SAML metadata does not contain an IDPSSODescriptor") unless idpDescriptor?

      issuer = attr entityDescriptor, 'entityID'
      return reject new Error("SAML metadata EntityDescriptor is missing entityID") unless exports.isPresent issuer

      entryPoint = extractEntryPoint idpDescriptor
      return reject new Error("SAML metadata does not contain a usable IdP SSO endpoint") unless exports.isPresent entryPoint

      certs = extractSigningCertificates idpDescriptor
      return reject new Error("SAML metadata does not contain a signing certificate") unless certs.length > 0

      resolve
        issuer: issuer
        entryPoint: entryPoint
        idpCert: certs

commonSamlOptions = (configAll) ->
  samlConfig = configAll.server.security.saml
  passReqToCallback: true
  callbackUrl: "#{configAll.client.fullpath}/login/callback"
  audience: samlConfig.audience
  disableRequestedAuthnContext: samlConfig.disableRequestedAuthnContext

explicitSamlOptions = (configAll) ->
  samlConfig = configAll.server.security.saml
  Object.assign {}, commonSamlOptions(configAll),
    entryPoint: samlConfig.entryPoint
    issuer: samlConfig.issuer
    idpCert: samlConfig.cert

exports.fetchMetadataXml = (metadataUrl, requestAdapter = request) ->
  new Promise (resolve, reject) ->
    requestAdapter
      method: 'GET'
      url: metadataUrl
      headers:
        accept: 'application/samlmetadata+xml,application/xml,text/xml,*/*'
      timeout: 30000
      json: false
    , (error, response, body) ->
      return reject new Error("Unable to fetch SAML metadata from #{metadataUrl}: #{error.message}") if error?
      statusCode = response?.statusCode
      unless statusCode >= 200 and statusCode < 300
        return reject new Error("Unable to fetch SAML metadata from #{metadataUrl}: status #{statusCode}")
      unless exports.isPresent body
        return reject new Error("SAML metadata response from #{metadataUrl} was empty")
      resolve body

exports.getSamlStrategyOptions = (configAll, requestAdapter = request) ->
  samlConfig = configAll.server.security.saml
  return Promise.resolve explicitSamlOptions(configAll) unless exports.isPresent samlConfig.metadataUrl

  exports.fetchMetadataXml(samlConfig.metadataUrl, requestAdapter)
    .then (metadataXml) ->
      exports.parseMetadataXml(metadataXml)
    .then (metadataOptions) ->
      Object.assign {}, commonSamlOptions(configAll), metadataOptions
