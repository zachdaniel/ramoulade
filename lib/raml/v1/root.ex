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

  def from_yaml(document, yaml) do
    _ = validate!(document, yaml)

    %__MODULE__{
      title: yaml["title"],
      description: yaml["description"]
    }
    |> add_version(document, yaml)
    |> add_documentation(document, yaml)
  end

  def add_version(root, _document, yaml) do
    if yaml["version"] do
      Map.put(root, :version, Version.parse!("#{yaml["version"]}"))
    else
      root
    end
  end

  def add_documentation(root, document, yaml) do
    if yaml["documentation"] do
      Map.put(root, :documentation, Ramoulade.Raml.V1.Documentation.from_yaml(yaml["documentation"], document))
    end
  end

  def new(yaml) do
    %__MODULE__{
      title: yaml["title"],
      media_type: yaml["mediaType"],
      description: yaml["description"],
      version: yaml["version"],
      # base_uri: Ramoulade.Raml.V1.BaseUri.from_parsed_yaml(yaml),
      protocols: yaml["protocols"],
      media_type: yaml["mediaType"],
      documentation: yaml["documentation"],
      #TODO:
      # documentation, schemas, types, traits, resource_types, annotation_types, annotations,
      # security_schemes, secured_by, uses, relative_ur
    }
  end

  def validate!(document, yaml) do
    unless yaml["title"] do
      Ramoulade.error!(document, "A RAML specification MUST have a top level title attribute.")
    end
  end
end
