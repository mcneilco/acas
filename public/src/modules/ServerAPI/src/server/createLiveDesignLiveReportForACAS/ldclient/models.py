import copy
import json


def ensure_string_list(list_to_convert):
    return [str(potential_integer) for potential_integer in list_to_convert]


class BaseModel(object):
    _fields = []

    def as_dict(self):
        """
        :return: The instance as a dict
        """
        data = {}
        for field in self._fields:
            method = 'serialize_{0}'.format(field)
            if hasattr(self, method):
                value = getattr(self, method)()
            else:
                value = getattr(self, field)

            data[field] = value

        return data

    def as_json(self, **kwargs):
        """
        :return: The instance as a Json string
        """
        return json.dumps(self.as_dict(), **kwargs)

    @classmethod
    def from_dict(cls, data):
        local_data = {}
        for field in cls._fields:
            if field in data:
                field_data = copy.deepcopy(data[field])
                method = 'deserialize_{0}'.format(field)
                if hasattr(cls, method):
                    local_data[field] = getattr(cls, method)(field_data)
                else:
                    local_data[field] = field_data
        return cls(**local_data)

    @classmethod
    def from_json(cls, data):
        return cls.from_dict(json.loads(data))

    @classmethod
    def from_list(cls, arr):
        return [cls.from_dict(elem) for elem in arr]


class Project(BaseModel):

    _fields = ['id', 'name', 'active', 'alternate_id', 'default_template_id', 'description', 'restricted']

    def __init__(self,
                 id=None,
                 name=None,
                 active='Y',
                 alternate_id=None,
                 default_template_id=0,
                 description=None,
                 restricted=False):
        self.id = id
        self.name = name
        self.active = active
        self.alternate_id = alternate_id
        self.default_template_id = default_template_id
        self.description = description
        self.restricted = restricted


class AssayType(BaseModel):
    """ Each column in a report is an assay type. """

    _fields = ['name', 'count', 'addable_column_id', 'value_type']

    def __init__(self, name, count=None, addable_column_id=None, value_type=None):
        self.name = name
        self.count = count
        self.addable_column_id = addable_column_id
        self.value_type = value_type


class Assay(BaseModel):
    """ An assay contains at least one type, and may contain a url"""

    _fields = ['protocol', 'name', 'database_name', 'project_ids', 'units', 'lot',
               'concentration_units', 'concentration', 'types', 'folder_path']

    def __init__(self,
                 name,
                 types,
                 protocol=None,
                 database_name=None,
                 project_ids=None,
                 units=None,
                 lot=None,
                 concentration_units=None,
                 concentration=None,
                 folder_path=None):
        self.protocol = protocol
        self.name = name
        self.database_name = database_name
        self.project_ids = project_ids
        self.units = units
        self.lot = lot
        self.concentration_units = concentration_units
        self.concentration = concentration
        self.types = types
        self.folder_path = folder_path

    def serialize_types(self):
        return [array_type.as_dict() for array_type in self.types]

    @staticmethod
    def deserialize_types(types):
        return AssayType.from_list(types)

class Column(BaseModel):

    _fields = ['id', 'name', 'column_type', 'value_type', 'log_scale', 'project_ids', 'folder_name']

    def __init__(self,
                 id=None,
                 name=None,
                 column_type=None,
                 value_type=None,
                 log_scale=None,
                 project_ids=None,
                 folder_name=None):
        self.id = id
        self.name = name
        self.column_type = column_type
        self.value_type = value_type
        self.log_scale = log_scale
        self.project_ids = project_ids
        self.folder_name = folder_name

# move backup above assaytype
class Rationale(BaseModel):

    _fields = ['description', 'user_name', 'corporate_id', 'live_report_id', 'id',
               'default', 'created_at', 'updated_at']

    def __init__(self,
                 description="",
                 user_name="",
                 corporate_id=None,
                 live_report_id=None,
                 default=None,
                 id=None,
                 created_at=None,
                 updated_at=None):
        self.description = description
        self.user_name = user_name
        self.corporate_id = corporate_id
        self.live_report_id = live_report_id
        self.default = default
        self.id = id
        self.created_at = created_at
        self.updated_at = updated_at


class Database(BaseModel):

    _fields = ['name', 'projects', 'ideas', 'writeback', 'primary']

    def __init__(self, name, projects=None, ideas=True, primary=True, writeback=True):
        self.name = name
        self.projects = projects
        self.primary = primary
        self.writeback = writeback
        self.ideas = ideas


class ViewSelection(BaseModel):

    _fields = ['operator', 'value']

    def __init__(self, operator, value):
        self.operator = operator
        self.value = value


