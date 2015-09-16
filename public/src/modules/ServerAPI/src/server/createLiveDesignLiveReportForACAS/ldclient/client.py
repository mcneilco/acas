import os
import copy
import json
import base64
import hashlib
import logging
import requests
import time

from requests.auth import HTTPBasicAuth

from .models import (Assay, Database, LiveReport, Folder, Protocol, Model, ModelVersion,
                     Project, ColumnDescriptor, ensure_string_list)

SUPPORTED_LD_VERSION = '7.3'

ASSAYS_PATH = '/assays'
DATABASES_PATH = '/databases'
PROJECTS_PATH = '/projects'
LIVE_REPORTS_PATH = '/live_reports'
FOLDERS_PATH = '/tags'
EXTPROPS_PATH = '/extprop/'
MODELS_PATH = '/extprop/models'
PROTOCOLS_PATH = '/extprop/protocols'
MODEL_VERSIONS_PATH = '/extprop/versions'
IMPORT_PATH = '/import'
ASYNC_PATH = '/async_task'
TAGS_PATH = '/tags/live_reports'
COMPOUNDS_PATH = '/compounds'
ABOUT_PATH = '/about'
XTALS_PATH = '/xtals/export'
ATTACHMENT_PATH = '/attachment'
POSE_PATH = '/pose'
CONFIG_PATH = '/config'

FINISHED_STATUS_TYPES = ['finished', 'killed', 'failed', 'malformed_output']

logger = logging.getLogger(__name__)


class ServerProcessingError(Exception):
    pass


