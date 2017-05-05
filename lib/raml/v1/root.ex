defmodule Ramoulade.Raml.V1.Root do
  defstruct [
    :title,
    :media_type,
    :description,
    :version,
    :base_uri,
    :base_uri_parameters,
    :protocols,
    :media_type,
    :documentation,
    :schemas,
    :types,
    :traits,
    :resource_types,
    :annotation_types,
    :annotations,
    :security_schemas,
    :secure_by,
    :users,
    :relative_uri
  ]

  alias Ramoulade.Raml.Validations

  @type parse_result(t) :: t | {:error, String.t}

  @spec from_parsed_yaml(map) :: parse_result(%__MODULE__{})
  def from_parsed_yaml(yaml) do
    yaml
    |> validate
    |> new
  end

  def new(yaml) do
    %__MODULE__{
      title: yaml["title"],
      media_type: yaml["mediaType"],
      description: yaml["description"],
      version: yaml["version"],
      base_uri: Ramoulade.Raml.V1.BaseUri.from_parsed_yaml(yaml),
      protocols: yaml["protocols"],
      media_type: yaml["mediaType"],
      documentation: yaml["documentation"],
      #TODO:
      # documentation, schemas, types, traits, resource_types, annotation_types, annotations,
      # security_schemes, secured_by, uses, relative_ur
    }
  end

  def validate(yaml) do
    yaml
    |> Validations.mutually_exclusive("schemas", "types")
    |> Validations.required("title")
  end
end