class LiveReport(object):
    NEVER = 'never'
    BY_CACHEBUILDER = 'by_cachebuilder'
    WHEN_OPENED = 'when_opened'

    def __init__(self,
                 title,
                 description='',
                 update_policy=BY_CACHEBUILDER,
                 template=False,
                 shared_editable=True,
                 view_selection=None,
                 default_rationale=None,
                 assay_view=None,
                 id=None,
                 alias=None,
                 project_id=0,
                 owner=None,
                 is_private=False,
                 active=True,
                 columns_order=None,
                 additional_rows=None,
                 addable_columns=None,
                 tags=None,
                 last_saved_date=None,
                 column_descriptor_mapping=None,
                 sorted_columns=None,
                 hidden_rows=None,
                 scaffolds=None):
        self.title = title
        self.description = description
        self.update_policy = update_policy
        self.template = template
        self.shared_editable = shared_editable
        self.view_selection = view_selection
        self.default_rationale = default_rationale
        self.assay_view = assay_view
        self.id = id
        self.alias = alias
        self.project_id = str(project_id)
        self.owner = owner
        self.is_private = is_private
        self.active = active
        self.additional_rows = additional_rows
        self.addable_columns = addable_columns
        default_columns_order = ["Compound Structure", "Corporate ID", "Rationale",
                                 "Lot Scientist", "Lot Date Registered"]
        self.columns_order = columns_order if columns_order else default_columns_order
        self.tags = tags if tags else []
        self.last_saved_date = last_saved_date
        self.column_descriptor_mapping = column_descriptor_mapping
        self.sorted_columns = sorted_columns if sorted_columns else []
        self.hidden_rows = hidden_rows if hidden_rows else []
        self.scaffolds = scaffolds if scaffolds else []

    def as_json_string(self, standard_required=True):
        return json.dumps(self.as_dict(standard_required=standard_required))

    def as_dict(self, standard_required=True):
        data = {}
        if self.title or standard_required:
            data['title'] = self.title
        if self.description or standard_required:
            data['description'] = self.description
        if self.owner or standard_required:
            data['owner'] = self.owner
        if self.last_saved_date or standard_required:
            data['last_saved_date'] = self.last_saved_date
        if self.column_descriptor_mapping or standard_required:
            data['column_descriptor_mapping'] = self.column_descriptor_mapping
        if self.sorted_columns or standard_required:
            data['sorted_columns'] = self.sorted_columns
        if self.hidden_rows or standard_required:
            data['hidden_rows'] = self.hidden_rows
        if self.scaffolds or standard_required:
            data['scaffolds'] = self.scaffolds
        if self.owner or standard_required:
            data['owner'] = self.owner
        if self.additional_rows or standard_required:
            data['additional_rows'] = self.additional_rows
        if self.addable_columns:
            data['addable_columns'] = self.addable_columns
        if self.tags or standard_required:
            data['tags'] = self.tags
        if self.update_policy or standard_required:
            data['update_policy'] = self.update_policy
        if self.template or standard_required:
            data['template'] = self.template
        if self.is_private or standard_required:
            data['is_private'] = self.is_private
        if self.active or standard_required:
            data['active'] = self.active
        if self.shared_editable or standard_required:
            data['shared_editable'] = self.shared_editable
        if self.view_selection:
        #TODO (tso): this should be standard_required but is not here due to get_live_report always
        # returning null for this value
            data['view_selection'] = self.view_selection.as_dict()
        if self.default_rationale:
            data['default_rationale'] = self.default_rationale
        if self.columns_order:
            data['columns_order'] = self.columns_order
        if self.assay_view:
            data['assay_view'] = self.assay_view.as_dict()
        if self.id or standard_required:
            data['id'] = self.id
        if self.alias:
            data['alias'] = self.alias
        if self.project_id:
            data['project_id'] = self.project_id
        return data

    @staticmethod
    def from_dict(data):
        addable_columns = data.get('addable_columns')
        alias = data.get('alias')

        if data.get('assay_view'):
            assay_view = ViewMap.from_dict(data['assay_view'])
        else:
            assay_view = None

        if 'view_selection' in data:
            view_selection = ViewSelection.from_dict(data['view_selection'])
        else:
            view_selection = None
        column_descriptor_mapping = data.get('column_descriptor_mapping')

        default_rationale = data.get('default_rationale')

        return LiveReport(title=data['title'],
                          description=data['description'],
                          owner=data['owner'],
                          is_private=data['is_private'],
                          update_policy=data['update_policy'],
                          template=data['template'],
                          active=data['active'],
                          shared_editable=data['shared_editable'],
                          view_selection=view_selection,
                          columns_order=data['columns_order'],
                          additional_rows=data['additional_rows'],
                          addable_columns=addable_columns,
                          tags=data['tags'],
                          last_saved_date=data['last_saved_date'],
                          column_descriptor_mapping=column_descriptor_mapping,
                          sorted_columns=data['sorted_columns'],
                          hidden_rows=data['hidden_rows'],
                          default_rationale=default_rationale,
                          assay_view=assay_view,
                          id=data['id'],
                          alias=alias,
                          project_id=data.get('project_id'))

    @classmethod
    def from_list(cls, arr):
        return [cls.from_dict(elem) for elem in arr]