class LDClient(object):
    """
    Connection to LiveDesign server

    :type host: str
    :param host: The url to the LiveDesign server, e.g. ('http://localhost:9087')

    :type username: str
    :param username: HTTP basic auth username for accessing the server

    :type password: str
    :param password: HTTP basic auth password
    """

    def __init__(self, host, username=None, password=None):
        self.client = ApiClient(host, username, password)

    def assays(self, database_name=None, project_ids=None, assay_name=None):
        """
        Retrieve all assays

        :type project_ids: List
        :param project_ids: Filters assays to those that belong to the listed projects

        :type assay_name: str
        :param assay_name: Name of the assay to retrieve

        :type database_name: str
        :param database_name: Filter down to assays in a single database (DEPRECATED)

        :return: List of :class:`models.Assay`
        """
        if not project_ids:
            project_ids = [project.id for project in self.projects()]
        params = {}
        if database_name:
            params['database_name'] = database_name

        params['project_ids'] = ','.join([str(pid) for pid in project_ids])
        if assay_name:
            params['assay_name'] = assay_name
        response = self.client.get(ASSAYS_PATH, '', params=params)
        return Assay.from_list(response)

    def assay(self, assay_name, database_name=None, project_ids=None):
        """
        Gets a single assay

        :type assay_name: str
        :param assay_name: Name of the assay to retrieve

        :type project_ids: List
        :param project_ids: Filters assays to those that belong to the listed projects

        :type database_name: str
        :param database_name: Filter down to assays in a single database (DEPRECATED)

        :return: A single :class:`models.Assay` object
        """
        assay_list = self.assays(database_name=database_name,
                                 project_ids=project_ids,
                                 assay_name=assay_name)
        if len(assay_list) == 0:
            raise RuntimeError("No assays found with name: {0}".format(assay_name))

        if len(assay_list) > 1:
            raise RuntimeError("Multiple assays found with name: {0}".format(assay_name))

        return assay_list[0]

    def get_or_create_assay(self,
                            assay_name,
                            assay_type_name,
                            column_type,
                            project_ids):
        """
        Get an assay by its assay_name, assay_type_name, and column_type or create a new assay column if it does
        not exist

        :param assay_name: name of the column
        :param assay_type_name: type of the assay. Must be 3D if column_type == 'THREE_D'
        :param column_type: type of the column. Must be a valid column type recognized by LiveDesign
        :param project_ids: ACLs on the column
        :return: the content of the persisted assay
        :rtype: dict
        """
        assay = {
            "assay_name" : assay_name,
            "assay_type_name" : assay_type_name,
            "column_type" : column_type,
            "project_ids" : project_ids
        }

        return self.client.post(ASSAYS_PATH,
                                '/',
                                data=json.dumps([assay]))[0]

    def databases(self):
        """
        Retrieve all databases

        :return: List of :class:`models.Database`
        """
        response = self.client.get(service_path=DATABASES_PATH, path="", params={})
        return Database.from_list(response)

    def database(self, database_name):
        """
        Retrieve a database by name

        :type database_name: str
        :param database_name: Name of the database to retrieve

        :return: A single :class:`models.Database` object
        """
        path = "/" + database_name
        response = self.client.get(service_path=DATABASES_PATH, path=path, params={})
        return Database.from_dict(response)

    def compound_search(self, molecule, search_type="EXACT", max_results=20, search_threshold=.7,
                        database_names=None, project_id=0):
        """
        Retrieves the corporate ids of the compounds that match the structure search

        :type molecule: str
        :param molecule: SMARTS of the compounds to search

        :type search_type: str
        :param search_type: Type of search: EXACT, SIMILARITY, and SUBSTRUCTURE

        :type max_results: int
        :param max_results: Maximum number of results to return

        :type search_threshold: double
        :param search_threshold: Threshold for SIMILARITY searches

        :type database_names: List
        :param database_names: Databases to search compounds in

        :type project_id: int
        :param project_id: Project to perform search on in addition to the Global project

        :return: List of corporate ids
        """
        if not database_names:
            # search all databases
            database_names = [database.name for database in self.databases()]
        request = {
            "compound_search_type": "STRUCTURE_SEARCH",
            "project_id": project_id,
            "live_report_id": None,
            "structure_search_query": {
                "molecule": molecule,
                "search_type": search_type,
                "search_threshold": search_threshold,
                "max_results": max_results
            },
            "database_search_query": {
                "databases": database_names
            }
        }
        response = self.client.post(service_path=COMPOUNDS_PATH,
                                    path='/search',
                                    data=json.dumps(request))
        return [str(compound['id']) for compound in response['results']]

    def compound_search_by_id(self, query, database_names=None, project_id=0):
        """
        Retrieves the corporate ids of the compounds that match the query

        :type query: str
        :param query: Corporate ID query string

        :type database_names: List
        :param database_names: Databases to search compounds in

        :type project_id: int
        :param project_id: Project to perform search on in addition to the Global project

        :return: List of corporate ids
        """
        if not database_names:
            database_names = [database.name for database in self.databases()]
        request = {
            "compound_search_type": "CORPORATE_ID_SEARCH",
            "project_id": project_id,
            "live_report_id": None,
            "corporate_id_search_query": {"query": query},
            "database_search_query": {"databases": database_names}
        }
        response = self.client.post(service_path=COMPOUNDS_PATH,
                                    path='/search',
                                    data=json.dumps(request))
        return [str(compound['id']) for compound in response['results']]

    def live_reports(self, project_ids=None):
        """
        Retrieve all Live Reports

        :type project_ids: List
        :param project_ids: List of projects ids to search

        :return: List of :class:`models.LiveReport`
        """
        if not project_ids:
            project_ids = [project.id for project in self.projects()]
        params = {'project_ids': ','.join([str(pid) for pid in project_ids])}
        response = self.client.get(service_path=LIVE_REPORTS_PATH, path='', params=params)
        return LiveReport.from_list(response)

    def live_report(self, live_report_id):
        """
        Retrieves a single Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to retrieve

        :return: :class:`models.LiveReport`
        """
        response = self.client.get(LIVE_REPORTS_PATH, '/{0}'.format(live_report_id))
        return LiveReport.from_dict(response)

    def create_live_report(self, live_report):
        """
        Saves a new LiveReport to the LiveDesign server

        :type live_report: :class:`models.LiveReport`
        :param live_report: LiveReport to save

        :return: :class:`models.LiveReport`
        """
        data = live_report.as_json_string(standard_required=True)
        response = self.client.post(LIVE_REPORTS_PATH, '', data=data)
        return LiveReport.from_dict(response)

    def copy_live_report(self, template_id, params):
        """
        Creates copy of an existing Live Report

        :type template_id: int
        :param template_id: ID of the Live Report to copy

        :return: :class:`models.LiveReport`
        """
        response = self.client.post(service_path=LIVE_REPORTS_PATH,
                                    path='/{0}/copy'.format(template_id),
                                    data=json.dumps(params))
        return LiveReport.from_dict(response)

    def create_folder(self, folder_name, project_id="0"):
        """
        Creates a new folder

        :type folder_name: str
        :param folder_name: Name of the new folder

        :type project_id: str
        :param project_id: ID of the project for the folder

        :return: :class:`models.Folder`
        """
        folder = {"name": folder_name, "id": None, "project_id": project_id}
        response = self.client.post(service_path=TAGS_PATH,
                                    path='',
                                    data=json.dumps(folder))
        return Folder.from_dict(response)

    def update_live_report(self, live_report_id, live_report):
        """
        Updates a Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to be updated

        :type live_report: :class:`models.LiveReport`
        :param live_report: updated Live Report object

        :return: :class:`models.LiveReport`
        """
        data = live_report.as_json_string(standard_required=False)
        response = self.client.put(LIVE_REPORTS_PATH, '/{0}'.format(live_report_id), data=data)
        return LiveReport.from_dict(response)

    def execute_live_report(self, live_report_id, use_cached=False, json_response=True):
        """
        Executes a Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to execute

        :type use_cached: bool
        :param use_cached: If True, Live Report is not re-executed if available in the cache

        :type json_response: bool
        :param json_response: If True, gets a json object from the server

        :return: If json_response is True, json response from server
        """
        params = {'use_cached': use_cached}
        response = self.client.get(service_path=LIVE_REPORTS_PATH,
                                   path='/{0}/results'.format(live_report_id),
                                   params=params,
                                   json_response=json_response)
        return response

    def export_live_report(self, live_report_id, export_type='sdf'):
        """
        Exports a Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to be exported

        :type export_type: str
        :param export_type: File type: sdf (default), csv, xls, pptx, pdf
        """
        params = {'type': export_type}
        return self.client.get(service_path=LIVE_REPORTS_PATH,
                               path='/{0}/export'.format(live_report_id),
                               params=params,
                               json_response=False)

    def delete_live_report(self, live_report_id):
        """
        Deletes the Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to be deleted
        """
        self.client.delete(LIVE_REPORTS_PATH, '/{0}'.format(live_report_id))

    def column_descriptors(self, live_report_id, column_id=None):
        """
        Retrieves all column descriptors for a live report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to retrieve column descriptors for

        :type column_id: int
        :param column_id: ID of the column to return

        :return: List of :class:`models.ColumnDescriptor`
        """
        response = self.client.get(LIVE_REPORTS_PATH, '/{0}/columns'.format(live_report_id))

        column_descriptors = ColumnDescriptor.from_list(response)

        if column_id:
            column_descriptors = [cd for cd in column_descriptors if cd.column_id == column_id]

        return column_descriptors

    def add_column_descriptor(self, live_report_id, column_descriptor):
        """
        Adds column descriptors to a live report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to add column descriptor to

        :type :class:`models.ColumnDescriptor`
        :param column_descriptor: Column descriptor to add

        :return: :class:`models.ColumnDescriptor`
        """

        # Switch to update if the column descriptor already exists
        matching_column_descriptors = self.column_descriptors(live_report_id,
                                                              column_descriptor.column_id)

        if matching_column_descriptors:
            column_descriptor.id = matching_column_descriptors[0].id
            return self.update_column_descriptor(live_report_id, column_descriptor)

        column_descriptor.id = None
        column_descriptor.live_report_id = live_report_id
        self.client.post(service_path=LIVE_REPORTS_PATH,
                         path='/{0}/columns'.format(live_report_id),
                         data=column_descriptor.as_json())

        return self.column_descriptors(live_report_id, column_descriptor.column_id)[0]

    def update_column_descriptor(self, live_report_id, column_descriptor):
        """
        Updates column descriptors to a live report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to update column descriptor for

        :type :class:`models.ColumnDescriptor`
        :param column_descriptor: Column descriptor to update

        :return: :class:`models.ColumnDescriptor`
        """
        column_descriptor.live_report_id = live_report_id
        self.client.put(service_path=LIVE_REPORTS_PATH,
                        path='/{0}/columns/{1}'.format(live_report_id, column_descriptor.id),
                        data=column_descriptor.as_json())

        return self.column_descriptors(live_report_id, column_descriptor.column_id)[0]

    def add_columns(self, live_report_id, addable_columns):
        """
        Adds a model to the Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to add the models to

        :type addable_columns: List
        :param addable_columns: List of addable columns IDs

        :return: List of column id/name pairs in the Live Report
        """
        live_report = self.live_report(live_report_id=int(live_report_id))
        columns = live_report.addable_columns
        if columns:
            columns.extend(addable_columns)
        else:
            columns = addable_columns
        live_report.addable_columns = columns
        response = self.update_live_report(live_report_id, live_report)
        return [column for column in response.column_descriptor_mapping.iteritems()]

    def remove_columns(self, live_report_id, addable_columns):
        """
        Removes models from Live Report

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to add the models to

        :type addable_columns: List
        :param addable_columns: List of addable columns IDs

        :return: List of column id/name pairs in the Live Report
        """
        live_report = self.live_report(live_report_id=int(live_report_id))
        columns = live_report.addable_columns

        live_report.addable_columns = list(set(columns) - set(addable_columns))
        response = self.update_live_report(live_report_id, live_report)
        return [column for column in response.column_descriptor_mapping.iteritems()]

    def add_rows(self, live_report_id, additional_rows):
        """
        Add compounds to a LiveReport

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to add the compounds to

        :type additional_rows: List
        :param additional_rows: Corporate IDs of compounds to be added to the Live Report

        :return: List of compounds (additional_rows) in the Live Report
        """
        live_report = self.live_report(live_report_id=int(live_report_id))
        live_report.additional_rows.extend(additional_rows)
        return self.update_live_report(live_report_id, live_report).additional_rows

    def list_folders(self, project_ids=None):
        """
        Retrieves all available folders.

        :type project_ids: List of project ids
        :param project_ids: Limits the folders to those in the specified projects

        :return: List of :class:`models.Folder`
        """
        if not project_ids:
            project_ids = [project.id for project in self.projects()]
        project_ids = ensure_string_list(project_ids)

        response = self.client.get(service_path=FOLDERS_PATH,
                                   path="/live_reports",
                                   params={'project_ids': ','.join(project_ids)})
        return Folder.from_list(response)

    def project_tags(self, project_ids=None):
        """
        Retrieves all tags.

        :type project_ids: List of project ids
        :param project_ids: Limits the tags to those in the specified projects

        :return: List of :class:`models.Folder`
        """
        if not project_ids:
            project_ids = [int(project.id) for project in self.projects()]
        project_ids = ensure_string_list(project_ids)
        response = self.client.get(service_path=TAGS_PATH,
                                   path='',
                                   params={'project_ids': ','.join(project_ids)})
        return Folder.from_list(response)

    def create_tag(self, project_id, tag_name):
        """
        Creates a new folder

        :type tag_name: str
        :param tag_name: Name of the new tag

        :type project_id: str
        :param project_id: ID of the project for the tag

        :return: :class:`models.Folder`
        """
        params = {"name": tag_name,
                  "id": None,
                  "project_id": project_id}
        response = self.client.post(service_path=TAGS_PATH,
                                    path='',
                                    data=json.dumps(params))
        return Folder.from_dict(response)

    def ping(self):
        """
        Attempts to connect to the LiveDesign server

        :return: True if the connection was successful
        """
        return bool(self.client.get(service_path=ABOUT_PATH, path=''))

    def protocols(self, project_ids=None):
        """
        Retrieves list of protocols

        :type project_ids: List of project ids
        :param project_ids: Limits the protocols to those in the specified projects

        :return: List of :class:`models.Protocol`
        """
        if not project_ids:
            project_ids = [project.id for project in self.projects()]
        project_ids = ensure_string_list(project_ids)
        response = self.client.get(service_path=PROTOCOLS_PATH,
                                   path='',
                                   params={'project_ids': ','.join(project_ids)})
        return [Protocol.from_dict(protocol) for protocol in response]

    def protocol(self, protocol_id):
        """
        Retrieves a single protocol

        :type protocol_id: int
        :param protocol_id: ID of the protocol to retrieve

        :return: :class:`models.Protocol`
        """
        response = self.client.get(service_path=PROTOCOLS_PATH, path='/{0}'.format(protocol_id))
        return Protocol.from_dict(response)

    def get_protocol_id_by_name(self, protocol_name):
        """
        Searches for a protocol ID using the name

        :type protocol_name: str
        :param protocol_name: Name of the protocol

        :return: Protocol ID
        """
        matching_protocols = filter(lambda p: p.name == protocol_name, self.protocols())
        return int(matching_protocols[0].id) if matching_protocols else matching_protocols

    def create_or_update_protocol(self, protocol):
        """
        Creates or updates a protocol

        :type protocol: :class:`models.Protocol`
        :param protocol: Protocol object to save

        :return: :class:`models.Protocol`
        """
        existing_protocol_id = self.get_protocol_id_by_name(protocol.name)
        if existing_protocol_id:
            protocol.id = existing_protocol_id
            return self.update_protocol(protocol.id, protocol)
        else:
            return self.create_protocol(protocol)

    def create_protocol(self, protocol):
        """
        Creates a protocol

        :type protocol: :class:`models.Protocol`
        :param protocol: Protocol object to save

        :return: :class:`models.Protocol`
        """
        response = self.client.post(service_path=PROTOCOLS_PATH,
                                    path='',
                                    data=protocol.as_json())
        return Protocol.from_dict(response)

    def update_protocol(self, protocol_id, protocol):
        """
        Updates a protocol

        :type protocol: :class:`models.Protocol`
        :param protocol: Protocol object to update

        :return: :class:`models.Protocol`
        """
        response = self.client.put(service_path=PROTOCOLS_PATH,
                                   path='/{0}'.format(protocol_id),
                                   data=protocol.as_json())
        return Protocol.from_dict(response)

    def models(self, project_ids=None):
        """
        Retrieves list of models

        :type project_ids: List of project ids
        :param project_ids: Limits the models to those in the specified projects

        :return: List of :class:`models.Model`
        """
        if not project_ids:
            projects = self.projects()
            project_ids = [int(p.id) for p in projects]

        project_ids = ensure_string_list(project_ids)
        response = self.client.get(service_path=MODELS_PATH,
                                   path="",
                                   params={'project_ids': ','.join(project_ids)})
        return Model.from_list(response)

    def model(self, model_id):
        """
        Retrieves a single model

        :type model_id: int
        :param model_id: ID of the model to retrieve

        :return: :class:`models.Model`
        """
        # TODO(Osorio): Combine the model method with the get_model_id_by_name, and
        # get_model_by_name
        response = self.client.get(service_path=MODELS_PATH, path="/{0}".format(model_id))
        return Model.from_dict(response)

    def get_model_id_by_name(self, model_name):
        """
        Retrieves a single model

        :type model_name: str
        :param model_name: Name of the model to retrieve

        :return: Model ID
        """
        return int(self.get_model_by_name(model_name).id)

    def get_model_by_name(self, model_name):
        """
        Retrieves a single model

        :type model_name: str
        :param model_name: Name of the model to retrieve

        :return: :class:`models.Model`
        """
        matching_models = [m for m in self.models() if m.name == model_name]
        if len(matching_models) == 0:
            raise RuntimeError("No models found with name: {0}".format(model_name))

        if len(matching_models) > 1:
            raise RuntimeError("Multiple models found with name: {0}".format(model_name))

        return matching_models[0]

    def create_or_update_model(self, model):
        """
        Creates or updates a model

        :type model: :class:`models.Model`
        :param model: Model object to save

        :return: :class:`models.Model`
        """
        existing_model = self.get_model_by_name(model.name)
        if existing_model:
            model.id = existing_model.id
            model.default_version.id = existing_model.default_version.id
            return self.update_model(model.id, model)
        else:
            return self.create_model(model)

    def create_model(self, model):
        """
        Creates a model

        :type model: :class:`models.Model`
        :param model: Model object to save

        :return: :class:`models.Model`
        """
        response = self.client.post(service_path=MODELS_PATH,
                                    path="",
                                    data=model.as_json())
        new_model = Model.from_dict(response)
        files_uploaded = False

        # save files
        for file_macro in model.default_version.file_macro_values:
            if file_macro.file_contents:
                files_uploaded = True
                data = file_macro.as_dict()
                files = {'model_file': (file_macro.original_file_name, file_macro.file_contents)}
                self.client.post(service_path=MODEL_VERSIONS_PATH,
                                 path="/{0}/uploads".format(new_model.default_version.id),
                                 files=files,
                                 data=data,
                                 request_specific_headers={'Content-Type': 'multipart/form-data'})

        if files_uploaded:
            new_model = self.model(new_model.id)

        return new_model

    def update_model(self, model_id, model):
        """
        Updates an existing model

        :type model_id: int
        :param model_id: ID of the model to update

        :type model: :class:`models.Model`
        :param model: Model object to save

        :return: :class:`models.Model`
        """
        response = self.client.put(service_path=MODELS_PATH,
                                   path='/{0}'.format(model_id),
                                   data=model.as_json_string())
        return Model.from_dict(response)

    def model_versions(self):
        """
        Retrieves list of model versions

        :return: List of :class:`models.ModelVersion`
        """
        response = self.client.get(service_path=MODEL_VERSIONS_PATH, path="")
        return ModelVersion.from_dict(response)

    def model_version(self, model_version_id):
        """
        Retrieves a single model version

        :type model_version_id: int
        :param model_version_id: ID of the model version to retrieve

        :return: :class:`models.ModelVersion`
        """
        response = self.client.get(service_path=MODEL_VERSIONS_PATH,
                                   path='/{0}'.format(model_version_id))
        return ModelVersion.from_dict(response)

    def create_model_version(self, model_version):
        """
        Creates a model version

        :type model_version: :class:`models.ModelVersion`
        :param model_version: Model version object to save

        :return: :class:`models.ModelVersion`
        """
        data = model_version.as_json_string(standard_required=True, include_file_macros=False)
        response = self.client.post(service_path=MODEL_VERSIONS_PATH,
                                    path='',
                                    data=data)
        new_model_version = ModelVersion.from_dict(response)

        files_uploaded = False
        # save files
        for file_macro in model_version:
            if file_macro.file_contents:
                files_uploaded = True
                data = file_macro.as_dict
                files = {'model_file': (file_macro.original_file_name, file_macro.file_contents)}
                self.client.post(service_path=MODEL_VERSIONS_PATH,
                                 path='/{0}/upload'.format(new_model_version.id),
                                 files=files,
                                 data=data)

        if files_uploaded:
            new_model_version = self.model_version(new_model_version.id)

        return new_model_version

    def update_model_version(self, model_version_id, model_version):
        """
        Updates an existing model version

        :type model_version_id: int
        :param model_version_id: ID of the model version to update

        :type model_version: :class:`models.ModelVersion`
        :param model_version: Model version object to save

        :return: :class:`models.ModelVersion`
        """
        data = model_version.as_json_string(standard_required=False)
        response = self.client.put(service_path=MODEL_VERSIONS_PATH,
                                   path='/{0}'.format(model_version_id),
                                   data=data)
        return ModelVersion.from_dict(response)

    @staticmethod
    def get_tsv_import_settings(database_name='pri'):
        """
        Return a mapping for storing just structures and the Corporate ID
        """
        params = {
            "writeBackDbName": database_name,
            "delimiter": "\t",
            "sourceLiveReportId": 0,
            "filename": None,
            "propNameToReflect": None,
            "corpIdGenPolicy": "AUTO_GENERATE",
            "loadIntoDatabase": True,
            "published": True,
            "overwrite": False,
            "useAutoIdentifiers": False,
            "assayPerRowFormat": True,
            "truncatePermitted": True,
            "loadStructuresOnly": False,
            "fileHasHeader": True,
            "assay_per_row_format": True,
            "overwrite_permitted": False,
            "use_auto_identifiers": False,
            "truncate_permitted": True,
            "load_structures_only": False,
            "identifier_column_name": "Corporate ID",
            "file_has_header": True,
            "file_header": ["Corporate ID", "Lot Number", "Assay Name", "Expt Result Value",
                            "Expt Result Type", "Expt Result Units", "Expt Result Operator",
                            "Assay Protocol", "Expt Result Std Dev", "Expt Result Desc",
                            "Expt Date", "Expt Result Comment", "Expt Concentration",
                            "Expt Conc Units", "Expt Nb Page", "Expt Notebook",
                            "Expt Batch Number"],
            "data_mapping_column_names": ["Import?", "Name", "Data Type", "Model Type",
                                          "Name in File"],
            "data_mapping_rows": [
                [True, "Corporate ID", "String", "IDENTIFIER", "Corporate ID"],
                [True, "Lot Number", "Integer", "Lot Number", "Lot Number"],
                [True, "Assay Name", "String", "Assay Name", "Assay Name"],
                [True, "Expt Result Value", "Real", "Expt Result Value", "Expt Result Value"],
                [True, "Expt Result Type", "String", "Expt Result Type", "Expt Result Type"],
                [True, "Expt Result Units", "String", "Expt Result Units", "Expt Result Units"],
                [True, "Expt Result Operator", "String", "Expt Result Operator",
                 "Expt Result Operator"],
                [True, "Assay Protocol", "String", "Assay Protocol", "Assay Protocol"],
                [True, "Expt Result Std Dev", "String", "Expt Result Std Dev",
                 "Expt Result Std Dev"],
                [True, "Expt Result Desc", "String", "Expt Result Desc", "Expt Result Desc"],
                [True, "Expt Date", "String", "Expt Date", "Expt Date"],
                [True, "Expt Result Comment", "String", "Expt Result Comment",
                 "Expt Result Comment"],
                [True, "Expt Concentration", "String", "Expt Concentration", "Expt Concentration"],
                [True, "Expt Conc Units", "String", "Expt Conc Units", "Expt Conc Units"],
                [True, "Expt Nb Page", "String", "Expt Nb Page", "Expt Nb Page"],
                [True, "Expt Notebook", "String", "Notebook ID", "Expt Notebook"],
                [True, "Expt Batch Number", "String", "Expt Batch Number", "Expt Batch Number"]
            ]
        }

        return json.dumps(params)

    def start_export_assay_and_pose_data(self,
                                         project,
                                         mapping_file_name,
                                         data_file_name,
                                         sha1,
                                         corporate_id_column,
                                         live_report_name,
                                         published,
                                         properties,
                                         export_type='SDF',
                                         live_report_id=None):
        """
        Starts an upload of assay, pose and mapping data to Seurat.

        :type project: :class:`models.Project` or str
        :param project: Project object or project name to upload the data to

        :type mapping_file_name: str
        :param mapping_file_name: Name of the data map file

        :type data_file_name: str
        :param data_file_name: Name of the file to upload

        :type sha1: str
        :param sha1: Sha1 of the file to upload

        :type corporate_id_column: str
        :param corporate_id_column: Name of the column that contains the corporate id information

        :type live_report_name: str
        :param live_report_name: Name of the Live Report to be created

        :type published: bool
        :param published: Whether to make the data available system wide (True) or just for that
                Live Report (False).

        :type properties: List
        :param properties: List of dicts with the properties to be exported

        :type export_type: str
        :param export_type: "MAESTRO" for including pose data and "SDF" for no pose data

        :type live_report_id: int
        :param live_report_id: What Live Report to import the compounds to. If None, a new Live
                Report is created

        :return: the task_id of the import upload task
        """
        # TODO(Osorio): Combine the data export calls into one, and pass the format and endpoint
        #   selection (/, /web, /maestro) as a parameter
        # TODO(Osorio): Use a project object as the argument

        logger.info('Exporting as %s on project %s, mapping %s and data %s', export_type,
                    project, mapping_file_name, data_file_name)

        import_settings = {
            'identifier': corporate_id_column,
            'type': export_type,
            'project_name': project,
            'live_report_name': live_report_name,
            'source_live_report_id': live_report_id,
            'published': published,
            'new_live_report': live_report_id is None,
            'add_data_to_live_report': True,
            'compounds_only': False,  # Always false (if true it only registers)
            'assay_properties': [{'header_name': prop['name'],
                                  'assay_name': prop['model'],
                                  'assay_type': prop['endpoint'],
                                  'assay_units': prop['units']}
                                 for prop in properties]
        }

        data = {
            'import_settings': json.dumps(import_settings),
            'sha1': sha1
        }

        with open(mapping_file_name, 'rb') as mapping_file:
            mapping_data = mapping_file.read()

        with open(data_file_name, 'rb') as import_file:
            # The backend expects a base64 encoded file.
            import_data = base64.b64encode(import_file.read())

        files = {
            'mapping_data': (os.path.basename(mapping_file_name), mapping_data),
            'import_data': (os.path.basename(data_file_name), import_data)
        }

        response = self.client.post(IMPORT_PATH,
                                    '/maestro_task',
                                    data=data,
                                    files=files,
                                    request_specific_headers={'Content-Type': 'multipart/form-data'})
        return response['task_id']

    def wait_and_get_result_url(self, task_id):
        response = self.client.get(ASYNC_PATH,
                                   '/{0}'.format(task_id))
        timeout = time.time() + 60*20 # five minutes from now
        while response['status'] not in FINISHED_STATUS_TYPES:
            if time.time() > timeout:
                raise Exception("Timed out while waiting for export to finish")
            time.sleep(2)
            response = self.client.get(ASYNC_PATH,
                                       '/{0}'.format(task_id))

        if response['status'] != 'finished':
            raise Exception('Failed to export maestro data. Status = ' + response['status'])

        return response['result_url']

    def get_task_result(self, result_url):
        return self.client.get(result_url.replace("/api", "", 1), '')

    @staticmethod
    def get_sdf_import_settings(database_name='pri', generate_corp_ids=True):
        """
        Return a mapping for storing just structures and the Corporate ID
        """
        params = {
            "writeBackDbName": database_name,
            "delimiter": None,
            "sourceLiveReportId": 0,
            "filename": None,
            "propNameToReflect": None,
            "corpIdGenPolicy": "AUTO_GENERATE" if generate_corp_ids else "SPECIFIC_SDF_RECORD_PROPERTY",
            "loadIntoDatabase": True,
            "published": True,
            "overwrite": False,
            "useAutoIdentifiers": False,
            "assayPerRowFormat": False,
            "truncatePermitted": True,
            "loadStructuresOnly": True,
            "fileHasHeader": False,
            "assay_per_row_format": False,
            "overwrite_permitted": False,
            "use_auto_identifiers": False,
            "truncate_permitted": True,
            "load_structures_only": True,
            "identifier_column_name": "Corporate ID",
            "file_has_header": False,
            "file_header": None,
            "data_mapping_column_names": ["Import?", "Name", "Data Type", "Model Type",
                                          "Name in File", "Assay Name in DB", "Assay Type",
                                          "Assay Units", "Assay Conc", "Conc Units"],
            "data_mapping_rows": [
                [True, "Corporate ID", "String", "Identifier", "Corporate ID", "Corporate ID",
                 "", "", "", ""]
            ]
        }

        return json.dumps(params)

    def load_csv(self, live_report_id, filename):
        """
        Load compounds into Live Design via csv

        :type live_report_id: int
        :param live_report_id: ID of the Live Report to load the data to

        :type filename: str
        :param filename: Name of the csv file to load

        :return: a list of dict objects - with each one representing a compound from the original
                        project table - containing data on that compound returned from the server.
        """

        import_settings = {
            "identifier": "SMILES",
            "type": "CSV_ROW_PER_COMPOUND",
            "project_name": "Global",
            "live_report_name": None,
            "source_live_report_id": live_report_id,
            "published": False,
            "new_live_report": False,
            "compounds_only": True,
            "add_data_to_live_report": True
        }

        data = {'import_settings': json.dumps(import_settings)}
        files = {'import_data': (filename, open(filename, 'rb'), '')}
        logger.debug("Loading csv file %s into LiveDesign..." % filename)
        response = self.client.post(service_path=IMPORT_PATH,
                                    path='/web',
                                    data=data,
                                    files=files,
                                    request_specific_headers={'Content-Type': 'multipart/form-data'})
        return response['response']['import_responses']

    def register_compounds_sdf(self, project_name, file_contents, file_name,
                               use_corporate_id=False):
        """
        Register a set of compounds with the Seurat Server.

        :type project_name: str
        :param project_name: Name of the project to put the compounds in

        :type file_contents: fp
        :param file_contents: the actual string file contents of the SD file to be exported to
                Seurat

        :type file_name: str
        :param file_name: Name of the file to be used as a reference for the import by the server

        :type use_corporate_id: bool
        :param use_corporate_id: If True, the 'Corporate ID' field in the sdf will be used for
                registration

        :return: a list of dict objects - with each one representing a compound from the original
                project table - containing data on that compound returned from the server.
        """
        # TODO(Osorio): Combine the registration calls into one, and pass the format and endpoint
        #   selection (/, /web, /maestro) as a parameter
        logger.info('Making registration call on project %s, with file %s'
                    % (project_name, file_name))

        export_type = 'SDF'

        import_settings = {
            'type': export_type,
            'project_name': project_name,
            'compounds_only': True,
            'published': False,
            }

        if use_corporate_id:
            import_settings['identifier'] = 'Corporate ID'

        data = {
            'import_settings': json.dumps(import_settings),
            'sha1': hashlib.sha1(file_contents).hexdigest()
        }

        files = {
            'import_data': (file_name, file_contents)
        }

        response = self.client.post(IMPORT_PATH,
                                    '/',
                                    data=data,
                                    files=files,
                                    request_specific_headers={'Content-Type': 'multipart/form-data'})

        self._process_import_responses(response['import_responses'])
        return response['import_responses']

    @staticmethod
    def _process_import_responses(import_responses):
        error_messages = []
        general_messages = []
        failed = False

        for import_response in import_responses:
            if not import_response['success']:
                if import_response['messages']:
                    error_messages.append('\n'.join(import_response['messages']))
                failed = True
            else:
                if import_response['messages']:
                    general_messages.append('\n'.join(import_response['messages']))

        if general_messages:
            logger.info('Message from Server was: %s' % '\n'.join(general_messages))
        if failed:
            logger.error('Registration failed, responses: %s', import_responses)
            if error_messages:
                raise ServerProcessingError('\n'.join(error_messages))
            raise ServerProcessingError('An error occurred while registering compounds. '
                                        'Please contact your administrator.')

    def register_compounds_via_csv(self,
                                   project_name,
                                   file_contents,
                                   column_identifier,
                                   file_name,
                                   published=False,
                                   live_report_id=None,
                                   import_assay_data=False):
        """
        Register a set of compounds with the Seurat Server.

        :type project_name: str
        :param project_name: Name of the project to put the compounds in

        :type file_contents: file
        :param file_contents: The actual file contents of the SD file to be exported to Seurat.
                     Must be open(file,'rb')

        :type file_name: str
        :param file_name: Name of the file to be used as a reference for the import by the server

        :return: List of corporate IDs
        """
        logger.info('Making csv registration call on project %s, with file %s'
                    % (project_name, file_name))

        import_settings = {
            'project_name': project_name,
            'identifier': column_identifier,
            'published': published,
            'type': 'CSV_ROW_PER_COMPOUND',
            'source_live_report_id': live_report_id,
            'live_report_name': None,
            'new_live_report': False,
            'compounds_only': not import_assay_data,
            'add_data_to_live_report': import_assay_data,
            }

        data = {'import_settings': json.dumps(import_settings)}

        files = {'import_data': (file_name, file_contents, 'application/vnd.ms-excel')}

        response = self.client.post(IMPORT_PATH,
                                    '/web',
                                    data=data,
                                    files=files,
                                    request_specific_headers={'Content-Type': 'multipart/form-data'})
        corporate_ids = []
        if not response['success']:
            logger.error('failed to load csv data')
            raise Exception('failed to load csv data')

        return [r['corporate_id'] for r in response['response']['import_responses']]

    def load_sdf(self, live_report_id, filename, project_name="Global", compounds_only=False):
        """
        Load compounds into Live Design via sdf /web

        :type live_report_id: int
        :param live_report_id:

        :type filename: str
        :param filename: Name of the sdf file to load

        :type project_name: str
        :param project_name: Project to load the data to

        :type compounds_only: bool
        :param compounds_only: If True, the non-structure data of the SDF will be ignored

        :return: List: import_responses
        """
        import_settings = {
            "identifier": None,
            "type": "SDF",
            "project_name": project_name,
            "live_report_name": None,
            "source_live_report_id": live_report_id,
            "published": False,
            "new_live_report": False,
            "compounds_only": compounds_only,
            "add_data_to_live_report": True,
            }
        data = {'import_settings': json.dumps(import_settings)}
        with open(filename, 'rb') as input_file:
            files = {'import_data': input_file}
            logger.debug('loading sdf data %s into LiveDesign...' % filename)
            response = self.client.post(IMPORT_PATH,
                                        '/web',
                                        data=data,
                                        files=files,
                                        request_specific_headers={
                                            'Content-Type': 'multipart/form-data'})
        return response['response']['import_responses']

    def get_project_id_by_name(self, project_name):
        """
        Retrieves a single project

        :type project_name: str
        :param project_name: Name of the project to retrieve

        :return: ID of the matching project
        """
        matching_projects = filter(lambda p: p.name == project_name, self.projects())
        return int(matching_projects[0].id) if matching_projects else matching_projects

    def projects(self):
        """
        Get all projects

        :return: List of :class:`models.Project` objects
        """
        response = self.client.get(PROJECTS_PATH, '')
        return Project.from_list(response)

    def export_xtals(self, sources, file_format='pse'):
        """
        Trigger the export of 3D model files (a.k.a. xtals)

        :type sources: List of dicts
        :param sources: Specifies the 3D models that should be exported.
                Each dict should have the following keys: model_name, corporate_id, pose_id,
                file_name, and structure_type.

        :type file_format: str
        :param file_format: The format of the 3D model file to be exported; either "pse" or "mol2"

        :type json_response: bool
        :param json_response: If True, gets a json object from the server

        :return: The ID of the requested export task
        :rtype: string
        """
        data = {
            'export_sources': sources or [],
            'format': file_format,
        }
        response = self.client.post(service_path=XTALS_PATH,
                                    path='',
                                    json_response=True,
                                    data=json.dumps(data))
        if 'id' not in response:
            raise RuntimeError("Unexpected response received from LiveDesign server: "
                               "{!r}".format(response))
        return response['id']

    def export_xtals_status(self, export_id):
        """
        Check the status of a given xtals export

        :type export_id: string
        :param export_id: The ID of an export task, as returned by export_xtals()

        :type json_response: bool
        :param json_response: If True, gets a json object from the server

        :return: The status of the specified export task: a dict with "code" and "message" keys
        :rtype: dict
        """
        response = self.client.get(service_path=XTALS_PATH,
                                   json_response=True,
                                   path='/{0}/status'.format(export_id))
        if 'status' not in response:
            raise RuntimeError("Unexpected response received from LiveDesign server: "
                               "{!r}".format(response))
        return response['status']

    def export_xtals_result(self, export_id):
        """
        Get the content from an xtals export. This won't work unless export_xtals_status() returns
        a status code of "ready".

        :type export_id: string
        :param export_id: The ID of an export task, as returned by export_xtals()

        :return: The content of the exported 3D model file
        :rtype: bytes
        """
        params = {'type': ''} # to ensure that a JSON response isn't requested

        # If the exported files tend to be large, we may later choose to use the stream=True option
        # for the HTTP request so that we can return an iterater over the response content rather
        # than a string containing the whole file at once.
        try:
            response = self.client.get(service_path=XTALS_PATH,
                                       json_response=False,
                                       params=params,
                                       path='/{0}/result'.format(export_id))
        except requests.exceptions.HTTPError as err:
            if err.response is None:
                raise
            elif err.response.status_code == 404:
                raise RuntimeError("Export task with ID {} is not finished yet "
                                   "or a server-side file was not found".format(export_id))
            elif err.response.status_code == 500:
                raise RuntimeError("Export task with ID {} does not exist "
                                   "or a server-side I/O error occurred".format(export_id))
            else:
                raise
        return response

    def get_or_create_attachment(self,
                                 attachment_file_name,
                                 file_type,
                                 project_ids,
                                 alternate_id=None):
        """
        Get a attachment by its file data, file_name, file_type and ACLs if it exist, or upload an attachment and
        persist it in LiveDesign

        :param attachment_file_name: path to the file to be uploaded
        :param file_type: type of file. Either IMAGE, ATTACHMENT, or THREE_D
        :param project_ids: projects the file should have ACLs on
        :param alternate_id: ID for the file. MUST be unique in LiveDesign if not null. Otherwise generated on creation
        :return: the content of the persisted attachment
        :rtype: dict
        """
        attachment_settings = {
            "id" : alternate_id,
            "file_name" : attachment_file_name,
            "file_type" : file_type,
            "project_id" : project_ids
        }
        data = {
            "attachment_settings" : json.dumps(attachment_settings)
        }

        with open(attachment_file_name, 'rb') as attachment_file:
            attachment_data = attachment_file.read()

        files = {
            "attachment_data" : attachment_data
        }

        return self.client.post(ATTACHMENT_PATH,
                                '/',
                                data=data,
                                files=files,
                                request_specific_headers={'Content-Type': 'multipart/form-data'})

    def get_or_create_pose(self,
                           column_id,
                           ligand_attachment_ids,
                           ligand_entity_id,
                           project_id,
                           published=False,
                           protein_attachment_ids=None):
        """
        Get a pose or create pose data on a column if it does not exist. New pose data must be created before hand
        via create_attachment

        :param column_id: column to put pose data on
        :param ligand_attachment_ids: ligand data on the pose (created via create_attachment)
        :param ligand_entity_id: entity id of the compound to put the pose data on
        :param protein_attachment_ids: protein data on the pose (created via create_attachment)
        :param published: whether or not the created pose should be published
        :param project_id: ACL on the pose
        :return: the content of the created pose
        :rtype: dict
        """
        ligand = {
            "attachment_ids" : ligand_attachment_ids,
            "entity_id" : ligand_entity_id
        }
        if protein_attachment_ids is None:
            protein = None
        else:
            protein = {
                "attachment_ids" : protein_attachment_ids
            }

        pose = {
            "ligand" : ligand,
            "protein" : protein,
            "column_id" : column_id,
            "published" : published,
            "project_id" : project_id
        }

        return self.client.post(POSE_PATH,
                                '/',
                                data=json.dumps(pose))

    def update_columns(self,
                    columns):
        """
        Update configs for specific columns

        :param columns: list of columns objects to update
        :return: updated column list
        """

        return self.client.put(service_path=CONFIG_PATH,
                            path='/columns/batch', 
                            data=json.dumps([column.as_dict() for column in columns]))

class ApiClient(object):
    """ Class to handle HTTP verbs """
    _verified_version = False

    def __init__(self, host, username, password):
        self.host = host
        self.username = username
        self.password = password

    def get(self, service_path, path, **kwargs):
        return self.invoke_request(service_path, path, http_method=requests.get, **kwargs)

    def post(self, service_path, path, **kwargs):
        return self.invoke_request(service_path, path, http_method=requests.post, **kwargs)

    def delete(self, service_path, path, **kwargs):
        return self.invoke_request(service_path, path, http_method=requests.delete, **kwargs)

    def put(self, service_path, path, **kwargs):
        return self.invoke_request(service_path, path, http_method=requests.put, **kwargs)

    def _verify_version(self):
        self._verified_version = True
        response = self.get(ABOUT_PATH, '')
        ld_version = response['seurat_version_number']
        if SUPPORTED_LD_VERSION not in ld_version:
            msg = 'Unsupported Live Design server version: {server}, expected version: {client}'
            logger.warn(msg.format(server=ld_version, client=SUPPORTED_LD_VERSION))

    def invoke_request(self, service_path, path, http_method, params=None, data=None, files=None,
                       json_response=True, request_specific_headers = {}):
        """
        Make a general request to the Seurat Server

        Args:
            service_path: 
            path: A string that is the addition to the Seurat Base URL
                specifying the method (e.g. '/scientists')
            http_method: The actual function from the restclient library to
                be invoked
            params: A dict mapping query string parameters to their
                respective values (default: {}) 
            data: POST params (dict or plain string)
            files: The files to upload

        Returns:
            The JSON-loaded response from the server, with no alterations

        Raises:
            requests.exceptions.HTTPError if request fails
        """

        # Lazily checks that the client version matches the LiveDesign
        # server version the first time an API call is made
        if not self._verified_version:
            self._verify_version()

        if params is None:
            params = {}
        else:
            params = copy.copy(params)
        url = ('%s%s%s' % (self.host, service_path, path))
        logger.info("About to request %s" % url)
        logger.info("Using params %s" % params)
        logger.info("Using data %s" % data)
        auth = HTTPBasicAuth(self.username, self.password)
        if 'type' not in params:
            params['_type'] = 'json'

        if json_response:
            headers = {
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            }
        else:
            headers = {}
        headers.update(request_specific_headers)
        logger.info("Using headers %s" % headers)

        proxies = {
            # "http": "http://127.0.0.1:8888",
        }

        response = http_method(url, params=params, data=data, auth=auth, headers=headers,
                               files=files, proxies=proxies, verify=False)

        response.raise_for_status()

        # Sometimes if there's no response content we don't need to JSON-load it.
        if response.content == "":
            return response.content
        if json_response:
            return json.loads(response.content)

        return response.content