class ModelReturn(BaseModel):
    """
    A model predictions object
    Allowed types: Real, Integer, String, Boolean
    """

    _fields = ['name', 'type', 'units', 'database_name', 'decimal_places', 'addable_column_id']

    def __init__(self, name, type, units, database_name, decimal_places=1, addable_column_id=None):
        self.name = name
        self.type = type
        self.units = units
        self.decimal_places = decimal_places
        self.database_name = database_name
        self.addable_column_id = addable_column_id


class TextMacroValue(BaseModel):

    _fields = ['name', 'value']

    def __init__(self, name, value):
        self.name = name
        self.value = value


class FileMacroValue(BaseModel):

    _fields = ['macro_name', 'original_file_name', 'id', 'file_contents']

    def __init__(self, macro_name, original_file_name, id=None, file_contents=''):
        self.macro_name = macro_name
        self.original_file_name = original_file_name
        self.id = id
        self.file_contents = file_contents


class ModelVersion(BaseModel):
    """
    template and protocol are synonymous
    """

    _fields = ['name', 'description', 'template_id', 'returns', 'parameters', 'realtime', 'user',
               'observation_source_id', 'text_macro_values', 'visible', 'id',
               'external_property_id']

    def __init__(self,
                 name,
                 description,
                 template_id,
                 returns,
                 parameters=None,
                 observation_source_id='',
                 user='',
                 realtime=False,
                 text_macro_values='',
                 file_macro_values=None,
                 uploadedFiles=None,
                 visible=True,
                 external_property_id="",
                 id=None):
        self.name = name
        self.description = description
        self.template_id = self.protocol_id=template_id
        self.returns = returns
        self.parameters = parameters
        self.observation_source_id = observation_source_id
        self.user = user
        self.realtime = realtime
        self.text_macro_values = text_macro_values if text_macro_values else []
        self.file_macro_values = file_macro_values if file_macro_values else []
        self.uploadedFiles = uploadedFiles
        self.visible = visible
        self.external_property_id = external_property_id
        #should this allow "" instead of None?
        self.id = id

    def serialize_text_macro_values(self):
        return [tmv.as_dict() for tmv in self.text_macro_values]

    def serialize_file_macro_values(self):
        return [fmv.as_dict() for fmv in self.file_macro_values]

    def serialize_returns(self):
        return [prediction.as_dict() for prediction in self.returns]

    @staticmethod
    def deserialize_text_macro_values(values):
        return TextMacroValue.from_list(values)

    @staticmethod
    def deserialize_file_macro_values(values):
        return FileMacroValue.from_list(values)

    @staticmethod
    def deserialize_returns(returns):
        return ModelReturn.from_list(returns)


class Model(BaseModel):

    _fields = ['id', 'name', 'visible', 'display_column_type', 'user', 'folder_path',
               'project_ids', 'property_type', 'default_version', 'defaultVersionId']

    def __init__(self,
                 name,
                 folder_path,
                 default_version,
                 visible=True,
                 user='',
                 display_column_type=None,
                 defaultVersionId='',
                 project_ids=None,
                 property_type='compound',
                 id=None):
        """
        valid values for display_column_type are "computational_model" or "computed_property"
        folder_path:  "User Defined/<username>" or "Physicochemical Descriptors"
        """
        self.name = name
        self.folder_path = folder_path
        self.default_version = default_version
        self.visible = visible
        self.user = user
        self.display_column_type = display_column_type
        self.defaultVersionId = defaultVersionId
        self.project_ids = ["0"] if not project_ids else ensure_string_list(project_ids)
        self.property_type = property_type
        self.id = id

    def serialize_default_version(self):
        return self.default_version.as_dict()

    @staticmethod
    def deserialize_default_version(data):
        if data:
            return ModelVersion.from_dict(data)
        else:
            return None


class DefaultVersion(BaseModel):
    _fields = ['id', 'name', 'description', 'user', 'visible', 'realtime', 'template_id',
               'external_property_id', 'text_macro_values', 'parameters', 'returns',
               'observation_source_id']

    def __init__(self,
                 name,
                 description,
                 visible,
                 realtime=False,
                 template_id=None,
                 text_macro_values=None,
                 parameters=None,
                 returns=None,
                 user=None,
                 external_property_id=None,
                 observation_source_id=None,
                 id=None,
                 file_macro_values=None,
                 uploadedFiles=None):
        self.id = id
        self.name = name
        self.description = description
        self.user = user
        self.visible = visible
        self.realtime = realtime
        self.template_id = template_id
        self.external_property_id = external_property_id
        self.text_macro_values = text_macro_values
        self.parameters= parameters
        self.returns = returns
        self.observation_source_id = observation_source_id

        self.file_macro_values = file_macro_values
        self.uploadedFiles = uploadedFiles

    def serialize_text_macro_values(self):
        return [tmv.as_dict() for tmv in self.text_macro_values]

    def serialize_returns(self):
        return [ret.as_dict() for ret in self.returns]

    @staticmethod
    def deserialize_text_macro_values(values):
        return TextMacroValue.from_list(values)

    @staticmethod
    def deserialize_returns(values):
        return ModelReturn.from_list(values)


class Folder(BaseModel):

    _fields = ['name', 'id', 'project_id']

    def __init__(self, name, id, project_id):
        """
        [{"id":"18330","name":"blc","project_id":"10"}]
        valid values for display_column_type are "computational_model" or "computed_property"
        folder_path:  "User Defined/<username>" or "Physicochemical Descriptors"
        """
        self.name = name
        self.id = id
        self.project_id = project_id


#TODO: do we need to manage the 'macros' field that comes from a get when we do an update or is
# this set automatically?
class Protocol(BaseModel):

    _fields = ['name', 'process_command', 'description', 'job_id_format', 'pre_process_command',
               'post_process_command', 'driver', 'visible', 'user_name', 'id', 'macros',
               'batch_size']

    def __init__(self,
                 name,
                 process_command,
                 description='',
                 pre_process_command='',
                 post_process_command='',
                 job_id_format='',
                 driver='sync',
                 visible=True,
                 user_name='',
                 id=None,
                 macros=None,
                 batch_size=1):
        self.name = name
        self.visible = visible
        self.driver = driver
        self.process_command = process_command
        self.description = description
        self.pre_process_command = pre_process_command
        self.post_process_command = post_process_command
        self.job_id_format = job_id_format
        self.batch_size = int(batch_size)
        self.macros = macros
        # TODO(Osorio): Cleanup
        #this seems to be ignored currently
        self.user_name = user_name
        self.id = id


class ColumnDescriptor(BaseModel):
    """
    The result of executing a live report
    """

    _fields = ['column_id', 'addable_column_id', 'live_report_id', 'display_name', 'width', 'color_styles', 'filters',
               'decimal_formats', 'hidden', 'id']

    def __init__(self, column_id, addable_column_id=None, live_report_id=None, display_name=None, width=None,
                 color_styles=None, filters=None, decimal_formats=None, hidden=False, id=None):
        self.column_id = column_id
        self.addable_column_id = addable_column_id
        self.live_report_id = live_report_id
        self.display_name = display_name if display_name else column_id
        self.width = width
        self.color_styles = color_styles if color_styles else []
        self.filters = filters if filters else []
        self.decimal_formats = decimal_formats
        self.hidden = hidden
        self.id = id


class Parameter(BaseModel):

    _fields = ['operator', 'value', 'runtime', 'display']

    def __init__(self, operator, value, runtime, display=None):
        self.operator = operator
        self.value = value
        self.runtime = runtime
        self.display = display

class ViewMap(BaseModel):

    _fields = ['color_styles']

    def __init__(self, color_styles):
        self.color_styles = color_styles if color_styles else []

    def serialize_color_styles(self):
        return [style.as_dict() for style in self.color_styles]

    @staticmethod
    def deserialize_color_styles(styles):
        return ColorStyle.from_list(styles)


class ColorStyle(BaseModel):

    _fields = ['color_column', 'color_low', 'color_high', 'range_low', 'range_high', 'source_column',
               'value_low', 'value_high', 'color_object', 'log_scale', 'matching_string']

    def __init__(self,
                 color_column,
                 color_low,
                 color_high,
                 range_low,
                 range_high,
                 source_column,
                 value_low,
                 value_high,
                 color_object=False,
                 log_scale=False,
                 matching_string=None):
        self.color_column = color_column
        self.color_low = color_low
        self.color_high = color_high
        self.range_low = range_low
        self.range_high = range_high
        self.source_column = source_column
        self.value_low = value_low
        self.value_high = value_high
        self.color_object = color_object
        self.log_scale = log_scale
        self.matching_string = matching_string


class LiveReportResult(object):
    """The result of executing a live report"""

    _fields = ['columns', 'results']

    def __init__(self, columns, results):
        self.columns = columns
        self.results = results


class SchrodingerException(Exception):
    @property
    def message(self):
        """Returns the first argument used to construct this error."""
        return self.args[0]


class InvalidArgumentException(SchrodingerException):
    pass
